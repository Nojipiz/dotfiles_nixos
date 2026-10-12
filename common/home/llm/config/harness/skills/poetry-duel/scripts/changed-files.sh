#!/usr/bin/env bash
# List changed files for a PR (scoping context reads).
# Usage: changed-files.sh <PR-or-URL> [--repo owner/repo]
set -euo pipefail

PR="${1:-}"
REPO=""
shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$PR" ]]; then
  echo "usage: changed-files.sh <PR-or-URL> [--repo owner/repo]" >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh CLI not found. Install gh and run 'gh auth login'." >&2
  exit 1
fi

if [[ -z "$REPO" ]]; then
  REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
fi

gh pr diff "$PR" --repo "${REPO:?cannot resolve repo: run inside a checkout or pass --repo owner/repo}" --name-only
