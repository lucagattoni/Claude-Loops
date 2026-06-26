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

## Two Lenses on Loop Primitives

A loop can be decomposed two complementary ways. Keep both in mind — they answer
different questions.

| Lens | Primitives | Answers |
|---|---|---|
| **Functional** (what the loop *does*) | Execution · Verification · Orchestration · Observability | "Which capability failed?" |
| **Mechanical** (what the loop is *built from*) | Automations · Worktrees · Skills · Connectors · Sub-agents · Memory | "Which component do I configure?" |

The functional lens names the four jobs every non-trivial loop performs:

- **Execution** — doing the work (the Act step above)
- **Verification** — checking the work before it ships ([Verification](04-verification.md))
- **Orchestration** — coordinating multiple agents/steps ([Subagents](07-subagents.md), [Fan-Out](10-fan-out.md))
- **Observability** — being able to see *what the loop did and why*, so a failure can be
  attributed to the right layer. Without it you cannot tell whether execution,
  verification, or orchestration broke — you only see that the loop failed.

> "Loop engineering is the right frame — execution, verification, and orchestration are
> the primitives." ([@miltonheyan](https://x.com/miltonheyan/status/2070432513307357388), Jun 2026) —
> with **observability as the prerequisite fourth**: the others are undiagnosable without it.

The mechanical lens is the [Six Building Blocks](03-building-blocks.md) you actually
configure to realise those functions. Observability in practice means run logs, the
cross-run memory file ([Loop Contract](27-loop-contract.md#cross-run-memory-persistence)),
and behavioural eval harnesses that score real runs across multiple dimensions
([travisbreaks/coding-agent-evals](https://github.com/travisbreaks/coding-agent-evals), Jun 2026).

## Loop Termination

A session ends at one of these **runtime** signals. They are the mechanical events that
enforce the design-time [Stop Condition Taxonomy](27-loop-contract.md#stop-condition-taxonomy)
(completion-check / budget / max-iterations / no-progress):

- Claude produces a text-only response (no tool calls) — `success` (enforces a completion check)
- `max_turns` is reached — `error_max_turns` (enforces budget / max-iteration stops)
- `max_budget_usd` is exceeded — `error_max_budget_usd` (enforces the budget stop)
- A Stop hook rejects the result — loop re-enters (a completion check that has not yet passed)
- An unrecoverable error occurs — `error_during_execution`
