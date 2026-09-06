# Goal Engineering

> Loops discover work. Goals finish it.

A **goal** is a bounded autonomous task with a defined completion state. Unlike a
loop (which recurs on a schedule or event), a goal runs once and terminates when
a verifiable criterion is met.

(Cobus Greyling, ["Goal Engineering"](https://cobusgreyling.substack.com/p/goal-engineering), Substack, Jun 2026.)

> **Scope note:** this page describes Cobus Greyling's *goal engineering* reference
> implementation, built for [xAI's Grok Build CLI `/goal`](https://github.com/cobusgreyling/goal-engineering)
> — not Claude Code's own `/goal`. Claude Code ships a native
> [`/goal` command](https://code.claude.com/docs/en/goal) (since v2.1.139) with a different
> mechanism: a small fast model (Haiku by default) evaluates a plain-language completion
> condition after every turn and returns *Not yet met*, *Met*, or *Impossible*. There is no
> G0–G3 score, no required `GOAL.md`, and no canonical pattern library in the built-in
> version. Treat the GOAL.md / G0–G3 / pattern discipline below as an optional practice you
> layer on top of Claude Code's `/goal`, not as how it behaves out of the box.

## Goals vs. Loops

Use this decision framework before designing a task:

```
Do you know what "done" looks like?
├── No  → clarify the objective first (you don't have a loop or a goal, you have a wish)
└── Yes → Is the work recurring on a schedule?
    ├── Yes → design a Loop
    └── No  → design a Goal
```

| Property | Loop | Goal |
|---|---|---|
| Trigger | Schedule or event | Single invocation |
| Termination | Runs until stopped | Stops when verifiable criterion is met |
| State | Progress tracked across iterations | State tracked in GOAL.md |
| Primary risk | Runaway cost without stop condition | Goal mirage (plausible-looking partial output) |

Production systems combine both: a cron loop discovers work and spawns Goals to
finish discrete units of it.

## The Four Goal Primitives

Every well-formed goal requires four components:

### 1. Objective
A single bounded statement with verifiable completion criteria — not a vague directive.

```
Bad:  "Improve the auth module"
Good: "Migrate to lib/auth/v2; done when all tests in /auth pass,
       zero legacy/auth imports remain, and GOAL.md checklist is complete"
```

The objective must be testable by the Verifier.

### 2. Verifier
An independent validation mechanism — tests, a subagent reviewer, a CI check.
The agent that wrote the code is a poor judge of its own work; the Verifier must
be separate. (See [Verification](04-verification.md) and [DOER/CHECKER](07-subagents.md).)

### 3. State — GOAL.md
A persistent external memory file the agent reads at the start of every context
window and writes to at meaningful milestones. GOAL.md contains:
- Objective (verbatim)
- Done conditions (checklist)
- Guardrails (what the goal must not touch)
- Execution log (what has been tried, discovered, completed)

GOAL.md is the solution to the context reset problem: when the agent's context is
cleared or compacted, GOAL.md preserves the goal's history and prevents re-doing
completed work or forgetting discovered constraints. Use an `update_goal` tool call
(or a simple file write) at meaningful milestones rather than after every micro-step.

### 4. Budget
Turn caps, token limits, and kill switches — the same hard stops as a loop.
A goal without a budget is a runaway process with a polished objective.

See [Loop Contract](27-loop-contract.md) for the full BUDGET property.

## GOAL.md Schema

A minimal GOAL.md for a well-formed goal:

```markdown
# Goal: <name>

## Objective
<One bounded, verifiable statement of what done looks like.>

## Done conditions
- [ ] <Condition 1 — machine-checkable>
- [ ] <Condition 2 — machine-checkable>

## Guardrails
- Must not touch: <list restricted paths or systems>
- Budget: --max-turns N --max-budget-usd $M

## Execution log
<!-- Agent writes here at each milestone -->
- [YYYY-MM-DD HH:MM] <What was attempted / discovered / completed>
```

**Write rules:** update the log at meaningful milestones (not every micro-step); check Done conditions before each write; never delete log entries. This file is the recovery mechanism — it must be self-explanatory to a fresh agent starting mid-goal.

([cobusgreyling/goal-engineering](https://github.com/cobusgreyling/goal-engineering) reference implementation, Jun 2026.)

## Six Canonical Goal Patterns

Reference patterns for common goal types ([cobusgreyling/goal-engineering](https://github.com/cobusgreyling/goal-engineering), Jun 2026):

| Pattern | Objective | Natural Verifier |
|---|---|---|
| **Tests Green** | All tests in \<scope\> pass | CI exit code |
| **Migrate Module** | \<module\> migrated; zero legacy imports remain | grep for old import paths |
| **Fix Bug** | \<issue #N\> closed; regression test present | Test suite + issue state |
| **Refactor Safely** | Behavior-preserving refactor complete; no new test failures | Test suite + diff line count |
| **Implement Feature** | Scoped feature complete; acceptance criteria hold | Acceptance checklist + test suite |
| **Coverage Target** | Test coverage raised to \<threshold\>% | Coverage report exit code |

Use these as starting points — always replace the objective with a concrete bounded statement before launching.

## G0–G3 Goal Readiness Scoring

Before launching a goal, check the Four Primitives are all in place — a concrete verifiable
objective, a verifier that is not the implementer, a GOAL.md the agent can read and write,
and an explicit budget/deny list. Readiness itself is scored by the auditor
(`npx @cobusgreyling/goal-audit . --suggest`), which computes a 0–100 score from weighted
signals — GOAL.md, skills, verifier, tests, CI, budget and run-log freshness — and buckets it:

| Level | Score | Meaning |
|---|---|---|
| **G0** | < 40 | Ad hoc `/goal` usage |
| **G1** | 40–59 | GOAL.md + assisted goals |
| **G2** | 60–79 | Verifier + test gates |
| **G3** | 80+ | CI, budget, run log |

([cobusgreyling/goal-engineering](https://github.com/cobusgreyling/goal-engineering), Jun 2026.)

## Catching an underspecified goal before it propagates

The readiness score above asks whether the *scaffolding* is in place — a `GOAL.md`, a verifier, a
budget. It does not ask whether the **objective itself is unambiguous**, and that is the failure
this KB kept naming without a mechanism: once implementation, review and deploy are all automated,
underspecified input becomes the dominant bottleneck, because every downstream stage faithfully
executes the wrong thing. Catching bad *output* is the expensive way to find out.

Four 2026 results supply the missing mechanism. Together they answer *what to check*, *who checks
it*, and — the surprising one — *when checking still helps*.

**The gate: a separate agent that can halt the implementer.** The strongest coding-specific result
decouples detection from execution: a Main Agent with the usual edit/execute tools, and a separate
**Intent Agent** that watches the state history and fires a single binary decision when the
instruction or repo context is missing information. On an **underspecified variant of SWE-bench
Verified** the scaffold reaches a **69.40% resolve rate**, *"significantly outperforming a standard
single-agent setup and closing the performance gap with agents operating on fully specified
instructions."* It also *"exhibits well-calibrated information-seeking behavior, conserving queries
on simple tasks while proactively seeking information on more complex issues"* — the property that
makes an ambiguity gate survivable rather than a nag.
([arXiv 2603.26233](https://arxiv.org/abs/2603.26233), Edwards & Schuster, Mar 2026.)

The transferable shape is the separation, not the paper's specific scaffold: **the thing that
decides "this is too vague to build" must not be the thing that wants to start building.** That is
the same maker/checker independence [Verification](04-verification.md) argues for, moved to the
front of the loop.

**The policy: ask only when the question is worth its cost.** A clarifying-question gate that fires
constantly gets disabled. SAGE-Agent formalises the decision over tool parameters and their domains,
separating *specification* uncertainty (what the user wants) from *model* uncertainty (what the LLM
predicts), and scores each candidate question by **Expected Value of Perfect Information** against a
redundancy cost — reporting *"7-39% higher coverage on ambiguous tasks"* while asking materially
fewer questions.
([arXiv 2511.08798](https://arxiv.org/abs/2511.08798), Suri et al., Nov 2025, rev. Apr 2026.)

**The timing, which is the counterintuitive part.** A forced-injection study — **84 task variants,
6,000+ runs**, four frontier models, clarifications injected at controlled points in the trajectory
— found that *"earlier is always better"* is wrong, and that the decay depends on **what** is
missing:

| Missing information | How long clarification retains value |
|---|---|
| **Goal** | *"loses nearly all value after 10% of execution"* (pass@3 drops from 0.78 to baseline) |
| **Input** | *"retains value through roughly 50%"* |
| **Any type, past mid-trajectory** | *"degrades performance below never asking at all"* |

That last row is the one to design against: **a late clarification is worse than none.** An agent
that asks at 70% has already built on the wrong assumption, and the question now costs a turn and
buys a contradiction. The same study found *"no current frontier model asks within the empirically
optimal window,"* with **52% of sessions over-asking** and others never asking at all — so this is
not a behaviour to expect for free.
([arXiv 2605.07937](https://arxiv.org/abs/2605.07937), May 2026.)

**Prior art outside agents, worth knowing.** Requirements engineering has run this gate on humans
for years: an in-context-learning classifier labels each requirement ambiguous/unambiguous **with a
mandatory rationale**, before the spec reaches design or implementation — validated on real
industrial requirements with two named partners. The mandatory-explanation part is the transferable
bit: a gate that says *"ambiguous"* without saying *why* cannot be acted on.
([Bashir et al., ICSME 2025 Industry Track](https://ieeexplore.ieee.org/document/11185947/).)

**What this means for a loop contract.** Underspecification is a `SCOPE` defect, and it is cheapest
to catch before `TRIGGER`:

1. **Gate the goal, not just the scaffolding.** Add an ambiguity check ahead of the readiness score
   — the score can be 100 on a goal nobody can interpret.
2. **Put it in a different agent from the implementer**, and let it halt.
3. **Budget the questions**, or the gate gets turned off — 52% of unassisted sessions over-ask.
4. **Set a deadline for asking, not just a policy.** After roughly the first tenth of execution, a
   goal-level question is close to worthless; past the midpoint it is actively harmful. If the loop
   has not resolved its ambiguity early, the correct move is to **stop and re-scope**, not to ask
   mid-flight.

## A-Priori Goal-Cost Estimation

The Budget primitive is usually set by guesswork. Because the six canonical patterns
each carry a characteristic cost profile, you can instead **forecast cost from the
pattern before the run starts**:

```bash
npx @cobusgreyling/goal-cost --pattern fix-bug
npx @cobusgreyling/goal estimate --pattern tests-green --level G2
```

The estimator is **pattern-keyed**: it maps a goal pattern (`fix-bug`, `tests-green`,
`migrate-module`, …) — optionally refined by the G0–G3 readiness tier — to an expected
token/turn cost, so you can set a realistic `--max-budget-usd` / `--max-turns` *before*
launching rather than discovering the cost after a runaway. This is the a-priori
counterpart to post-hoc cost tracking (see [Cost & Turn Control](11-cost-control.md));
pair them — estimate from the pattern, then cap with the measured ceiling.

([cobusgreyling/goal-engineering v1.1.0 — "Stack release (Loop + Goal)"](https://github.com/cobusgreyling/goal-engineering/releases/tag/v1.1.0) `goal-cost`, Jun 2026. The `goal-cost` package itself is v1.0.0 and, unlike `goal-audit`/`goal-init`, is not published to npm — `npx @cobusgreyling/goal-cost` and `npx @cobusgreyling/goal` both 404 as of 2026-09-05, so check `npm view @cobusgreyling/goal-cost version` before relying on the commands above.)

## Case Study: 107M Rows on a Single Goal

A concrete real-world data point on how far a single well-formed Goal scales: Ben Tossell
set Codex running on one `/goal`-equivalent objective to repeat tasks until done,
delegating to **hundreds of subagents** — including a dedicated **auditor subagent
verifying the numbers** — to scrape and clean 107 million rows of UK council spending data.
The auditor role is the Verifier primitive in this doc made concrete at scale: a goal this
large doesn't get one final check, it gets a standing subagent whose only job is
cross-checking the working agents' output against the source data as it accumulates.
([Ben's Bites, "Scraping 107M rows of data to build this"](https://www.bensbites.com/p/scraping-107m-rows-of-data-to-build), Sep 2026.)

## Aspire — Can Models Self-Evolve from Vague Goals?

The Four Goal Primitives above assume the Objective starts well-formed (per the "Bad" vs
"Good" example). Aspire benchmarks the harder case: **vague-goal-driven self-evolution**,
where the objective itself is underspecified and the agent must sharpen it across attempts.
Agents complete the training loops, but weight-level gains stay sparse, and harness
evolution lags hand-engineered references — evidence that the G0 (vague objective) case
this doc already flags as "do not launch; clarify first" is not yet something agents reliably
self-correct their way out of, reinforcing rather than replacing the G0–G3 readiness
discipline above. ([arXiv 2608.31111, "Aspire"](https://arxiv.org/abs/2608.31111), Aug 2026.)

## Relationship to the Loop Contract

A goal is a single non-recurring iteration with a deterministic stopping condition.
A goal's stopping condition is almost always the **completion check** in the
[Stop Condition Taxonomy](27-loop-contract.md#stop-condition-taxonomy), backed by a
budget safety stop. The [Loop Contract](27-loop-contract.md)'s STOP property maps
directly to the Verifier primitive. The Anchor File pattern maps as follows:

| Anchor file | Goal primitive |
|---|---|
| `VISION.md` | Objective |
| `GOAL.md` | State |
| `CLAUDE.md` | Guardrails (within State) |
| Stop hook / CI | Verifier |
| `--max-budget-usd` | Budget |
