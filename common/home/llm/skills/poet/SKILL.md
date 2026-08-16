---
name: poet
description: Enforces readable, self-explanatory code. Load for code review OR new code creation. Minimal comments, expressive naming, natural language-like structure.
compatibility: opencode, claude, pi
---

## Core Philosophy

Code must read like natural language flowing top-to-bottom. A comment block is almost always a code smell—prefer expressive names and extracted functions. The AI must act as a lens, applying universal grammar rules to all languages, while automatically adapting control flow and side-effect handling based on whether the target language is functional or multi-paradigm.


## Universal Grammar & Naming Rules (All Languages)

These rules apply universally, regardless of the language paradigm.

### No unnecessary comments
Comments are forbidden when code can express the same intent. Exception: links to external resources that provide context impossible to express in code (specs, RFCs, bug reports).
```python
# bad: comment restates code
increment = value + 1  # add one to value

# good: external link adds context the code cannot
def calculateRetryDelay(attempt: int) -> int:
    # @see: [https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
    return min(base_delay * (2 ** attempt), max_delay)

```

### Ubiquitous Language (No Synonyms)

Code must exactly mirror domain terminology. If the business calls it a `Subscriber`, the code cannot call it a `User`, `Client`, or `Account`.

```typescript
// bad: mixing terms for the same concept
function chargeClient(user: Customer) { ... }

// good: consistent domain vocabulary
function chargeSubscriber(subscriber: Subscriber) { ... }

```

### Full names, never abbreviate

Use complete descriptive names. Boilerplate is acceptable.

```typescript
// bad
const uat = getToken();
// good
const userAuthenticationToken = getToken();

```

### Functions describe actions, Values describe entities

Function names must answer "what does this do?" without reading the body. Variable names must answer "what is this?" without reading context.

```typescript
// bad
function check(x) { ... }
const cnt = getActiveSubscriptions().length;

// good
function validateUserInput(input: string) { ... }
const activeSubscriptionCount = getActiveSubscriptions().length;

```

### Boolean Prefixes (is, has, can, should)

Variables holding boolean values must sound like questions or facts so `if` statements read as grammatically correct English.

```typescript
// bad: sounds like an object or command
const active = user.status === 'active';
if (active) { ... } 

// good: sounds like a sentence
const isActive = user.status === 'active';
if (isActive) { ... }

```

### No Double Negatives (Positive Boolean Framing)

Booleans and predicates must always be framed positively so they read naturally when prefixed with `!` or `not`.

```typescript
// bad: brain-bending ("if not not hidden")
if (!isNotHidden) { ... } 

// good: reads like English ("if not visible")
if (!isVisible) { ... } 

```

### Extract magic values & Complex Conditionals

Named constants or variables replace raw literals and complex inline logic.

```typescript
// bad: requires stopping to parse the logic and literals
if (users.length > 5 && user.hasPaidTaxes && !user.hasClaimed) { ... }

// good: reads like a business rule
const minimumUsersForDiscount = 5;
const isEligibleForDiscount = users.length > minimumUsersForDiscount && user.hasPaidTaxes && !user.hasClaimed;

if (isEligibleForDiscount) { ... }

```

### Functions do one thing

Size is irrelevant—cohesion matters. If it does multiple things, extract. When languages allow internal functions, use them to structure a long function without exposing helpers.

```typescript
// good: one purpose, internal helpers for structure
function processUser(input: unknown) {
  const validatedUser = _validateUserInput(input);
  const normalizedUser = _normalizeUser(validatedUser);
  _persistUser(normalizedUser);

  function _validateUserInput(input: unknown): User { ... }
  function _normalizeUser(user: User): User { ... }
  function _persistUser(user: User): void { ... }
}

```

### Generic types need descriptive names

Single-letter type parameters (`T`, `E`, `A`) obscure intent. Name type parameters for what they represent in the domain.

```scala
// bad: single-letter types reveal nothing
def retry[T, E](fallibleAttempt: () => Either[E, T], maxAttempts: Int): Either[E, T] = ???
def findOrDefault[A](items: List[A], predicate: A => Boolean, default: A): A = ???

// good: type names express domain meaning
def retry[Value, Error](fallibleAttempt: () => Either[Error, Value], maxAttempts: Int): Either[Error, Value] = ???
def findOrDefault[Item](items: List[Item], matches: Item => Boolean, fallback: Item): Item = ???
```

### Abstract only when necessary or reused

Do not extract abstractions preemptively. Make code specific and direct. Extract only when the same logic appears in multiple places or clarifies calling code.


## Control Flow & Structure (Paradigm-Dependent)

### Multi-Paradigm (TypeScript, Python, etc.)

* **Guard Clauses:** Enforce early returns to prevent deep nesting. The main happy-path logic must be completely un-indented at the bottom of the function.
```typescript
// bad: nested and hard to follow
function processRefund(order: Order) {
  if (order.isPaid) {
    if (!order.isRefunded) {
      issueRefund(order);
    }
  }
}
// good: prerequisites handled early, happy path reads like prose
function processRefund(order: Order) {
  if (!order.isPaid) return;
  if (order.isRefunded) return;
  issueRefund(order);
}

```

### Functional (Scala, Haskell, etc.)

* **Pattern Matching & Combinators:** Prefer pattern matching over `if/else` chains. Use monadic flow (`for` comprehensions, `do` notation) to handle short-circuiting naturally.
* **Descriptive Chaining:** When chaining optional values or fallbacks, name each one descriptively.
```scala
val environmentConfiguration: Option[Config] = loadFromEnvironment()
val defaultConfiguration: Option[Config] = loadDefault()
val config = environmentConfiguration orElse defaultConfiguration

```

## State, Side Effects & Error Handling (Paradigm-Dependent)

### Functional Languages — Absolute Purity

* **Domain is Pure:** Zero side effects in the domain. Immutability is default. All I/O lives at the boundary. Aim for referential transparency.
* **Errors as Values:** No exceptions for control flow. Domain functions return `Either`, `Result`, `Option`, or equivalent types—never throw.
```scala
// good: domain returns Either, pure
def withdraw(balance: Money, amount: Money): Either[InsufficientFunds, Money] =
  Either.cond(amount <= balance, balance - amount, InsufficientFunds(amount))

```


* **Loops:** Prefer recursion or higher-order functions (`map`, `filter`, `fold`) over imperative loops.

### Multi-Paradigm Languages — Pragmatic Purity

* **Purity by Default:** Push functional patterns where the codebase context allows it. Prefer `map`/`filter`/`reduce` over imperative loops. Use `const`/`final` by default.
* **Boundary Side Effects:** Keep domain logic pure. Encapsulate side effects at boundaries.
```typescript
// good: domain logic is pure, side effects at boundary
function calculateDiscount(order: Order): Order {
  return { ...order, total: order.total * 0.9 };
}
// orchestration layer
const discountedOrder = calculateDiscount(order);
logger.info("discount applied");
await repository.save(discountedOrder);

```

## Usage

Load this skill when:

* Reviewing existing code for readability violations.
* Writing new code to apply these principles from the start.

## Review Output Format

When reviewing, automatically detect the language paradigm and tailor the output. List violations grouped by:

1. **Excessive Comments:** Restating code or replaceable by better names. (Never suggest adding comments to solve a context problem; suggest refactoring instead).
2. **Naming & Vocabulary Violations:** Abbreviations, single-letter variables, unclear intent, mixed domain terminology.
3. **Grammar & Boolean Violations:** Double negatives, missing boolean prefixes (`is/has/can`), complex un-encapsulated conditionals.
4. **Function Design Violations:** Doing multiple things, poorly named generic parameters, premature abstraction.
5. **Control Flow & State Violations:**
* *(If Multi-Paradigm):* Missing guard clauses, deep nesting, imperative loops where functional fits, leaked side effects.
* *(If Functional):* Missed pattern matching opportunities, unsafe exceptions, unnecessary mutability, non-idiomatic monadic chaining.
