---
name: poet
description: Writes and reviews code for prose-like readability; expressive names, ubiquitous domain language, comments forbidden unless user-validated with external link, extracted conditionals, flattened control flow, and type-refined APIs. Use when writing, reviewing, refactoring, or renaming code, or when the user mentions readability, naming, comments, or clean structure.
compatibility: opencode, claude, pi
---

Code must read like natural language flowing top-to-bottom. Prefer names, extracted functions, and types over comments. Apply the universal rules to every language. Adapt control flow, effects, and type encoding to the paradigm: functional (Scala, Haskell, F#, …) vs multi-paradigm (TypeScript, Python, …). Poet wins over local idiom.
es
When the target is Scala, Read [reference/scala.md](reference/scala.md). When the target is TypeScript, Read [reference/typescript.md](reference/typescript.md).

## Grammar & Naming

### Comments
Forbidden by default. Code must express intent through names, types, and structure. The only exception: a comment the user has explicitly validated that contains an external link (spec, RFC, bug tracker, blog post). No link, no comment.
```scala
val incrementedValue = value + 1 // Code is self-documenting.

def calculateRetryDelay(attempt: Int): Int =
  // @see: https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/
  math.min(baseDelay * math.pow(2, attempt).toInt, maxDelay)
```

### Ubiquitous language
Mirror domain terms exactly. No synonyms. If the business says `Subscriber`, the code cannot say `User`, `Client`, or `Account`.
```scala
def chargeSubscriber(subscriber: Subscriber): Unit = ???
```

### Names
- Full words. Never abbreviate (`userAuthenticationToken`, not `uat`).
- Functions answer "what does this do?"; values answer "what is this?"
- Booleans use `is`/`has`/`can`/`should` and are framed positively (`isVisible`, never `isNotHidden`).
- Name type parameters for what they represent (`Value`, `Error`, `Item`), not `T`/`E`/`A`.
- Collections are plural; lookups are `byX` (`subscribersById`).

### Extract magic values & compound predicates
Name domain literals and complex conditions. Leave `0`, `1`, `""`, `None`/`null` alone.
```scala
val minimumUsersForDiscount = 5
val isEligibleForDiscount =
  users.length > minimumUsersForDiscount && user.hasPaidTaxes && !user.hasClaimed
if (isEligibleForDiscount) { ... }
```

### Functions do one thing
Cohesion matters, not line count. Orchestrate in one function; put each step in a specifically typed helper. Prefer internal functions when the language allows, so helpers stay unexported.
```scala
def persistValidUser(rawUserInput: RawUserInput): Unit =
  val validatedUser = validateUserInput(rawUserInput)
  val normalizedUser = normalizeUser(validatedUser)
  persistUser(normalizedUser)
```

### Abstract only when necessary or reused
Stay specific. Extract only when the same logic appears twice or the extraction makes the caller read as prose.

## Type Safety

Types document assumptions. A change that alters behavior must fail to compile, not slip through as a still-green rename.

- Specific functions for specific types. `charge(subscriber: Subscriber)` — not `charge(entity: Any)` / `unknown` / `object` / untyped `string`.
- Refine domain values. IDs, money, emails, and statuses are not raw `String`/`Int`/`Boolean`.
- *Make illegal states unrepresentable*. Mutually exclusive cases are a sum type / discriminated union, not a pile of flags.
- This is not dependent types or compile-time content validation. It is precise signatures and refined types so the compiler guards the assumptions.

## Control Flow

### Multi-paradigm (TypeScript, Python, …)
Guard clauses. Prerequisites return early. Happy path stays unindented at the bottom.
```typescript
function processRefund(order: Order) {
  if (!order.isPaid) return;
  if (order.isRefunded) return;
  issueRefund(order);
}
```

### Functional (Scala, Haskell, …)
Pattern match instead of `if/else` chains. Use monadic flow (`for` / `do`) for short-circuiting. Name each intermediate in a chain.
```scala
val environmentConfiguration: Option[Config] = loadFromEnvironment()
val defaultConfiguration: Option[Config] = loadDefault()
val config = environmentConfiguration orElse defaultConfiguration
```

## State, Effects & Errors

### Functional — absolute purity
Domain has zero side effects. Immutability is default. I/O lives at the boundary. Referential transparency. No exceptions for control flow — return `Either` / `Result` / `Option`. Prefer `map` / `filter` / `fold` / recursion over imperative loops.
```scala
def withdraw(balance: Money, amount: Money): Either[InsufficientFunds, Money] =
  Either.cond(amount <= balance, balance - amount, InsufficientFunds(amount))
```

### Multi-paradigm — pragmatic purity
Push `map`/`filter`/`reduce` and `const`/`final` by default. Domain stays pure. Side effects stay at the orchestration boundary.
```typescript
function calculateDiscount(order: Order): Order {
  return { ...order, total: order.total * 0.9 };
}
const discountedOrder = calculateDiscount(order);
logger.info("discount applied");
await repository.save(discountedOrder);
```

## Write
Apply silently. Do not narrate these rules.

## Review
Detect the paradigm and load the matching language file. Cite `path:line`. Show the rewrite. Poet wins over local idiom. If clean: `poet: clean`.

Group violations:

1. **Comments** — any comment without a user-validated external link.
2. **Naming & vocabulary** — abbreviations, unclear intent, mixed domain terms, single-letter type params.
3. **Grammar & booleans** — double negatives, missing `is`/`has`/`can`/`should`, un-named compound predicates.
4. **Function design** — mixed concerns, premature abstraction, unspecific types.
5. **Type safety** — `Any`/`any`, primitive obsession, illegal states that still typecheck, casts that hide breakage.
6. **Control flow & effects**
   - Multi-paradigm: missing guards, deep nesting, imperative loops where a transform fits, leaked side effects.
   - Functional: missed pattern match, thrown exceptions, mutability, non-idiomatic combinators.
