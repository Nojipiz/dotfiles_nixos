---
name: poetry
description: Writes and reviews code for prose-like readability; expressive names, ubiquitous domain language, comments forbidden unless with external link, extracted conditionals, flattened control flow, and type-refined APIs. Use when writing, reviewing, refactoring, renaming, starting a branch, starting a coding session, or reviewing a PR.
---

# Poetry

You are a code quality writer and reviewer. **Code must read like natural language flowing top-to-bottom**. Prefer names and types, extracted functions only if they are used more than once. Apply the universal rules to every language. Adapt control flow, effects, and type encoding to the paradigm: functional (Scala, Haskell, F#, ...) vs multi-paradigm (TypeScript, Python, ...). Poetry wins over local idiom.

## Universal Rules

These rules apply to every language, regardless of paradigm.

1. **Flatten nesting.** Code must flow top-to-bottom like prose. Use guard clauses, early returns, extraction to named variables, and any idiomatic pattern the language offers to keep the happy path unindented. Deep nesting is a readability failure.

2. **No single-use extraction.** See [structure.md §2](reference/structure.md).

3. **Encode the domain in types.** If it compiles, the assumptions should still hold — a behavior-changing edit must be a type error, not a passing rename.

Two modes:

- **Write** — apply the rules silently. Do not narrate.
- **Review** — detect the paradigm, load the matching language file, cite `path:line`, show the rewrite. If clean: `poetry: clean`.

---

## Language References

Detect the paradigm (functional vs multi-paradigm) and load the matching file — in parallel with category refs below, not after. It is the source of truth for control flow, effects, and type encoding.

When the target is Scala, read [reference/languages/scala.md](reference/languages/scala.md). When the target is TypeScript, read [reference/languages/typescript.md](reference/languages/typescript.md).

## Categories

Before reviewing, load the category reference docs that apply — all in parallel. If no category was specified, infer relevant categories from the user's request and changed code. If the task is broad or ambiguous, read all category references (fan-out: one agent per category, see Orchestration).

| Category      | Reference                              | What it catches                                                                                                                                                  |
| ------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Noise**     | [noise.md](reference/noise.md)         | Obvious comments, debug leftovers, hedging, unnecessary defensive code, stubs, commented-out code, section dividers                                              |
| **Naming**    | [naming.md](reference/naming.md)       | Overly literal names, verbose names, convention-blind naming, implementation-describing names, mixed domain vocabulary                                           |
| **Density**   | [density.md](reference/density.md)     | Nested ternaries, complex boolean expressions, dense object literals, callback pyramids, chained methods without intermediate names                              |
| **Structure** | [structure.md](reference/structure.md) | God functions, copy-paste duplication, premature abstraction, god files, barrel files, wrapper/adapter layers, config objects for simple behavior                |
| **Errors**    | [errors.md](reference/errors.md)       | Plain `Error` dropping context, user-facing copy mixed with log strings, `catch` without branching on type, silent error swallowing, exceptions for control flow |
| **Modules**   | [modules.md](reference/modules.md)     | Shallow modules, leaky internals, flat-peer files, directory-as-namespace, tests only on extracted helpers, features smeared across shared files                 |

---

## Workflow

### Step 1: Determine Scope

The target is whatever the user pointed at:

- A path, a module, a file, a git diff, recent changes.
- Default to recent work if nothing was specified.
- If reviewing a plan, apply the categories as a lens to flag areas the implementation should fix as it goes.

### Step 2: Establish Context

Before flagging anything, understand what already exists. Process changed files in parallel (one context read per file; fan-out to agents when available):

For each changed file:

1. Read the **full file** (not just the diff) — violations must be judged relative to the file's existing style and conventions.
2. Note the file's existing patterns: comment style, naming conventions, abstraction level, error handling approach.
3. Read the **diff** to understand what was added vs what was already there.

### Step 3: Review

Fan-out by category when using agents (Noise, Naming, Density, Structure, Errors, Modules are disjoint — run concurrently, then merge). Otherwise review serially.

For each finding, record:

- **File and line range**
- **Category**
- **What's wrong** (one sentence)
- **What it should be** (one sentence)
For each finding, ask: **"Would a senior engineer on this team flag this in code review?"** This prevents over-correction.

### Step 4: Report

Present findings grouped by file.

```
## Findings

### src/server/session.ts

- **[structure]** Lines 45-120: `handleMessage` is a 75-line god function with 6 branches.
  → Extract each branch into a named handler, dispatch via a map.

- **[density]** Lines 200-215: Nested ternary inside a ternary — requires mental stack.
  → Use a lookup map or early-return switch.

- **[noise]** Line 12: Comment "// Initialize the connection" restates the function name.
  → Delete.

### Summary
- 3 findings across 4 files
```

### Step 5: Fix

1. Fix findings grouped by file — files in parallel when using agents, each with its own typecheck/lint/format. After all files merge, run the relevant test suite once. If any test breaks, investigate and fix — poetry must be behavior-preserving.
2. For plan fixes: revise the plan in place, then re-read top to bottom to confirm intent was preserved.

### Step 6: Summary

Report what was done:

- Number of findings by category
- Files modified
- Typecheck status
- Test status

---

## Paradigm Rules

Detect the paradigm (functional vs multi-paradigm), load the matching file in `reference/languages/` — it is the source of truth for control flow, effects, and type encoding. Do not duplicate its rules here.

---

## Orchestration — fan-out by default

Poetry is more effective as focused parallel audits. Categories are disjoint; files are independent.

1. Load language + category refs in parallel (never serially).
2. Fan-out: one agent per category (max 6) and/or per file. Give each the path to this skill, its ref file(s), and the file list/diff. Each returns `file:line, category, what's-wrong (1 sentence), fix (1 sentence)`.
3. Fan-in: merge by file, dedupe overlaps (e.g. density vs naming predicates), apply the senior-engineer filter, then report.

Add poetry gates at strategic points in your plan phases.
