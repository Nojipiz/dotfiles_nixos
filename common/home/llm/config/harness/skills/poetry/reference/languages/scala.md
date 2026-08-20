# Scala

Load this file when writing or reviewing Scala. SKILL.md rules still apply. Poet wins.

## Combinators that read as English

Name the values, then let the combinator be the verb.

| Intent | Use |
|---|---|
| fallback | `orElse` |
| default | `getOrElse`, `Option.when` / `Option.unless` |
| handle both cases | `fold`, `map` / `leftMap` |
| question | `exists`, `forall`, `contains` |
| keep / drop | `filter`, `filterNot`, `collect`, `collectFirst` |
| transform | `map`, `flatMap`, `flatten` |
| both or neither | `zip`, `zipWith` |
| search | `find` |
| decide | `Either.cond`, `Either.catchOnly` |
| sequence | `traverse`, `sequence` |
| settle a value | `foreach`, `tap` |

```scala
val environmentConfiguration = loadFromEnvironment()
val defaultConfiguration = loadDefault()
val configuration = environmentConfiguration orElse defaultConfiguration

val withdrawnBalance = Either.cond(
  amount <= balance,
  balance - amount,
  InsufficientFunds(amount),
)

val activeSubscriberEmails =
  subscribers.collect { case subscriber if subscriber.isActive => subscriber.email }
```

Prefer `for` when the story is a sequence of dependent steps. Prefer a named `val` plus combinator when it reads as a single sentence.

```scala
val authorizedWithdrawal =
  for
    subscriber <- findSubscriber(subscriberId)
    _          <- ensureCanWithdraw(subscriber, amount)
    balance    <- withdraw(subscriber.balance, amount)
  yield balance
```

Pattern match instead of boolean ladders. Keep matches exhaustive — the compiler already enforces this when the source is sealed.

## Type safety

If it compiles, the assumptions should still hold. Encode the domain in types so a behavior-changing edit is a type error, not a passing rename.

### Specific functions, specific types
No `Any`. No `asInstanceOf`. No `null`. No `String`/`Int` standing in for domain values.

```scala
opaque type SubscriberId = String
object SubscriberId:
  def parse(raw: String): Either[InvalidSubscriberId, SubscriberId] =
    Either.cond(raw.nonEmpty, raw, InvalidSubscriberId(raw))

opaque type Money = BigDecimal
object Money:
  def parse(raw: BigDecimal): Either[InvalidMoney, Money] =
    Either.cond(raw >= 0, raw, InvalidMoney(raw))
  extension (money: Money)
    def minus(amount: Money): Either[InsufficientFunds, Money] =
      Either.cond(amount <= money, money - amount, InsufficientFunds(amount))

def chargeSubscriber(subscriber: Subscriber, amount: Money): Either[ChargeFailure, Subscriber] = ???
```

### Smart constructors
The only way to build a refined value is a function that can fail. `apply` on the companion is not a back door.

### Illegal states unrepresentable
Replace flag clusters with a sealed ADT. A paid-and-refunded-and-draft order must not compile.

```scala
sealed trait OrderStatus
object OrderStatus:
  case object Draft extends OrderStatus
  final case class Paid(paidAt: Instant) extends OrderStatus
  final case class Refunded(paidAt: Instant, refundedAt: Instant) extends OrderStatus

def issueRefund(order: Order): Either[RefundFailure, Order] =
  order.status match
    case OrderStatus.Paid(paidAt) =>
      Right(order.copy(status = OrderStatus.Refunded(paidAt, Instant.now())))
    case OrderStatus.Draft =>
      Left(OrderNotPaid(order.id))
    case OrderStatus.Refunded(_, _) =>
      Left(OrderAlreadyRefunded(order.id))
```

### Errors as values
Domain returns `Either[DomainError, Value]` or `Option`. Sealed error ADTs, not `String`/`Exception`.

### Exhaustiveness is the test
A new `OrderStatus` case must break every match that did not handle it. Do not add a wildcard to silence the compiler in domain code.

## Placeholder stubs

If the function needs to exist, implement it. If it doesn't, don't create it.

```scala
// Bad: stub that returns a hardcoded value
def validateUser(input: UserInput): Boolean = true

// Bad: empty catch that swallows the error
try
  riskyOperation()
catch
  case _ => ()

// Bad: TODO comment as implementation
def processPayment(order: Order): Either[PaymentError, Receipt] =
  // TODO: implement payment processing
  ???
```

```scala
// Good: implement or remove
def validateUser(input: UserInput): Either[ValidationError, User] =
  for
    name  <- validateName(input.name)
    email <- validateEmail(input.email)
  yield User(name, email)

// Good: ??? signals a genuine unfinished branch — the compiler warns on it
def processPayment(order: Order): Either[PaymentError, Receipt] =
  // This compiles but will throw at runtime — only acceptable during early prototyping
  ???
```

**Rule:** `???` is a compiler-visible placeholder, not a production pattern. If the function ships, implement it. Empty catch blocks are always wrong.

### Refine, do not annotate
`subscriber: Subscriber` is the check. `subscriber: Any /* actually a Subscriber */` is a defect. Phantom or tagged types are welcome when two values share a representation but must not mix (`DebitMoney` vs `CreditMoney`).
