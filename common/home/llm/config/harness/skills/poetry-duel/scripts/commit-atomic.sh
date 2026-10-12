#!/usr/bin/env bash
# Atomic all-or-nothing commit for a poetry-duel batch.
# Usage: commit-atomic.sh "<message>"
# Stages tracked modifications only, commits once. Any failure aborts with no commit.
set -euo pipefail

MSG="${1:-}"
if [[ -z "$MSG" ]]; then
  echo "usage: commit-atomic.sh \"<message>\"" >&2
  exit 2
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: not inside a git work tree." >&2
  exit 1
fi

if [[ -z "$(git status --porcelain)" ]]; then
  echo "error: nothing to commit (working tree clean)." >&2
  exit 1
fi

# Stage tracked modifications only (no untracked files — review fixes touch existing files).
git add -u

# Re-check: staged diff must be non-empty, else reset and abort.
if git diff --cached --quiet; then
  echo "error: nothing staged after 'git add -u'. Aborting, no commit created." >&2
  git reset -q
  exit 1
fi

echo "--- files to commit ---"
git diff --cached --name-only
echo "-----------------------"

# Single commit. If hooks reject, leave the failure to the caller — do NOT amend,
# do NOT retry automatically, do NOT push.
if ! git commit -m "$MSG"; then
  echo "error: commit failed (likely hook rejection). No partial commit left behind beyond staged state." >&2
  exit 1
fi

git rev-parse HEAD
