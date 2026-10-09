---
description: Prose-like readability review and fix
agent: poet
---

Load the `poetry` skill via the skill tool and follow it exactly.

Request: $ARGUMENTS

Route scope from the request:

- `branch` — diff current branch vs root branch (main or default).
- `session` — diff of this session's changes.
- `review_pr <url-or-number>` — in parallel, run `gh pr view <url-or-number> --json files,body,title` and `gh pr diff <url-or-number>`. Read-only report, do not fix.
- `<path|module|file|git diff>` — that scope. Empty request defaults to recent work.
- Plan review — apply the skill categories as a lens, flag what implementation must fix.
