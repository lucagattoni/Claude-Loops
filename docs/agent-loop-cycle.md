# The Core Agent Loop Cycle

Every Claude Code session — whether interactive or headless — follows this cycle:

```
Observe → Reason → Plan → Act (tool calls) → Verify → repeat
```

Claude is **not** a chatbot that waits for input between turns. Within a single
session it chains tool calls autonomously: read files, run commands, edit code, run
tests, read results, iterate. Each full round-trip (Claude output → tool execution →
result back to Claude) is one **turn**.

## Alternative Framing: Universal Agent Thesis

Cobus Greyling proposes a four-step cycle that generalises across all agent tooling
and domains:

```
Perceive → Reason → Act → Learn → repeat
```

The distinguishing fourth step — **Learn** — means the agent updates its own state
or strategy based on feedback from previous actions. In Claude Code terms, "Learn"
maps to reading test output, reviewing prior commits, or updating `PROGRESS.md`
before the next iteration. An agent that only loops `Perceive → Reason → Act`
without incorporating feedback is executing, not improving.

## Loop Termination

The loop ends when:
- Claude produces a text-only response (no tool calls) — `success`
- `max_turns` is reached — `error_max_turns`
- `max_budget_usd` is exceeded — `error_max_budget_usd`
- A Stop hook rejects the result — loop re-enters
- An unrecoverable error occurs — `error_during_execution`
