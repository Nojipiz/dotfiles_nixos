# Modules

How code is organized into files and directories. AI creates shallow, leaky, or namespace-only modules.

## Patterns

### 1. Leaky Internals

Module exposes implementation details that callers shouldn't depend on.

```
// Bad: exposing internal types
payment-module/
  PaymentProcessor       — public
  StripeClient           — internal detail
  RetryPolicy            — internal detail
  PaymentRow             — internal detail (database schema)
  ─────────────────────
  export: PaymentProcessor, StripeClient, RetryPolicy, PaymentRow
```

```
// Good: public API hides internals
payment-module/
  PaymentProcessor       — public
  StripeClient           — internal (not exported)
  RetryPolicy            — internal (not exported)
  PaymentRow             — internal (not exported)
  ─────────────────────
  export: PaymentProcessor, PaymentResult, PaymentOptions
```

**Rule:** Export the public API, not the implementation. If a caller shouldn't use it, don't export it.

### 2. Flat-Peer Files

All files at the same level with no grouping, even when they form a cohesive unit.

```
// Bad: flat structure for a cohesive feature
agent/
  agent-list
  agent-detail
  agent-card
  agent-status
  agent-actions
  agent-queries
  agent-types
  agent-utils
  agent-constants
```

```
// Good: group by cohesion
agent/
  list
  detail
  card
  shared/
    status
    types
  actions
  queries
```

**Rule:** If files always change together and share types, group them. A directory with 8+ files at the same level is a smell.
