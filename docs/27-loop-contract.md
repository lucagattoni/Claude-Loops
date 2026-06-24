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

## Job-Description Framing

Rather than writing a loop prompt as a technical specification, write it as an
employee onboarding document. A new employee needs:

| Onboarding element | Loop Contract property |
|---|---|
| Job title and scope | TRIGGER + SCOPE |
| Output deliverables | ACTION + REPORT |
| Working hours / frequency | TRIGGER schedule |
| Escalation path | Human-in-the-Loop gate — when to ask a human |
| Performance standard | STOP condition |
| Budget authority | BUDGET cap |

The framing shift matters because onboarding documents describe *intent* and
*judgment boundaries* — exactly what a loop needs to act autonomously without
constant supervision. See [Human-in-the-Loop Escalation](14-human-in-the-loop.md).

(Claire Vo, Lenny's Newsletter, "How I AI: How to write AI agent loops", Jun 2026.)

## Event Modeling — Task Decomposition for Loop Contracts

Event Modeling (Martin Dilger, Jun 2026) applies the Loop Contract to individual
feature slices rather than to the whole task:

1. **Slice** the work into discrete functionality units — each slice has clear status
   transitions: `Planned → In Progress → Blocked → Done`
2. **Assign** each slice to one agent invocation — the slice is the unit of work for
   one context window; prevents confusion between tasks
3. **Subscribe** agents to board changes so they automatically claim available slices
4. **Prevent concurrency** — once a slice is `In Progress`, no second agent can claim it

The critical rule: **never argue with an agent mid-task.** Corrections accumulate as
"decision noise" — the agent does not learn from them, it just agrees and carries the
confusion forward. Instead:

```
1. Define tasks clearly before launching the agent
2. Execute one slice per clean context window
3. Record learnings in GOAL.md / CLAUDE.md after completion
4. Clear context completely
5. Start the next slice from a clean window with recorded learnings
```

> "Clean iterations with recorded learnings will outperform long, polluted
> conversations every single time." — Martin Dilger, Jun 2026

## Governed Cross-Session Learning

Experience Encoding (above) captures per-iteration learning. Cross-session learning
accumulates patterns across 5+ sessions and promotes them to standing rules:

| Skill | What it does | When to use |
|---|---|---|
| `/evolve` | Analyses session transcripts, extracts recurring patterns, drafts rule proposals | After ≥5 completed sessions on a loop |
| `/reconcile` | Converts extracted proposals into reviewable `.claude/rules/` files | Before any pattern is applied standing |

**Implementation note:** `/evolve` and `/reconcile` are not built-in Claude Code commands.
They are implemented as Claude Code [Skills](06-skills.md) — on-demand workflows
defined in `.claude/skills/`. To adopt this pattern, create `evolve.md` and `reconcile.md`
as skills in your project.

**Critical constraint: nothing auto-applies.** `/evolve` produces a draft; `/reconcile`
produces a reviewable file. The human reviews and approves before any pattern becomes
a standing rule. This prevents the loop from silently encoding bad habits as governance.

The review gate for each proposal:
1. Does this pattern actually improve outcomes, or just describe what happened?
2. Does it conflict with any existing rule?
3. Does it generalise correctly, or is it specific to one anomalous session?

(session-orchestrator — Kanevry/session-orchestrator, Jun 2026.)

## Relationship to Goal Engineering

When a loop's STOP condition is deterministic and the task is non-recurring, the
loop degenerates into a **Goal** — a bounded task with a single verifiable completion
state. The [Goal Engineering](30-goal-engineering.md) doc covers the four Goal
Primitives and the GOAL.md persistent state file in detail.

## Relationship to the Factory Model

The Loop Contract is the specification document for a factory model workflow. Just
as a factory floor has defined inputs, processes, and quality gates, the contract
defines what the loop accepts, does, and produces. See [The Factory Model](26-factory-model.md).
