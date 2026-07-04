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

(Data Science Dojo, ["Agentic Loops: From ReAct to Loop Engineering"](https://datasciencedojo.com/blog/agentic-loops-explained-from-react-to-loop-engineering-2026-guide/), 2026.)

## Real project cost benchmarks

From Anthropic's own harness engineering work (Prithvi Rajasekaran, Mar 2026):

| Task | Architecture | Time | Cost | Result |
|---|---|---|---|---|
| Retro game maker | Solo agent | 20 min | $9 | Broken core functionality |
| Retro game maker | Full harness (Planner + Generator + QA) | 6 hours | $200 | Fully playable, 16-feature spec, 10 sprints |
| Digital audio workstation | Simplified harness (no sprints) | 3h 50min | $124.70 | Working application |

The DAW cost breakdown: Planner $0.46 · Build phases $113.85 · QA phases $10.39.

**Key takeaway:** the 20× cost increase (solo → harness) on the game maker yielded
qualitatively different output — not incrementally better. Budget for this step-change
when reliability and completeness are non-negotiable.

## Token cost by loop pattern

Concrete benchmarks from operating named loop patterns (Cobus Greyling, [cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering), Jun 2026):

| Run type | Token cost |
|---|---|
| Noop pass (empty watchlist, early exit) | ~3,000–5,000 |
| Report-only triage run | ~50,000–80,000 |
| Action run (implementer + verifier) | ~200,000–250,000 |
| CI Sweeper at 5 min cadence, no early exit | ~5,000,000/day |

**The early exit rule:** every loop must check for work before doing any triage.
If the watchlist is empty, exit immediately at <5k tokens. Never run the full loop
body if there is nothing to act on.

Without early exit, a CI Sweeper running every 5 minutes against a green repo burns
~5M tokens per day on no-ops. The early exit rule converts it to ~3k tokens per pass.
This is not an optimisation — it is a correctness requirement for always-on loops.

See [Loop Patterns](34-loop-patterns.md) for the seven named loop patterns and their
typical token envelopes.

## Effort levels

| Level | Use when |
|---|---|
| `low` | File lookups, listing directories |
| `medium` | Routine edits, standard tasks |
| `high` | Refactors, debugging |
| `xhigh` | Complex coding tasks (Fable 5 / Opus 4.7+) |
| `max` | Multi-step problems requiring deep analysis |

### Reasoning effort is the dominant reliability lever — not tool access

A 90-run observational study (building the same spec'd app — a real-time retro board —
across multiple model generations, two harnesses, two effort levels, a testing tool, and
two design prompts; scored on a 14-criterion / 42-point rubric) found that **reasoning
budget, not extra tooling, is what buys first-try reliability**:

| Lever | Effect on *first-try-perfect* (all 14 criteria, zero corrective prompts) | Cost delta |
|---|---|---|
| Raise effort `high` → `xhigh` | **28% → 89%** first-try-perfect; ~5× fewer corrective prompts | **+9–29%** |
| Add a testing tool | No improvement in functional score *or* reliability (even on interface-visible criteria) | **+42–68%** |

The counterintuitive result: **checking mechanisms and tool access do not fix failures
whose root cause is weak reasoning.** When the model's reasoning is the bottleneck, spend
the marginal dollar on reasoning budget (or a stronger model) before adding testing tools
or checker passes — the effort bump is both cheaper and dramatically more effective. This
does not override the [verification](04-verification.md) mandate (an *independent* verifier
still catches what the maker cannot self-see); it says a *self*-run testing tool bolted
onto a weak-reasoning maker is a poor trade against simply raising effort.

([*Reasoning effort, not tool access, buys first-try reliability in agentic code generation*](https://arxiv.org/abs/2607.02436), arXiv, Jul 2026.)

## Handle result subtypes

```python
if message.subtype == "error_max_turns":
    # Resume the session with a higher limit
    resume_session(session_id, max_turns=60)
elif message.subtype == "error_max_budget_usd":
    alert("Budget exceeded — review and restart")
```

## Operational Kill / Pause / Slow-Down Thresholds

Define explicit decision rules for three escalation levels before deploying any production loop:

| Signal | Action | Threshold example |
|---|---|---|
| Budget overspend mid-period | **Slow down** — reduce cadence or skip non-urgent runs | Budget >80% consumed before week mid-point |
| High false-positive rate | **Slow down** — human reviews before loop re-runs | False positives >30% of runs in a 7-day window |
| Production incident or schema migration | **Pause** — halt loop until incident resolved | Any active Sev-1 or open migration PR |
| Two consecutive weeks of negative cost-to-value | **Kill** — decommission the loop | 14 days: every run costs more than the defects it catches |
| Consistent loop failures | **Kill** | Loop fails to complete successfully 3+ times per week for 2 weeks |
| Team disengagement | **Kill** | No human has read a loop report in 14 days |

These thresholds are deployment prerequisites, not optional monitoring. Define them before
the first production run — they cannot be calibrated after a runaway event.

([cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering), Jun 2026.)
