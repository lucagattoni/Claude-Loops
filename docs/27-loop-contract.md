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

> "If you can't say what done looks like, you don't have a loop. You have a wish." — Sabrina Ramonov, Jun 2026

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

## Two Quality Gates

Before a loop iteration continues or launches, apply two explicit checkpoints:

| Gate | Question | When |
|---|---|---|
| **Gate 1 — Evidence completeness** | Is the output backed by objective evidence (test results, logs, metrics)? | Before allowing the loop to continue to the next iteration |
| **Gate 2 — Stopping condition clarity** | Can you state exactly what "done" looks like before the loop starts? | Before launching the loop at all |

Gate 2 maps directly to the STOP property in the Loop Contract above. Gate 1 is
what enforces it at runtime — without objective evidence, the loop cannot know
whether STOP has been met.

(Wooheum Xin, "Stop Writing Prompts: The True Nature of Loop Engineering", Zenn, Jun 2026.)

## Experience Encoding — The Loop's Learning Step

After each iteration completes and before context is cleared, encode what was learned
back into the project's persistent knowledge:

1. **Rules** — add a new CLAUDE.md rule if a mistake was made that a rule would prevent
2. **Templates** — update or create a skill in `.claude/skills/` if a reusable procedure emerged
3. **Negative lessons** — document anti-patterns encountered so the next iteration avoids them
4. **PROGRESS.md** — mark the completed task and note any blockers or discoveries

This step closes the learning loop: each iteration makes the next one smarter, not
just incrementally further along. The cycle is:

```
Goal Contract → Execution → Evidence Gate → Stopping Condition → Experience Encoding → next cycle
```

Skipping Experience Encoding means the loop accumulates runtime progress but no
institutional knowledge. The skills file stays empty; the same mistakes recur.

## Relationship to the Factory Model

The Loop Contract is the specification document for a factory model workflow. Just
as a factory floor has defined inputs, processes, and quality gates, the contract
defines what the loop accepts, does, and produces. See [The Factory Model](26-factory-model.md).
