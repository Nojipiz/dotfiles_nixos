---
description: Review a PR against poetry standards, post approved findings
agent: poet-pr-reviewer
---

Invoke the `poet-pr-reviewer` agent with the request below. It runs Phase A (findings table) then stops — present its findings and gate before re-invoking it with approvals for Phase B posting.

Request: $ARGUMENTS

Expected scope: `<pr-number-or-url> [--repo owner/name]`. Empty request: ask for the PR.
