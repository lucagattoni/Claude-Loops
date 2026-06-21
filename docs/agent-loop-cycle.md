# The Core Agent Loop Cycle

Every Claude Code session — whether interactive or headless — follows this cycle:

```
Observe → Reason → Plan → Act (tool calls) → Verify → repeat
```

Claude is **not** a chatbot that waits for input between turns. Within a single
session it chains tool calls autonomously: read files, run commands, edit code, run
tests, read results, iterate. Each full round-trip (Claude output → tool execution →
result back to Claude) is one **turn**.

The loop ends when:
- Claude produces a text-only response (no tool calls) — `success`
- `max_turns` is reached — `error_max_turns`
- `max_budget_usd` is exceeded — `error_max_budget_usd`
- A Stop hook rejects the result — loop re-enters
- An unrecoverable error occurs — `error_during_execution`
