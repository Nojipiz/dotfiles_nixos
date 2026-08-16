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
```scala
// bad: comment restates code
val increment = value + 1 // add one to value

// good: name expresses intent
val incrementedValue = value + 1

// good: external link adds context the code cannot
def calculateRetryDelay(attempt: Int): Int =
  // @see: https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/
  math.min(baseDelay * math.pow(2, attempt).toInt, maxDelay)
```

### Ubiquitous Language (No Synonyms)

Code must exactly mirror domain terminology. If the business calls it a `Subscriber`, the code cannot call it a `User`, `Client`, or `Account`.

```scala
// bad: mixing terms for the same concept
def chargeClient(user: Customer): Unit = ???

// good: consistent domain vocabulary
def chargeSubscriber(subscriber: Subscriber): Unit = ???
```

### Full names, never abbreviate

Use complete descriptive names. Boilerplate is acceptable.

```scala
// bad
val uat = getToken()
// good
val userAuthenticationToken = getToken()
```

### Functions describe actions, Values describe entities

Function names must answer "what does this do?" without reading the body. Variable names must answer "what is this?" without reading context.

```scala
// bad
def check(x: String): Boolean = ???
val cnt = getActiveSubscriptions().length

// good
def validateUserInput(input: String): Boolean = ???
val activeSubscriptionCount = getActiveSubscriptions().length
```

### Boolean Prefixes (is, has, can, should)

Variables holding boolean values must sound like questions or facts so `if` statements read as grammatically correct English.

```scala
// bad: sounds like an object or command
val active = user.status == "active"
if (active) { ... }

// good: sounds like a sentence
val isActive = user.status == "active"
if (isActive) { ... }
```

### No Double Negatives (Positive Boolean Framing)

Booleans and predicates must always be framed positively so they read naturally when prefixed with `!` or `not`.

```scala
// bad: brain-bending ("if not not hidden")
if (!isNotHidden) { ... }

// good: reads like English ("if not visible")
if (!isVisible) { ... }
```

### Extract magic values & Complex Conditionals

Named constants or variables replace raw literals and complex inline logic.

```scala
// bad: requires stopping to parse the logic and literals
if (users.length > 5 && user.hasPaidTaxes && !user.hasClaimed) { ... }

// good: reads like a business rule
val minimumUsersForDiscount = 5
val isEligibleForDiscount = users.length > minimumUsersForDiscount && user.hasPaidTaxes && !user.hasClaimed

if (isEligibleForDiscount) { ... }
```

### Functions do one thing

Size is irrelevant—cohesion matters. If it does multiple things, extract. When languages allow internal functions, use them to structure a long function without exposing helpers.

```scala
// good: one purpose, internal helpers for structure
def processUser(input: Any): Unit =
  val validatedUser = validateUserInput(input)
  val normalizedUser = normalizeUser(validatedUser)
  persistUser(normalizedUser)
end processUser

def validateUserInput(input: Any): User = ???
def normalizeUser(user: User): User = ???
def persistUser(user: User): Unit = ???
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
