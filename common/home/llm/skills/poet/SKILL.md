---
name: poet
description: Enforces readable, self-explanatory code. Load for code review OR new code creation. Minimal comments, expressive naming, natural language-like structure.
compatibility: opencode, claude, pi
---

## Rules

### No unnecessary comments

Comments are forbidden when code can express the same intent. A comment block is almost always a code smell — prefer better names or extracted functions.

```python
# bad: comment restates code
increment = value + 1  # add one to value

# good: name expresses intent
incremented_value = value + 1
```

### Full names, never abbreviate

Use complete descriptive names. Boilerplate is acceptable.

```typescript
// bad
const uat = getToken();

// good
const userAuthenticationToken = getToken();
```

### Function names describe actions

Names must answer "what does this do?" without reading the body.

```typescript
// bad
function check(x) { ... }

// good
function validateUserInput(input: string) { ... }
```

### Variable names describe entities

Names must answer "what is this?" without reading context.

```typescript
// bad
const cnt = getActiveSubscriptions().length;

// good
const activeSubscriptionCount = getActiveSubscriptions().length;
```

### Extract magic values

Named constants or variables replace raw literals in logic.

```typescript
// bad
if (users.length > 5) { ... }

// good
const minimumUsersForGroupDiscount = 5;
if (users.length > minimumUsersForGroupDiscount) { ... }
```

## Language Idioms — Functional Languages

For languages with first-class functional support (Scala, Haskell, Kotlin, F#, Clojure, Elixir):

- Immutability is default. Mutability requires explicit justification.
- No exceptions for control flow. Use `Either`, `Result`, `Option`, or equivalent types.
- Prefer pattern matching over if/else chains.
- Prefer recursion or higher-order functions (`map`, `filter`, `fold`) over loops.
- Aim for referential transparency — functions must return the same output for the same input with no hidden side effects, using effect systems when it's neccesary.

```scala
// bad: mutable loop with exceptions
var results = List.empty[String]
for (user <- users) {
  if (user.age < 18) throw new UnderageException(user.name)
  results = results :+ user.name
}

// good: immutable pipeline with Either
def extractNames(users: List[User]): Either[AppError, List[String]] =
  users.traverse { user =>
    Either.cond(user.age >= 18, user.name, UnderageError(user.name))
  }
```

When chaining optional values or fallbacks, name each one descriptively so the final expression reads like natural language. Use whatever combinator the language provides (`orElse`, `??`, `|`, `firstNotNullOf`, etc.):

```scala
val environmentConfiguration: Option[Config] = loadFromEnvironment()
val defaultConfiguration: Option[Config] = loadDefault()
val config = environmentConfiguration orElse defaultConfiguration
```

```scala
// bad: mutable loop with exceptions
var results = List.empty[String]
for (user <- users) {
  if (user.age < 18) throw new UnderageException(user.name)
  results = results :+ user.name
}

// good: immutable pipeline with Either
def extractNames(users: List[User]): Either[AppError, List[String]] =
  users.traverse { user =>
    Either.cond(user.age >= 18, user.name, UnderageError(user.name))
  }
```

## Language Idioms — Multi-paradigm Languages

For languages where functional is optional but supported:

- Push functional patterns where the codebase context allows it.
- Prefer `map`/`filter`/`reduce` over imperative loops when readable.
- Use `const`/`final` by default. Justify `var`/`let` mutations explicitly.
- Encapsulate side effects at boundaries. Keep core logic pure where possible.
- If the project uses a functional library (fp-ts, Effect, Arrow), follow functional conventions strictly.

```typescript
// bad: imperative mutation
const results = [];
for (const user of users) {
  if (user.isActive) {
    results.push(user.name.toUpperCase());
  }
}

// good: functional pipeline
const activeUserNames = users
  .filter((user) => user.isActive)
  .map((user) => user.name.toUpperCase());
```

## Usage

Load this skill when:
- Reviewing existing code for readability violations
- Writing new code to apply these principles from the start

## Review Output

When reviewing, list violations grouped by:
- **Excessive comments** — restating code or replaceable by better names
- **Naming violations** — abbreviations, single-letter variables, unclear intent
- **Readability issues** — nested logic, non-obvious conditions, poor top-to-bottom flow
- **Functional violations** — unnecessary mutability, exceptions for control flow, imperative loops where functional fits

Never suggest adding comments to solve a context problem. Suggest refactoring instead.
