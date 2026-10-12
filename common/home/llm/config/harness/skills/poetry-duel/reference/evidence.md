# Evidence guide for poetry-duel verdicts

Verdict ranks: types > tests > docs > runtime reasoning. Canonical close/fix shapes and gating live in `SKILL.md` Step 4 — this file only details what counts as proof.

## 1. Types (strongest)

- Cite the declaration that makes the bug unrepresentable: `path:line`.
- Examples: union variant, exhaustive `match`/`switch`, non-nullable / branded type, `readonly`, capability token.
- Verify with the compiler (`tsc --noEmit`, `sbt compile`, …). Record command + result.

## 2. Tests

- Cite the covering test: `path:line` + test name. Run it; record command + pass.
- No existing test means either the comment is VALID (add the test with the fix) or you write a new passing test to prove INVALID — the latter is weaker than a pre-existing one; say so in the verdict.

## 3. Documentation / contract

- Cite README, spec, ADR, config schema, or API contract with path or URL. Quote the exact invariant.
- Docs contradicting code lose — flag the docs as stale instead of closing.

## 4. Runtime reasoning (weakest, last resort)

- Trace the full guard/caller chain in the verdict, `path:line` per link. "Shouldn't happen" without a chain is not proof.
