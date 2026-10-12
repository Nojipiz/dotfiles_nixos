---
description: Triage PR review comments, fix accepted ones in one atomic commit
agent: poet-duelist
---

Invoke the `poet-duelist` agent with the request below. It runs Phase A (verdict table) then stops — present its verdicts and gate each one (Accept / Decline: will be done later / Decline: out of scope / Decline: fix isn't correct) before re-invoking it with the decisions for Phase B.

Request: $ARGUMENTS

Expected scope: `<pr-number-or-url> [--repo owner/name]`. Empty request: ask for the PR.
