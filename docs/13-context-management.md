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

## What eats context fastest

- Large file reads (every file read accumulates)
- Verbose bash output (`--verbose` on for dev, off for production loops)
- Long CLAUDE.md files
- Many MCP tool schemas (use MCP tool search to defer loading)
