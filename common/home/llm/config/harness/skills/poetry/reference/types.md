# Types

Type system abuse and neglect. AI works around types instead of working with them — casting, ignoring, or duplicating.

## Core Rules

- **Specific functions for specific types.** `charge(subscriber: Subscriber)` — not `charge(entity: Any)` / `unknown` / `object` / untyped `string`.
- **Refine domain values.** IDs, money, emails, and statuses are not raw `String`/`Int`/`Boolean`.
- **Make illegal states unrepresentable.** Mutually exclusive cases are a sum type / discriminated union, not a pile of flags.
- **This is not dependent types or compile-time content validation.** It is precise signatures and refined types so the compiler guards the assumptions.

## Patterns

### 1. Escape Hatch Types

Every language has a way to bypass the type system — `any` in TypeScript, `Any` in Scala, untyped `Object` in Java, raw pointers in C++. Using them defeats the purpose of having a type system.

```
// Bad: bypass type checking
data = response.data as Any
result = value.toString()  // works on anything, fails on nothing at compile time

// Bad: untyped function signature
function processMessage(msg):
  if msg.type == "subscribe": ...
```

```
// Good: proper types
data: AgentResponse = response.data

function processMessage(msg: AgentMessage):
  if msg.type == "subscribe": ...
```

**Rule:** Escape-hatch types are never the answer for internal code. If you don't know the type, figure it out. If it's genuinely dynamic, validate at the boundary.

### 2. Silencing Compiler Diagnostics

Every language has directives to suppress type errors — `@ts-ignore`, `@ts-expect-error`, `@SuppressWarnings`, `// noinspection`, `#[allow(...)]`. These silence the compiler instead of fixing the problem.

```
// Bad: silencing type errors
// @ts-ignore
webSocket.send(data)

// @ts-expect-error — types are wrong but it works at runtime
result = provider.execute(command)
```

**Rule:** Fix the type error. If type definitions are wrong, correct them or create a declaration file with the right types. Suppression directives are never acceptable in new code.

### 3. Duplicated Types

Same concept redefined per layer — server, API, app — with identical fields copy-pasted.

```
// Bad: same concept redefined per layer
// server/types
Subscriber { id, name, status, pid }

// api/types
Subscriber { id, name, status, pid }

// app/types
Subscriber { id, name, status }
```

```
// Good: one canonical type, layer-specific views derived
Subscriber { id, name, status, pid }

AppSubscriber = Pick<Subscriber, "id" | "name" | "status">
```

**Rule:** One canonical type per concept. Derive views with subset operations (`Pick`, `Omit`, `Partial`, or language equivalent). Never redefine fields.

### 4. Loose String Types

A string that can only be one of a known set of values should not be a raw string. Typos compile fine.

```
// Bad: stringly-typed
function handleMessage(type, payload):
  if type == "subscribe": ...
  else if type == "command": ...

function setStatus(status):
  // "runing" (typo) compiles fine
```

```
// Good: constrained set
MessageType = "subscribe" | "command" | "heartbeat"

function handleMessage(type: MessageType, payload):
  // exhaustive matching is possible

SubscriberStatus = "active" | "inactive" | "suspended" | "pending"
```

**Rule:** If a value can only be one of a known set, encode that set in the type. Typos become compile errors.

### 5. Untyped Boundaries

Data entering the system — network responses, file I/O, user input, IPC — used without validation.

```
// Bad: network response used without validation
response = fetch("/api/subscribers")
subscribers = response.json()  // untyped
subscribers.forEach(renderSubscriber)
```

```
// Good: validate at boundary, then use typed data
response = fetch("/api/subscribers")
raw = response.json()
subscribers = schema.parse(raw)  // typed from here on
subscribers.forEach(renderSubscriber)
```

**Rule:** Every boundary where data enters your system must have schema validation. After validation, types flow automatically.

### 6. Complex Inline Object Types

Multi-property object shapes declared inline instead of given a name.

```
// Bad: object shape hidden in a local declaration
serviceDeclarations: Array<{ scriptName: string; port?: number }> = []

// Bad: complex inline parameter type
function startServices(
  declarations: Array<{ scriptName: string; port?: number; env?: Record<string, string> }>
)
```

```
// Good: name the domain shape
ServiceDeclaration = {
  scriptName: string
  port?: number
}

serviceDeclarations: ServiceDeclaration[] = []

function startServices(declarations: ServiceDeclaration[])
```

**Rule:** Don't put multi-property object shapes inline. Give the shape a named type close to where the concept belongs.

### 7. Positional Argument Lists

Can't tell what each argument means. Boolean parameters obscure intent.

```
// Bad: can't tell what each argument means
createAgent("claude", "my-agent", true, false, 30000, "full-access")

// Bad: boolean parameters
startAgent("my-agent", true, false, true)
```

```
// Good: object parameter — call site is self-documenting
createAgent({
  provider: "claude",
  name: "my-agent",
  detached: true,
  quiet: false,
  timeout: 30000,
  mode: "full-access",
})
```

**Rules:**
- **One positional** is fine when the function name names it (`findSubscriberById(id)`).
- **Two positionals** are fine when symmetry makes them obvious (`Math.max(a, b)`).
- **3+ parameters** → object. No exceptions.
- **Any boolean parameter** → object.
- **Any optional parameter** → object.
