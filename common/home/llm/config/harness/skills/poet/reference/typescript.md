# TypeScript

Load this file when writing or reviewing TypeScript. SKILL.md rules still apply. Poet wins.

## Compiler strictness

Assume (or require) `strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noImplicitOverride`. The project's existing linter and formatter are the authority — do not add rules that fight them.

## Combinators that read as English

Prefer named values plus array/promise methods over index loops.

| Intent      | Use                                                      |
| ----------- | -------------------------------------------------------- |
| fallback    | `??` (not logical or: it treats `0` and `""` as missing) |
| keep / drop | `filter`                                                 |
| transform   | `map`, `flatMap`                                         |
| question    | `some`, `every`, `includes`                              |
| search      | `find`                                                   |
| both cases  | discriminated `switch`, or a typed `Result` match helper |

```typescript
const environmentConfiguration = loadFromEnvironment();
const defaultConfiguration = loadDefault();
const configuration = environmentConfiguration ?? defaultConfiguration;

const activeSubscriberEmails = subscribers
  .filter(isActiveSubscriber)
  .map((subscriber) => subscriber.email);
```

## Type operations

Derive types from types. A change to a source type must propagate everywhere without a manual sweep. If you define `User` once, every `CreateUser`, `UpdateUser`, `UserPreview` is a type expression over `User` — not a copy.

### Built-in utility types

| Operation | What it does | Use when |
|---|---|---|
| `Pick<T, K>` | keep only keys `K` | narrow to a subset of fields |
| `Omit<T, K>` | drop keys `K` | hide internals or computed fields |
| `Partial<T>` | all props optional | patch / update payloads |
| `Required<T>` | all props required | after a merge or default-fill |
| `Readonly<T>` | all props readonly | immutable view of a type |
| `Record<K, V>` | object with keys `K`, values `V` | maps, lookup tables |
| `Extract<T, U>` | keep union members assignable to `U` | narrow a union |
| `Exclude<T, U>` | drop union members assignable to `U` | remove cases from a union |
| `NonNullable<T>` | strip `null` and `undefined` | after a guard or filter |
| `ReturnType<F>` | return type of function `F` | derive a type from a handler |
| `Parameters<F>` | parameter tuple of `F` | derive arg types from a handler |
| `Awaited<T>` | unwrap `Promise<T>` | async return types |

```typescript
type User = { id: SubscriberId; name: string; email: string; passwordHash: string };
type UserPreview = Pick<User, "id" | "name" | "email">;
type CreateUser = Omit<User, "id">;
type UserPatch = Partial<CreateUser>;
type SubscriberLookup = Record<SubscriberId, User>;
```

### Mapped types

Transform every property in a type at once. Add or remove `readonly` and `?` modifiers with `+`/`-`.

```typescript
type Nullable<T> = { [K in keyof T]: T[K] | null };
type Mutable<T> = { -readonly [K in keyof T]: T[K] };
type Validated<T> = { readonly [K in keyof T]: T[K] };
```

### Conditional types and `infer`

Extract parts of a type, or branch on structure.

```typescript
type ErrorOf<T> = T extends Result<infer E, unknown> ? E : never;
type ValueOf<T> = T extends Result<unknown, infer V> ? V : never;

type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;
```

### Indexed access and `keyof`

Index into a type with a key type. Derive field types from the parent.

```typescript
type OrderStatus = Order["status"];
type OrderStatusKind = OrderStatus["kind"];

function getField<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

### Template literal types

Derive string types from other string types.

```typescript
type EventName = "click" | "focus" | "blur";
type HandlerName = `on${Capitalize<EventName>}`; // "onClick" | "onFocus" | "onBlur"
```

### Prefer derivation over duplication

If you find yourself writing `CreateUser`, `UpdateUser`, `UserSnapshot` as separate hand-written types that share fields with `User`, derive them. The compiler will enforce the relationship.

```typescript
type CreateUser = Omit<User, "id">;
type UpdateUser = Partial<Omit<User, "id" | "passwordHash">>;
type UserSnapshot = Readonly<Pick<User, "id" | "name" | "email">>;
```

## Type safety

If it compiles, the assumptions should still hold. Encode the domain in types so a behavior-changing edit is a type error, not a passing rename.

### Specific functions, specific types

Do not accept `object`, `Record<string, unknown>`, or `string` when a domain type exists.

```typescript
type SubscriberId = string & { readonly brand: "SubscriberId" };
type MoneyCents = number & { readonly brand: "MoneyCents" };

function chargeSubscriber(
  subscriber: Subscriber,
  amount: MoneyCents,
): Result<ChargeFailure, Subscriber> {
  return { kind: "ok", value: subscriber };
}
```

Brand primitives at construction. Two branded strings must not be assignable to each other.

### Discriminated unions over flag piles

Mutually exclusive states are a union with a `kind` (or equivalent tag). A draft-and-paid order must not typecheck.

```typescript
type OrderStatus =
  | { kind: "draft" }
  | { kind: "paid"; paidAt: Date }
  | { kind: "refunded"; paidAt: Date; refundedAt: Date };

function issueRefund(order: Order): Result<RefundFailure, Order> {
  switch (order.status.kind) {
    case "paid":
      return {
        kind: "ok",
        value: {
          ...order,
          status: {
            kind: "refunded",
            paidAt: order.status.paidAt,
            refundedAt: new Date(),
          },
        },
      };
    case "draft":
      return {
        kind: "err",
        error: { kind: "order-not-paid", orderId: order.id },
      };
    case "refunded":
      return {
        kind: "err",
        error: { kind: "order-already-refunded", orderId: order.id },
      };
  }
}
```

### Exhaustiveness

A `switch` on a union must assign the leftover value to `never`. Adding a new `kind` must break the build.

```typescript
function assertNever(value: never): never {
  throw new Error(`unexpected: ${JSON.stringify(value)}`);
}
```

### `satisfies` and `as const`

Use `satisfies` to check a value against a type without widening. Use `as const` for literal unions.

### Narrow with predicates, not casts

`value is Subscriber`, assertion functions (`asserts value is T`), and control-flow narrowing. `as Subscriber` is not a parse.

### Readonly by default

`readonly` properties, `ReadonlyArray`, `as const` inputs. Mutation happens in dedicated, named steps — not as a side effect of a calculation.

### Refine, do not comment

`amount: MoneyCents` is the check. `amount: number /* cents */` is a defect. Optional fields that change meaning by presence should be a union, not `field?: T` plus a boolean.
