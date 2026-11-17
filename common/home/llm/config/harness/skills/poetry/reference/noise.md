# Noise

Surface-level slop that adds visual noise without meaning. The easiest to detect and fix — the most common AI output.

## Patterns

### 1. Comments

**Detection (do this first, mechanically):** scan every target file for comment tokens — `//`, `/*`, `/**`, `#`, `<!--`, `"""`, `'''`, `--`, `{-`. EVERY match is a `[noise]` finding with fix "delete the comment". Do not read the comment text to decide if it is helpful. Do not keep TODO, FIXME, HACK, NOTE, “why”, “intent”, documentation links, or hedging comments (`should work`, `not sure`, `might`). Those are findings too.

No comments. None. Code must express intent through names, types, and structure. No exceptions — not even for documentation links or references. “Why” is not an exception — encode it in a predicate name (`naming.md §7`) or a boolean (`density.md §2`). If you think a comment is needed, the code isn't clear enough — rewrite the code.

```scala
// Bad: obvious comment
// Initialize the database connection
val databaseConnection = Database.connect(config)

// Good: the code says it
val databaseConnection = Database.connect(config)
```

```typescript
// Bad: section divider
// ==========================================
// HELPER FUNCTIONS
// ==========================================
function calculateOrderTotal(items: CartItem[]): Money { ... }
function applyCouponDiscount(total: Money, coupon: Coupon): Money { ... }

// Good: the file structure is the divider
function calculateOrderTotal(items: CartItem[]): Money { ... }
function applyCouponDiscount(total: Money, coupon: Coupon): Money { ... }
```

```scala
// Bad: tutorial comment
// Use destructuring to extract the name property
val (name, email) = subscriber.profile

// Good: the code is self-evident
val (name, email) = subscriber.profile
```

```scala
// Bad: explains what the code does
// Calculate the total price with tax
val totalWithTax = subtotal * (1 + taxRate)

// Good: the name says it
val totalWithTax = subtotal * (1 + taxRate)
```

```scala
// Bad: explains a standard library method
// Filter active subscribers from the list
val activeSubscribers = subscribers.filter(subscriber => subscriber.isActive)

// Good: the code reads as English
val activeSubscribers = subscribers.filter(subscriber => subscriber.isActive)
```

```scala
// Bad: "why" comment that should be a name
// Check if the subscriber can access the resource
if (subscriber.role == "admin" || resource.isPublic) { ... }

// Good: extract the predicate, name encodes intent
val canSubscriberAccessResource = subscriber.role == "admin" || resource.isPublic
if (canSubscriberAccessResource) { ... }
```

Magic numbers and complex conditions belong to `naming.md §7` / `density.md §2` — don't comment them, name them.

```scala
// Bad: inline comment on a long line
val result = calculateOrderTotalWithDiscountAndTax(subscriberOrder, couponCode, taxRate) // this processes the order

// Good: break the line, name the parts
val processedOrderTotal = calculateOrderTotalWithDiscountAndTax(
  subscriberOrder,
  couponCode,
  taxRate,
)
```

```scala
// Bad: comment explaining a for-comprehension
// Find the subscriber, validate their subscription, then charge them
for
  subscriber <- findSubscriber(subscriberId)
  subscription <- validateSubscription(subscriber)
  receipt <- chargeCard(subscription.paymentMethod, amount)
yield receipt

// Good: the combinator names tell the story
for
  subscriber <- findSubscriber(subscriberId)
  subscription <- validateSubscription(subscriber)
  receipt <- chargeCard(subscription.paymentMethod, amount)
yield receipt
```

```scala
// Bad: comment explaining pattern match
// Handle different order statuses
order.status match
  case OrderStatus.Paid(paidAt) => ...
  case OrderStatus.Draft => ...
  case OrderStatus.Refunded(_, _) => ...

// Good: the match is self-documenting
order.status match
  case OrderStatus.Paid(paidAt) => ...
  case OrderStatus.Draft => ...
  case OrderStatus.Refunded(_, _) => ...
```

```scala
// Bad: Scaladoc restating the signature
/** Charges a subscriber for the given amount.
  * @param subscriber the subscriber to charge
  * @param amount the amount to charge
  * @return the result of the charge
  */
def chargeSubscriber(subscriber: Subscriber, amount: Money): ChargeResult = ???

// Good: no Scaladoc — the types and names are the documentation
def chargeSubscriber(subscriber: Subscriber, amount: Money): ChargeResult = ???

// Bad: documentation link is still a comment — delete it, encode the reason in code
// @see exponential backoff and jitter
def calculateRetryDelay(attempt: Int): Int =
  math.min(baseDelay * math.pow(2, attempt).toInt, maximumDelay)

// Good: no comment — the name and types carry the meaning
def calculateRetryDelay(attempt: Int): Int =
  math.min(baseDelay * math.pow(2, attempt).toInt, maximumDelay)
```

**Rule:** Delete all comments. ALWAYS flag, NEVER keep. Count each comment line or block as one finding. The fix is always deletion (plus a rename/restructure only if `naming.md` or `density.md` applies). Express intent through names, types, extracted predicates, and structure. This includes hedging comments (`// this should work for most cases`, `// not sure if this is the best approach`) — if unsure, investigate and write correct code. There is no “useful comment” category.

### 2. Debug and Logging Leftovers

```scala
println("DEBUG: reached here")
println(s"user: ${Json.stringify(user)}")
debugger // if supported by the runtime
```

**Rule:** Remove all `println`/`console.log`/`console.warn` that aren't part of a deliberate logging strategy. Remove `debugger` statements. Remove commented-out logging.

### 3. Unnecessary Defensive Code

Defensive checks for conditions that can't happen given the code's context.

```scala
// Bad: defensive checks in trusted internal code
def processSubscriber(subscriber: Subscriber): Unit =
  if (subscriber == null) return
  if (!subscriber.id.isInstanceOf[String]) return
  // actual logic...

// Bad: try-catch around code that doesn't throw
try
  val name = subscriber.firstName + " " + subscriber.lastName
  name.trim()
catch
  case _ => "Unknown"
```

```scala
// Good: trust the type system for internal code
def processSubscriber(subscriber: Subscriber): Unit =
  // actual logic directly — types guarantee shape

// Good: defensive code at REAL boundaries
def handleWebSocketMessage(raw: String): Unit =
  Json.parse(raw) match
    case Right(parsed) => processMessage(parsed)
    case Left(error) => logger.warn("Invalid message", error)
```

**Rule:** Validate at system boundaries (user input, network, file I/O). Trust the type system internally. If a `try-catch` can't explain what it's catching, it shouldn't exist.

### 4. Commented-Out Code

```scala
def findSubscriber(subscriberId: SubscriberId): Option[Subscriber] =
  // val cached = cache.get(subscriberId)
  // if (cached.isDefined) return cached
  val subscriber = database.findSubscriberById(subscriberId)
  // cache.set(subscriberId, subscriber)
  subscriber
```

**Rule:** Delete commented-out code. Git preserves history.
