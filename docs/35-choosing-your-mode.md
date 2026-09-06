# Interactive or Autonomous? Choosing Your Mode

This knowledge base has two parts, and this page decides which one you need.

- **[Part I — Loop Engineering](27-loop-contract.md)** is about designing a system that prompts an
  agent *for* you: it fires on a trigger, does work, verifies it, and stops. You are not at the
  keyboard.
- **[Part II — Developing with Claude Code](36-development-workflow.md)** is about you and Claude
  Code building software together, iteratively, with you in the loop.

Both are real. They are not the same discipline, and the second is the more common one.

---

## Start from the honest default

For **building software**, the default is interactive. Three independent sources say so.

> Effective coding-agent use is **"a complex, highly iterative process"** rather than purely
> autonomous long-horizon work; most practical utility comes from human intervention with
> **"high-skill judgement"**. *(Bolded fragments verbatim; the connecting prose is a summary.)*
>
> — Andrew Ng, [*The AI Engineering Skills Map In Detail — Using Coding Agents*](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map-in-detail-using-coding-agents/), 2026-09-04

> "Most coding tasks involve fewer truly parallelizable tasks than research, and LLM agents are not
> yet great at coordinating and delegating to other agents in real time."
>
> — Anthropic, [*How we built our multi-agent research system*](https://www.anthropic.com/engineering/multi-agent-research-system), 2025-06-13

And measured on a real project: over six weeks of building a shipped tool with Claude Code, the
work that actually moved product code was interactive; the autonomous fan-outs were used for
*review and audit*, not for authoring. See the case study in
[Session Architecture](37-session-architecture.md#case-study-pinakes).

This is not an argument against loops. It is an argument about **where they pay**.

---

## The three tests

Before you build a loop, it must pass all three. If it fails any one, stay interactive.

### 1. Can you write "done" as a command that exits 0?

Not a description of done. A command.

```bash
pytest -q && ruff check . && ./scripts/verify-migration.sh
```

If "done" is *"the refactor looks clean"* or *"the docs read well"*, you do not have a stopping
condition — you have a preference, and a loop cannot check it. This is the single most common
reason loops fail; see [Verification](04-verification.md) and the
[stop-condition taxonomy](27-loop-contract.md).

### 2. Will you run it more than about five times?

A loop costs design, a verifier, a budget cap, and ongoing maintenance as the codebase moves under
it. A one-off task does not amortise that. Recurring work does — triage, dependency bumps, docs
sync, digest generation, CI sweeps. The [Loop Patterns Catalog](34-loop-patterns.md) is a list of
work that has already cleared this bar.

### 3. Is the blast radius acceptable with nobody watching?

Ask what one bad unattended run costs. A loop that opens a PR is cheap to be wrong. A loop that
pushes to `main`, mutates production data, or spends without a ceiling is not. Ramp autonomy
rather than granting it — report-only, then propose, then write behind a gate. See
[Permissions](08-permissions.md) and [Human-in-the-Loop](14-human-in-the-loop.md).

---

## The decision table

| Property of the task | Interactive | Autonomous loop |
|---|---|---|
| "Done" expressible as a passing command | helpful | **required** |
| Novel, exploratory, or design-heavy | ✅ | ✗ |
| Repetitive and well-specified | ✗ | ✅ |
| You need to see intermediate state and steer | ✅ | ✗ |
| Cost of one wrong run | can be high | must be low |
| Runs while you are asleep / away | ✗ | ✅ |
| Requires taste, product judgement, or a decision only you can make | ✅ | ✗ |
| Decomposes into independent units | either | helps a lot |

**A task that is exploratory *and* recurring** — "keep an eye on our flaky tests" — usually splits:
the *detection* is a loop, the *fix* is interactive.

---

## The middle ground is where most work actually lives

The choice is not binary. Claude Code has several primitives that are autonomous **within a session
you are supervising** — the agent runs unattended for minutes to hours, but you are still there.

| Primitive | What it does | You are… |
|---|---|---|
| [Plan mode](15-explore-plan-implement.md) | Explore and design with edits disabled | at the keyboard |
| `/goal` | Runs until an independent per-turn evaluator says the criterion is met | supervising |
| [Subagents](07-subagents.md) | A side task in its own context, reporting back | supervising |
| [Dynamic workflows](39-dynamic-workflows.md) | Scripted fan-out over many agents, in background | supervising |
| [Agent teams](38-agent-teams.md) | Several teammates coordinating on a shared task list | supervising |
| `/loop` | Recurs on an interval — but needs a session open | nearby |
| [Routines](28-routines.md) / cron | Fires with no session at all | absent |

**Most productive Claude Code work sits in the middle rows.** If you are reaching for a scheduled
unattended loop for something you will do twice, you have skipped the middle.

---

## The compound-probability argument, correctly scoped

[The Paradigm Shift](01-paradigm-shift.md) makes the case that a task needing 10 sequential correct
decisions at 90% accuracy each succeeds end-to-end only 35% of the time (0.9¹⁰ ≈ 0.35), so
single-shot invocations cannot be reliable.

That argument is sound, and it is an argument for a **correction loop** — an observe → act →
verify → retry cycle. It is *not*, by itself, an argument for an **unattended** one.

**You are a correction loop.** When you read the diff, run the tests, and say "no, do it this way",
the cycle is closing — with a verifier of unmatched quality. The real question loop engineering
asks is narrower and more honest:

> Should I replace *myself* in this correction loop, for *this* task?

The answer is yes when your contribution to the cycle is mechanical (running the tests, noticing
the type error, re-reading the checklist) and no when it is judgement.

---

## Count cost per unit of work, not tokens

> "Setting up competitions to see who can use the most tokens (as some companies have done) takes
> the idea of encouraging token burn beyond what is productive."
>
> — Andrew Ng, [*What Comes After Tokenmaxxing?*](https://www.deeplearning.ai/the-batch/what-comes-after-tokenmaxxing-how-to-avoid-getting-locked-in-to-just-one-ai-provider/), 2026-08-07

Ng's replacement practice is to **instrument cost per unit of work** — he cites knowing that one of
his applications costs about \$0.50 per query and another about \$3.00 per 10-minute conversation.

The loop-engineering version of that number is *cost per closed unit*: per triaged issue, per
merged PR, per digest published. A loop whose per-unit cost you cannot state is a loop you cannot
decide about. `/usage` now reports a per-loop breakdown — run count, total tokens, tokens per run,
last run — so this is measurable rather than estimated. See [Cost & Turn Control](11-cost-control.md).

**The trap this catches:** autonomous loops make token spend invisible, because nobody is watching
the run. An interactive session that costs more per unit but converges in three turns can be the
cheaper choice.

---

## When the answer is "build a harness"

If several loops pass the three tests, you stop building loops one at a time and build the thing
that builds them — a harness. That is [Part I](24-harness-patterns.md)'s subject, and
[ClaudeWarp](https://github.com/lucagattoni/Claude-Warp) is a worked reference implementation on
top of Claude Code: durable state in git, budget caps on every scaffold, independent checkers, and
a `/claude-warp-sync` skill built to **retire its own components** as Claude Code absorbs them
natively.

That last property is the one to copy. A harness should be designed to shrink — though *designed
to* is the honest phrasing: across the two sync runs that project has recorded, the mechanism
retired **nothing**. See [Harness Patterns § When to Remove
Harness](24-harness-patterns.md#when-to-remove-harness) for what that measurement means, and
[the first-party disclosure](36-development-workflow.md#a-worked-reference-implementation) —
ClaudeWarp shares this KB's maintainer.

---

## Related

- [The Development Workflow](36-development-workflow.md) — the interactive cycle, end to end
- [Session Architecture](37-session-architecture.md) — one session or many, once you are in Part II
- [The Loop Contract](27-loop-contract.md) — how to specify a loop, once you have decided to build one
- [Loop Patterns Catalog](34-loop-patterns.md) — work that already passes the three tests
- [Loop Maturity Model](20-loop-maturity-model.md) — the progression, if you are going all the way
