# Naming

Names encode intent. A reader must understand what the value holds or what the function does without seeing its body or definition site.

## Core Rules

- **Full words.** Never abbreviate (`userAuthenticationToken`, not `uat`).
- **Functions** answer "what does this do?"; **values** answer "what is this?"
- **Booleans** use `is`/`has`/`can`/`should` and are framed positively (`isVisible`, never `isNotHidden`).
- **Type parameters** name what they represent (`Value`, `Error`, `Item`), not `T`/`E`/`A`.
- **Collections** are plural; lookups are `byX` (`subscribersById`).

## Patterns

### 1. Names Too Short to Convey Intent

```scala
// Too short — what kind of amount? what context?
val amount: Money = ???
val amountChargedInDefaultCurrency: Money = ???

// Too short — which user? doing what?
val user: User = ???
val userRequestingAccountClosure: User = ???

// Too short — eligible for what?
val isEligible: Boolean = ???
val isSubscriberEligibleForAnnualDiscount: Boolean = ???

// Too short — what does calculate do? calculate what?
def calculate(order: Order): Money = ???
def calculateRefundAmountAfterRestockingFee(order: Order): Money = ???

// Too short — filters which orders by what status?
val orders: List[Order] = ???
val pendingOrdersAwaitingFraudReview: List[Order] = ???
val ordersBySubscriberId: Map[SubscriberId, List[Order]] = ???
```

**Rule:** If you need to see the body to understand the name, the name is too short.

### 2. Overly Literal Names

Names that describe the mechanism, not the purpose.

```typescript
// Bad: describes what it does mechanically
const stringArray: string[] = names;
const numberValue: number = count;
const booleanFlag: boolean = isEnabled;
const objectMap: Map<string, Subscriber> = subscribersById;

// Good: describes what it represents
const activeSubscriberNames: string[] = names;
const retryCount: number = count;
const isSubscriptionActive: boolean = isEnabled;
const subscribersById: Map<string, Subscriber> = subscribersById;
```

**Rule:** The name should tell you what the value means in the domain, not what type it is.

### 3. Verbose Names That Restate the Type

```typescript
// Bad: name restates what the type already says
const subscriberObject: Subscriber = ...;
const dateString: string = ...;
const booleanValue: boolean = ...;
const arrayOfSubscribers: Subscriber[] = ...;
```

```typescript
// Good: name adds information the type doesn't
const requestingSubscriber: Subscriber = ...;
const subscriptionStartDate: string = ...;
const canSubscriberRetry: boolean = ...;
const recentlyActiveSubscribers: Subscriber[] = ...;
```

**Rule:** Don't repeat what the type system already tells you. The name adds semantic context.

### 4. Convention-Blind Naming

Ignoring the project's existing naming patterns.

```typescript
// Project uses camelCase for files
// Bad: new file uses kebab-case
subscriber-service.ts  // when everything else is subscriberService.ts

// Project uses "Repository" suffix for data access
// Bad: new class uses "DAO"
class SubscriberDAO { ... }  // when everything else is SubscriberRepository

// Project uses present tense for functions
// Bad: past tense
function processedSubscriber() { ... }  // when everything else is processSubscriber()
```

**Rule:** Match the existing conventions. If the project says `subscriberService.ts`, new files follow. Consistency beats personal preference.

### 5. Implementation-Describing Names

Names that expose how something works instead of what it does.

```typescript
// Bad: exposes implementation detail
function filterAndMapSubscribers(subscribers: Subscriber[]) { ... }
function arrayWithSortedScores(numbers: number[]) { ... }
const cachedSubscriberMap: Map<string, Subscriber> = ...;

// Good: describes the intent
function activeSubscriberEmails(subscribers: Subscriber[]) { ... }
const sortedScores: number[] = ...;
const subscribersById: Map<string, Subscriber> = ...;
```

**Rule:** The name should describe the result, not the steps to get there.

### 6. Mixed Domain Vocabulary

Using synonyms or inconsistent terms for the same concept.

```typescript
// Bad: same concept, different names across the codebase
// file A: chargeSubscriber()
// file B: billCustomer()
// file C: invoiceAccount()
// All three do the same thing
```

```typescript
// Good: one term, everywhere
chargeSubscriber()
```

**Rule:** Mirror domain terms exactly. No synonyms. If the business says `Subscriber`, the code cannot say `User`, `Client`, or `Account` in the same context.

### 7. Extract Magic Values & Compound Predicates

Name domain literals and complex conditions. Leave `0`, `1`, `""`, `None`/`null` alone.

```scala
val minimumSubscribersForDiscount = 5
val isEligibleForDiscount =
  subscribers.length > minimumSubscribersForDiscount && subscriber.hasPaidTaxes && !subscriber.hasClaimed
if (isEligibleForDiscount) { ... }
```

**Rule:** Domain constants get names. Technical zeros and empty strings don't.
