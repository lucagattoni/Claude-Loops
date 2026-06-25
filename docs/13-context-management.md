# Context Management

The context window is your most important resource. Performance degrades as it fills.

## Rules

- `/clear` between unrelated tasks — start each task with clean context
- `/compact` to summarize before starting a large new section
- Use subagents for investigation — their reads don't consume your context
- Never ask Claude to "explore the whole codebase" — scope narrowly
- After two failed corrections, `/clear` and write a better prompt

## Compaction shortcuts

```
/compact Focus on the API changes only
/compact Preserve: task objective, modified files, test results
```

## Context resets vs. compaction

Two strategies when a context window fills during a long task:

| Strategy | What it does | When to use |
|---|---|---|
| **`/compact`** | Summarizes earlier content in-place | When continuity matters and the model handles large context well |
| **Context reset** | Clears the window entirely; passes state via structured handoff artifacts | When the model shows "context anxiety" — degraded reasoning caused by accumulated history |

**Context anxiety** is the observable degradation that occurs when a model's earlier
mistakes, reversals, and dead ends remain in context: subsequent reasoning is anchored
to that accumulated wreckage rather than the current goal.

Findings from Anthropic engineering (Prithvi Rajasekaran, Mar 2026):
- Claude Sonnet 4.5 exhibited significant context anxiety — resets were essential for reliable output
- Claude Opus 4.6 largely eliminated this behaviour — compaction is often sufficient

**Practical rule:** If you observe a model re-litigating earlier decisions or
drifting from the original goal across turns, switch from compaction to resets.
Encode the learnings externally first (see [Experience Encoding](27-loop-contract.md)),
then start the next iteration from a clean window.

## Input Governance Pipeline

Before the model sees context, a governance pipeline can pre-process it to prevent
bloat from accumulating in the first place. Run these steps at session or turn start:

| Step | What it does |
|---|---|
| **Prefetch** | Load only the files and state actually needed for this turn |
| **Snip** | Truncate or summarise oversized inputs before they enter context |
| **Microcompact** | Compress completed subtask summaries into one-line records |
| **Collapse** | Merge redundant assistant-turn repetitions |
| **Autocompact** | Apply `/compact` automatically when context exceeds a threshold |

"Clean the site first, then execute." Proactive governance keeps context lean
throughout the session; reactive compaction triggered when the window is full is
more expensive and disruptive.

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

## Reactive Compact — Emergency Mid-Loop Compaction

Distinct from planned `/compact`: a reactive compact fires when context pressure
becomes critical mid-loop. Treat it as a failure-prone operation with its own
defensive budgeting:

- **Reserve output tokens**: keep ≥20,000 tokens free for the compact summary;
  compaction that runs out of output space produces a truncated summary that is
  worse than no summary
- **Early-warning buffer**: trigger at ≥13,000 tokens remaining — not when the
  window is already full
- **Circuit breaker**: if compaction fails 3 consecutive times, halt and escalate
  rather than continuing with degraded context

```
context usage > (window − 13,000 tokens)
  → fire reactive compact
  → verify summary completeness
  → if 3 consecutive failures → halt + escalate to human
```

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

## What eats context fastest

- Large file reads (every file read accumulates)
- Verbose bash output (`--verbose` on for dev, off for production loops)
- Long CLAUDE.md files
- Many MCP tool schemas (use MCP tool search to defer loading)
