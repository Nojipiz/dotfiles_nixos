---
name: poetry-duel
description: Triage and resolve PR review comments with evidence-based validation and poetry-style fixes. Use when addressing PR comments, handling review feedback, validating reviewer suggestions, or reviewing a PR with existing comments.
---

# Poetry Duel

Triage PR reviewer comments: every comment is **fixed with code** or **closed with proof**. Fixes follow `poetry`; verdicts follow the hierarchy below. Load `poetry` first via the skill tool — this skill adds triage, gating, and atomic commit only.

## Evidence hierarchy

Strongest proof first. No "can't happen" without one of these; without proof the comment stays VALID. Examples and verification commands: `reference/evidence.md`.

1. **Types** — signature makes the bug unrepresentable. Cite `path:line`, verify with the compiler.
2. **Tests** — pre-existing covering test passes. Cite `path:line` + command run.
3. **Docs / contract** — spec or config invariant precludes the case. Cite the source.
4. **Runtime reasoning (weakest, last resort)** — exact guard/caller chain, `path:line` per link.

## Scripts (`scripts/` — use these, no ad-hoc `gh`)

- `fetch-pr-comments.sh <PR-or-URL> [--repo o/r] [--out f]` — normalized JSON: inline + issue comments + PR meta.
- `changed-files.sh <PR-or-URL> [--repo o/r]` — changed files for scoping reads.
- `commit-atomic.sh "<msg>"` — one all-or-nothing commit. Never pushes.

Require `gh` + `jq` (`gh auth login`). If missing, stop and say so. Do not scrape HTML.

## Workflow

### 0–1. Scope + fetch

Resolve the PR (number or URL, optional `--repo`; defaults to the current branch's PR). Run the fetch script; every unresolved non-bot comment is in scope, resolved/bot listed as skipped with id only. Record per comment: id, author, file:line, body, URL. Script failure means fixing the environment first — never hand-roll partial fetches.

### 2. Context (before any verdict)

Establish context per `poetry` SKILL.md Step 2 (full file, existing patterns, diff). In parallel per its Orchestration rule, also load the matching language + category refs and the duel proof sources (types, callers, covering tests, docs).

### 3. Validate

Exactly one verdict per comment:

- **VALID** — real in this codebase. One sentence: what breaks + repro or failing test.
- **INVALID** — wrong, satisfied, stale, or impossible. Must cite hierarchy proof with `path:line`.

Apply poetry's senior-engineer filter (`poetry` SKILL.md Step 3) — nits it would reject are INVALID; cite the poetry rule + type/test proof. Output per comment: `### [n] file:line @author — first line (url) / Verdict: / Reason: / Proof or fix plan:`.

### 4. Gate through user (mandatory — no auto-fix, no auto-close)

Prompt via the question tool before acting; record a decision per comment; never enter Step 5 with undecided items. Propose exactly one of:

**A. Close with proof** (INVALID only) — posted after Accept, verbatim shape:
```
Closing this comment.

**Reason:** [shortest possible explanation]
**Proof:** [why it can't happen / isn't valid — types, tests, or docs with path:line + command run, e.g. "src/auth/guard.ts:42 User is Admin | Member, match exhaustive (tsc passes); tests/auth/guard.test.ts:88 covers guest rejection"]

Classified via 🧙🏾‍♂️ v1
```

**B. Create fix** (VALID only) — implemented only after Accept; shape follows poetry. After fix + commit, post reply verbatim shape:
```
Fixed in <sha>.

**Change:** [what changed + files]

Classified via 🧙🏾‍♂️ v1
```

Options per comment (verbatim labels): `Accept` / `Decline: will be done later` / `Decline: out of scope` / `Decline: fix isn't correct` (then ask one-line direction). Declined comments stay open and appear in the summary under their label — never in the commit.

### 5. Fix accepted VALIDs

Fix per `poetry` SKILL.md Step 5 (behavior-preserving, typecheck/lint/format, suite once at the end). Duel deltas: behavior may change only if the comment requests it; new behavior needs a covering test, untestable needs stronger type proof instead.

### 6. Atomic commit

All accepted fixes in ONE commit via the script, message `review(pr-<N>): address <k>/<m> comments (<scope>)`. Hook/empty failure aborts with zero commit — fix and retry, never amend, never push.

### 7. Summary

```
## Review summary (PR #N)
Fixed (<sha>): [id] file:line — change
Closed with proof: [id] file:line — Reason / Proof
Later: [id] | Out of scope: [id] | Fix incorrect: [id] — direction needed
Skipped (resolved/bot): [id]
Typecheck: <cmd> pass/fail; Tests: <cmd> pass/fail; Commit: <sha|aborted: reason>
```

## Rules

- Fix shape: poetry wins. Verdicts: evidence wins.
- No verdict without full-file context + named proof source.
- No edit or reply without per-comment Accept. No undecided items past Step 4.
- One commit or nothing; never push; zero in-scope comments reports `poetry-duel: clean`.
