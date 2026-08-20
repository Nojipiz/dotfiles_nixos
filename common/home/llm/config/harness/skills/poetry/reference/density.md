# Density

Code that is too compressed to read. Technically correct but requires mental unpacking.

## Patterns

### 1. Nested Ternaries

```typescript
// Bad: nested ternary — requires mental stack
const status = isActive
  ? isVerified
    ? "active"
    : "pending"
  : "inactive";

// Bad: ternary chain
const color = type === "error"
  ? "red"
  : type === "warning"
    ? "yellow"
    : type === "success"
      ? "green"
      : "gray";
```

```typescript
// Good: named predicates or switch
const status = () => {
  if (!isActive) return "inactive";
  if (!isVerified) return "pending";
  return "active";
}();

// Good: lookup
const STATUS_COLOR: Record<string, string> = {
  error: "red",
  warning: "yellow",
  success: "green",
};
const color = STATUS_COLOR[type] ?? "gray";
```

**Rule:** One ternary is fine. Nesting a ternary inside a ternary is never fine. Use a lookup, switch, or early return.

### 2. Complex Boolean Expressions

```typescript
// Bad: compound boolean — what does this check?
if (user.isActive && (!user.isBanned || user.hasAppealed) && user.loginCount > 0 && !user.isDeleted) {
  // ...
}

// Bad: negation-heavy
if (!(a || b) && !(c && !d)) {
  // ...
}
```

```typescript
// Good: named predicate
const isUserEligibleForFeature =
  user.isActive &&
  (!user.isBanned || user.hasAppealed) &&
  user.loginCount > 0 &&
  !user.isDeleted;

if (isUserEligibleForFeature) {
  // ...
}
```

**Rule:** Extract compound conditions into named predicates. If a boolean expression has more than 2 operators, name it.

### 3. Dense Constructor Calls

```scala
// Bad: inline construction — too many fields to scan
UserProfile(
  id = user.id,
  name = user.name,
  email = user.email,
  subscription = SubscriptionSummary(
    plan = subscription.plan,
    status = subscription.status
  ),
  metadata = Metadata(
    createdAt = Instant.now(),
    source = "api",
    version = 2
  ),
  permissions = user.roles.flatMap(_.permissions).filter(_.isActive)
)
```

```scala
// Good: build parts separately
val profile = UserProfileSummary(id = user.id, name = user.name, email = user.email)
val subscriptionInfo = SubscriptionSummary(plan = subscription.plan, status = subscription.status)
val metadata = Metadata(createdAt = Instant.now(), source = "api", version = 2)
val activePermissions = user.roles.flatMap(_.permissions).filter(_.isActive)

UserProfile(profile, subscriptionInfo, metadata, activePermissions)
```

**Rule:** If a constructor call has more than 4 arguments or any argument involves computation, name the parts.

### 4. Chained Method Calls Without Intermediate Names

```scala
// Bad: long chain — what does each step produce?
val result = users
  .filter(_.isActive)
  .flatMap(_.subscriptions)
  .filter(_.plan == "premium")
  .map(_.billingAmount)
  .sum
```

```scala
// Good: intermediate names tell the story
val activeUsers = users.filter(_.isActive)
val premiumSubscriptions = activeUsers
  .flatMap(_.subscriptions)
  .filter(_.plan == "premium")
val totalRevenue = premiumSubscriptions.map(_.billingAmount).sum
```

**Rule:** Chain length > 4 needs intermediate names. Each named value should tell the reader what the data looks like at that stage.

### 5. Dense Function Signatures

```scala
// Bad: too many params — which is which?
def createAgent(provider: String, name: String, model: String, detached: Boolean, quiet: Boolean, timeout: Int, mode: String): Agent = ???

// Bad: boolean params at call site — what does true mean?
startAgent("claude", true, false, true)
```

```scala
// Good: grouped into a config case class
case class AgentConfig(
  provider: String,
  name: String,
  model: Option[String] = None,
  detached: Boolean = false,
  quiet: Boolean = false,
  timeout: Option[Int] = None,
  mode: Option[String] = None
)

def createAgent(config: AgentConfig): Agent = ???

createAgent(AgentConfig(provider = "claude", name = "my-agent", detached = true))
```

**Rule:** 3+ parameters → group into a case class or config object. Any boolean parameter → named field. The call site must be self-documenting.
