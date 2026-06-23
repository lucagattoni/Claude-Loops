# Cost & Turn Control

Uncapped loops are expensive and can run indefinitely on open-ended prompts. Always
set limits for unattended runs.

```python
# Agent SDK (Python)
from claude_agent_sdk import query, ClaudeAgentOptions

async for message in query(
    prompt="refactor the auth module",
    options=ClaudeAgentOptions(
        max_turns=30,          # hard turn cap
        max_budget_usd=2.00,   # hard cost cap
        effort="high",         # reasoning depth: low|medium|high|xhigh|max
        model="claude-sonnet-4-6",
    )
):
    ...
```

## Token consumption benchmarks

Real-world multipliers relative to standard single-turn chat:

| Mode | Approximate token multiplier |
|---|---|
| Single agent | ~4× |
| Multi-agent | ~15× |

Set `--max-budget-usd` conservatively on first deployment (e.g. $2–5 for a single-agent
loop), then raise after observing actual consumption on real runs.

(Data Science Dojo, "Agentic Loops: From ReAct to Loop Engineering", 2026.)

## Effort levels

| Level | Use when |
|---|---|
| `low` | File lookups, listing directories |
| `medium` | Routine edits, standard tasks |
| `high` | Refactors, debugging |
| `xhigh` | Complex coding tasks (Fable 5 / Opus 4.7+) |
| `max` | Multi-step problems requiring deep analysis |

## Handle result subtypes

```python
if message.subtype == "error_max_turns":
    # Resume the session with a higher limit
    resume_session(session_id, max_turns=60)
elif message.subtype == "error_max_budget_usd":
    alert("Budget exceeded — review and restart")
```
