# Structure

Structural problems from code generated without understanding the architecture. Both extremes: too much repetition (copy-paste) and too much abstraction (DRY obsession). Functions should not exist for a single call site — that's indirection, not abstraction.

## Patterns

### 1. Copy-Paste Duplication

Same logic implemented multiple times with minor variations.

```
// Bad: duplicated status logic across three files
// in agent-list
function getStatusColor(agent) {
  if (agent.status === "running") return "green"
  if (agent.status === "stopped") return "gray"
  if (agent.status === "error") return "red"
  return "gray"
}

// in agent-detail
function statusToColor(status) {
  switch (status) {
    case "running": return "#00ff00"
    case "stopped": return "#888888"
    case "error": return "#ff0000"
    default: return "#888888"
  }
}
```

```
// Good: one source of truth
STATUS_COLOR = {
  running: "green",
  stopped: "gray",
  error: "red"
}

function statusColor(status):
  return STATUS_COLOR[status]
```

**Smell:** The same discriminator is checked in more than two places. Centralize.

### 2. Premature Abstraction

Extracting a "reusable" abstraction for code used exactly once.

```
// Bad: single-use helper that adds indirection
function createAgentStatusChecker(agent):
  return {
    isRunning: () => agent.status === "running",
    isStopped: () => agent.status === "stopped"
  }

checker = createAgentStatusChecker(agent)
if (checker.isRunning()) { ... }

// Bad: factory function for a simple object
function createNotificationPayload(title, body):
  return { title, body }

// Bad: trivial branch extracted into a helper
function workspaceScriptType(serviceScript):
  return serviceScript ? "service" : "script"
scriptType = workspaceScriptType(serviceScript)  // used once
```

```
// Good: inline the single-use code
if (agent.status === "running") { ... }

payload = { title, body }

scriptType = serviceScript ? "service" : "script"
```

**Rule:** No function should exist if it's used only once — that makes the code difficult to read. A function called once is indirection, not abstraction. The only exception is deep nesting that would otherwise reduce readability, but even then, keep logic at the same level as much as possible.

### 3. God Functions

Functions that do too many things — fetching, validating, transforming, persisting, notifying all in one.

```
// Bad: 80-line function doing everything
function handleMessage(raw):
  message = parse(raw)
  if (!message.type):
    send({ error: "Missing type" })
    return
  if (message.type === "subscribe"):
    // 20 lines of subscription logic
  else if (message.type === "command"):
    // 25 lines of command logic
  else if (message.type === "heartbeat"):
    // heartbeat logic
  // Update metrics, send ack, log
```

```
// Good: dispatch to focused handlers
function handleMessage(raw):
  parsed = schema.validate(parse(raw))
  if (!parsed.success):
    send({ error: "Invalid message" })
    return

  handlers = {
    subscribe: handleSubscribe,
    command: handleCommand,
    heartbeat: handleHeartbeat
  }

  handler = handlers[parsed.data.type]
  handler(parsed.data)
```

A big function is fine if the internal steps are extracted into named internal functions. The sin is not length — it's mixing concerns at the same level of abstraction. A 100-line function that calls 5 well-named helpers is clearer than a 30-line function that inlines everything.

**Rule:** If a function has more than 3 levels of nesting or handles more than one concern, split it. Each function answers one question. Keep logic at the same level — don't extract functions just to reduce line count.

### 4. God Files

Files that accumulate unrelated functionality.

```
// Bad: utils with 500 lines of unrelated helpers
formatDate(date)
parseAgentId(raw)
calculateRetryDelay(attempt)
truncateString(str, len)
isValidWebSocketUrl(url)
```

**Smells:**
- A file named `utils`, `helpers`, or `common` with more than 5 exports
- A file over 400 lines
- Functions in a file that share no imports or types

**Rule:** Organize by domain, not by technical role. `formatDate` belongs near date-related code, not in a generic utils file.
