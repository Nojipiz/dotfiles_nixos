#!/usr/bin/env bash
# Fetch all PR comments deterministically via gh.
# Usage: fetch-pr-comments.sh <PR-or-URL> [--repo owner/repo] [--out file.json]
set -euo pipefail

PR="${1:-}"
OUT=""
REPO=""
shift || true

# Resolve owner/repo explicitly so the script works outside a checkout too.
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
if [[ -z "$REPO" ]]; then
  REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
fi
if [[ -z "$REPO" ]]; then
  echo "error: cannot resolve repo. Run inside a checkout or pass --repo owner/repo." >&2
  exit 1
fi

if [[ -z "$PR" ]]; then
  echo "usage: fetch-pr-comments.sh <PR-or-URL> [--repo owner/repo] [--out file.json]" >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh CLI not found. Install gh and run 'gh auth login'." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq not found. Install jq." >&2
  exit 1
fi

# Resolve PR number from URL or number.
PR_NUMBER="$PR"
if [[ "$PR" =~ /pull/([0-9]+) ]]; then
  PR_NUMBER="${BASH_REMATCH[1]}"
fi

TMPDIR_OUT="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_OUT"' EXIT

OWNER="${REPO%%/*}"
NAME="${REPO#*/}"

# 1. Issue (conversation) comments, 2. inline review comments, 3. PR metadata.
gh api "repos/${REPO}/pulls/${PR_NUMBER}/comments" --paginate > "$TMPDIR_OUT/inline.json"
gh api "repos/${REPO}/issues/${PR_NUMBER}/comments" --paginate > "$TMPDIR_OUT/issue.json"
gh pr view "$PR_NUMBER" --repo "$REPO" --json number,title,url,headRefName,baseRefName,author,state > "$TMPDIR_OUT/meta.json"

# 4. Thread resolution state. REST has none, so join via GraphQL reviewThreads.
THREADS_QUERY='query($owner: String!, $name: String!, $number: Int!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100, after: $cursor) {
        pageInfo { hasNextPage endCursor }
        nodes { isResolved comments(first: 100) { nodes { databaseId } } }
      }
    }
  }
}'

echo '[]' > "$TMPDIR_OUT/thread_nodes.json"
CURSOR=""
while :; do
  if [[ -z "$CURSOR" ]]; then
    PAGE="$(gh api graphql -F owner="$OWNER" -F name="$NAME" -F number="$PR_NUMBER" -f query="$THREADS_QUERY")"
  else
    PAGE="$(gh api graphql -F owner="$OWNER" -F name="$NAME" -F number="$PR_NUMBER" -F cursor="$CURSOR" -f query="$THREADS_QUERY")"
  fi
  echo "$PAGE" | jq '.data.repository.pullRequest.reviewThreads.nodes' > "$TMPDIR_OUT/page_nodes.json"
  jq -s '.[0] + .[1]' "$TMPDIR_OUT/thread_nodes.json" "$TMPDIR_OUT/page_nodes.json" > "$TMPDIR_OUT/acc.json"
  mv "$TMPDIR_OUT/acc.json" "$TMPDIR_OUT/thread_nodes.json"
  HAS_NEXT="$(echo "$PAGE" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')"
  CURSOR="$(echo "$PAGE" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor // empty')"
  [[ "$HAS_NEXT" == "true" ]] || break
done

jq -n \
  --slurpfile inline "$TMPDIR_OUT/inline.json" \
  --slurpfile issue "$TMPDIR_OUT/issue.json" \
  --slurpfile meta "$TMPDIR_OUT/meta.json" \
  --slurpfile threads "$TMPDIR_OUT/thread_nodes.json" \
  '($threads[0] | map({(.comments.nodes[].databaseId | tostring): .isResolved}) | add // {}) as $resolved
  | {
    pr: $meta[0],
    inline_comments: ($inline[0] | map({
      id, author: .user.login, author_type: .user.type, body,
      path, line: (.line // .original_line),
      diff_hunk, url: .html_url, created_at, in_reply_to: .in_reply_to_id,
      is_resolved: $resolved[(.id | tostring)]
    })),
    issue_comments: ($issue[0] | map({
      id, author: .user.login, author_type: .user.type, body, url: .html_url, created_at
    }))
  }' > "$TMPDIR_OUT/combined.json"

if [[ -n "$OUT" ]]; then
  mv "$TMPDIR_OUT/combined.json" "$OUT"
  echo "wrote $OUT" >&2
else
  cat "$TMPDIR_OUT/combined.json"
fi
