# Errors

How errors are created, propagated, and handled. AI drops context, mixes concerns, and swallows failures.

## Patterns

### 1. Plain Error Dropping Context

```
// Bad: generic error — where did this happen? why?
throw new Error("something went wrong")
throw new Error("invalid input")
throw new Error("not found")
```

```
// Good: error is a product type carrying context
OrderNotFound(orderId: String)

// Good: error is a sum type — each variant names a failure mode
PaymentError = InsufficientFunds(available: Money, requested: Money)
             | CardExpired(expiresAt: Date)
             | ProviderUnavailable(provider: String, retryAfter: Duration)
```

**Rule:** Every error must answer: what failed, what was the input, and what was the expected state. A plain string is never acceptable in domain code. Model errors as algebraic data types — product types for context, sum types for failure modes.

### 2. User-Facing Copy Mixed With Log Strings

```
// Bad: same string used for logging and user display
throw new Error(`Failed to process order ${orderId}`)
// Later: catch (e) { showToast(e.message) }
// User sees: "Failed to process order ord_123"
```

```
// Good: product type with separate fields for each audience
OrderProcessingError(
  orderId: String,
  cause: Error,
  developerMessage: String,   // for logs — includes technical detail
  userMessage: String          // for UI — actionable and safe
)
```

**Rule:** Error messages for developers (logs) and users (UI) are different things. The developer message includes technical detail. The user message is actionable and safe. Model this as separate fields on the same product type.

### 3. Catch Without Branching on Type

```
// Bad: catch-all that treats every error the same
try {
  processPayment(order)
} catch (error) {
  log("Payment failed", error)
  return Failure("Payment failed")
}
```

```
// Good: pattern match on the sum type
try {
  processPayment(order)
} catch (error) {
  match error {
    InsufficientFunds(available, requested) =>
      return Failure(InsufficientFundsDetail(available))
    CardExpired(expiresAt) =>
      return Failure(CardExpiredDetail(expiresAt))
    ProviderUnavailable(provider, retryAfter) =>
      log("Payment provider down", provider, retryAfter)
      throw RetryableError("payment-provider", retryAfter)
    _ =>
      throw error  // Unknown errors propagate — don't swallow
  }
}
```

**Rule:** A catch block that doesn't branch on the error type is suspicious. If you can't name the failure modes, you don't understand the code. Pattern match on the sum type.

### 4. Silent Error Swallowing

```
// Bad: catch that does nothing
try {
  riskyOperation()
} catch (error) {
  // silently ignore
}

// Bad: catch that only logs
try {
  riskyOperation()
} catch (error) {
  log(error)
  // continues as if nothing happened
}
```

**Rule:** Every catch must either: (a) handle the specific error and recover, (b) rethrow with added context, or (c) return a typed error value. Silent swallowing is never acceptable.

### 5. Exceptions for Control Flow

```
// Bad: exception as expected outcome
function findUser(id: String): User {
  val user = db.get(id)
  if (user == null) throw UserNotFound(id)  // This is expected, not exceptional
  return user
}

// Used in normal flow:
try {
  val user = findUser(id)
} catch {
  case UserNotFound(id) => // handle
}
```

```
// Good: return a value for expected cases
function findUser(id: String): Option<User> {
  return db.get(id)
}

// Or with richer error:
function findUser(id: String): Either<UserNotFound, User> {
  val user = db.get(id)
  return user match {
    case Some(u) => Right(u)
    case None    => Left(UserNotFound(id))
  }
}
```

**Rule:** If the caller is expected to handle the case, it's not an exception — it's a return value. Model expected failures as `Option` or `Either` (sum types). Reserve exceptions for truly unexpected failures (infrastructure crash, memory exhaustion).
