# The Loop Contract

Before launching any loop, define six properties explicitly. A loop without a
complete contract is guaranteed to under-deliver or over-spend.

(Source: explainx.ai, "Loop Engineering: How to Design Coding Agent Loops That Run While You Sleep", Jun 2026.)

## The Six Properties

| Property | Question it answers | Example |
|---|---|---|
| **TRIGGER** | What starts this loop? | PR opened, file changed, daily 08:00 UTC |
| **SCOPE** | What can the loop touch? | Only files in `src/`; read-only on `main` |
| **ACTION** | What does it do when triggered? | Run tests, summarise failures, open a GitHub issue |
| **BUDGET** | What are the hard caps? | `--max-turns 50 --max-budget-usd 2.00` |
| **STOP** | When does it declare success? | All tests pass, or issue is open with failure list |
| **REPORT** | What does it say when done? | Post a PR comment with pass/fail summary |

A loop that lacks BUDGET or STOP is not a loop — it is a runaway process.

## Real Cost Data

Uber engineers burned their **entire annual AI budget in 4 months** before a
$1,500/month per-tool cap was imposed. The Loop Contract's BUDGET property exists
to prevent exactly this. See also [Cost & Turn Control](11-cost-control.md).

## The Anchor File Pattern

The Loop Contract can be materialised as four files in the repo:

| File | Purpose |
|---|---|
| `VISION.md` | High-level goal — what success looks like at the end |
| `CLAUDE.md` | Rules — what the loop can and cannot do |
| `AGENTS.md` | Roles — which agent does what in multi-agent setups |
| `PROMPT.md` | Task — the current specific work unit |

The loop reads all four at startup. Updating `PROMPT.md` re-tasks the loop without
changing its rules or goal.

## Relationship to the Factory Model

The Loop Contract is the specification document for a factory model workflow. Just
as a factory floor has defined inputs, processes, and quality gates, the contract
defines what the loop accepts, does, and produces. See [The Factory Model](26-factory-model.md).
