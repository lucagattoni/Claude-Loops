# The Loop Contract

**Designing the loop is the central act of loop engineering.** Before any code runs,
you answer five questions about the loop itself:

| Design question | What it decides | Contract property |
|---|---|---|
| **What?** | The purpose and what the loop may touch | SCOPE |
| **How?** | What the loop actually does each time it fires | ACTION |
| **When?** | What starts it — schedule, event, or signal | TRIGGER |
| **How much?** | The cost and runtime it is allowed to spend | BUDGET |
| **How do you know it's done?** | What "done" looks like and the verifier that confirms it | STOP + verifier |

The fifth question is a peer, not a footnote of "what." Knowing — and *checking* —
when the loop is done is the hardest and most-failed design decision: it is what the
[Stop Condition Taxonomy](#stop-condition-taxonomy) below and all of
[Verification](04-verification.md) exist to answer. A sixth property, **REPORT**, says
what the loop tells you when it finishes.

The Loop Contract is the concrete instrument for answering these. Get the design right
and execution is mechanical; get it wrong and no amount of model quality rescues it.
**A loop without a complete contract is guaranteed to under-deliver or over-spend.**
This design step — not the prompting, not the model choice — is where loop engineering
lives. ("The harness now matters more than the model" — see [The Paradigm Shift](01-paradigm-shift.md).)

(Source: explainx.ai, ["How to Build Your First Agent Loop: A Step-by-Step Guide"](https://www.explainx.ai/blog/how-to-build-your-first-agent-loop-step-by-step-2026), Jun 2026.)

## The Six Properties

Each property answers one of the design questions above. Define all six explicitly
before launching:

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

**Plan-as-contract for one-off fleet dispatch.** A lighter variant for a single
orchestrator dispatching to worker agents (rather than a standing loop): the
orchestrator writes one `plans/<name>/PLAN.md` per unit of work — the SCOPE and
ACTION properties for *that dispatch* — and the worker's only contract is to
execute exactly that plan and report back. Because the plan lives in git, a failed
dispatch can be trivially re-issued from the same file rather than re-specified from
scratch. ([walidboulanouar/loop-engineering](https://github.com/walidboulanouar/loop-engineering), Jul 2026.)

## Quota-Aware Should-Run Gate

A refinement of the BUDGET property for loops that persist across many agent turns
and restarts: rather than BUDGET being only a hard ceiling (spend no more than $X),
gate *every turn* through an explicit **should-run decision** with four states —
**proceed** (budget and priority clear it), **wait** (a higher-priority gate is
pending), **ask** (needs a human decision before spending more), or **idle** (nothing
actionable right now). This turns "did we run out of budget?" from a single
end-of-run check into a per-turn admission decision, and gives the loop a defined
state for "there is budget left but proceeding isn't the right call yet" — a case a
binary budget cap cannot express. Paired with a **safe fallback** rule: when the
primary (P0) objective is gated, the loop may still make progress on lower-priority
(P1/P2) work rather than sitting fully idle, provided that work is tracked with the
same evidence and ownership discipline as the primary objective (see
[claimed_by todo ownership](16-memory-patterns.md#pattern-d-multi-backend-task-queue)).
([huangruiteng/loopx](https://github.com/huangruiteng/loopx), Jul 2026.)

## Two Quality Gates

Before a loop iteration continues or launches, apply two explicit checkpoints:

| Gate | Question | When |
|---|---|---|
| **Gate 1 — Evidence completeness** | Is the output backed by objective evidence (test results, logs, metrics)? | Before allowing the loop to continue to the next iteration |
| **Gate 2 — Stopping condition clarity** | Can you state exactly what "done" looks like before the loop starts? | Before launching the loop at all |

Gate 2 maps directly to the STOP property in the Loop Contract above. Gate 1 is
what enforces it at runtime — without objective evidence, the loop cannot know
whether STOP has been met.

(Wooheum Xin, ["Stop Writing Prompts: The True Nature of Loop Engineering"](https://zenn.dev/acrosstudioblog/articles/38509c0473683a), Zenn, Jun 2026.)

## Stop Condition Taxonomy

The STOP property is the single most-cited failure point in loop engineering. A loop
that cannot say what "done" looks like stops too early (undercooked), runs forever
(overcooked), or never reports (forgotten) — the **rice-cooker problem**.
(Martin Ma, ["What the Hell Is Loop Engineering?"](https://www.linkedin.com/pulse/what-hell-loop-engineering-martin-ma-roipc/), Jun 2026.)

Every STOP property is built from one or more of four stop-condition categories. This
is the **canonical taxonomy** — other docs reference it rather than re-defining it.

| Category | Fires when | Role |
|---|---|---|
| **Completion check** | A verifier confirms the objective is met (tests pass, `VERDICT: PASS`, checklist complete) | The only *success* stop |
| **Budget exhausted** | `--max-budget-usd` or `--max-turns` cap reached | Safety stop — contain cost |
| **Max iterations** | Fixed iteration count reached (e.g. `/goal` stop-after-N: rename 25, CSV 30, PDF 40 turns) | Safety stop — bound runtime |
| **No-progress (stall)** | N consecutive iterations produce no measurable change (no new passing test, no diff) | Safety stop — detect dead-ends |

**Only the completion check means success.** The other three are *safety* stops: they
prevent a runaway but leave the work incomplete, so they must escalate to a human or a
retry — never report PASS. A production loop pairs a completion check (success) with at
least one safety stop (containment); a loop with only safety stops can never succeed,
and a loop with only a completion check can never be contained.

**Verification *is* the completion check.** "An agent loop without a verifier just
compounds its own mistakes on a schedule." ([@bojan_ai](https://x.com/bojan_ai/status/2070433693957558636), Jun 2026.)
The completion-check stop is only as trustworthy as the verifier behind it — see
[Verification](04-verification.md) for building a verifier the STOP property can rely
on, and the maker/checker separation that stops the agent grading its own work.

The runtime termination signals in [The Core Agent Loop Cycle](02-agent-loop-cycle.md)
(`success`, `error_max_turns`, `error_max_budget_usd`, Stop-hook rejection) are the
mechanical events that *enforce* these design-time categories: `success` enforces the
completion check; `error_max_turns` / `error_max_budget_usd` enforce the budget and
max-iteration stops.

(Stop-condition categories: Akshay Pachaar, ["Loop Engineering Clearly Explained"](https://x.com/akshay_pachaar/status/2069118430582866051), Jun 2026; bounded N-turn examples: [Sabrina Ramonov](https://x.com/Sabrina_Ramonov/status/2070125608013648082), Jun 2026; three-checkpoint model: [MindStudio](https://www.mindstudio.ai/blog/how-to-build-agentic-loop-claude-code), Jun 2026.)

### Reference implementation: the three exit codes

A minimal loop that *provably halts* maps the taxonomy onto three deterministic exit
codes, with the check run by the loop itself (not the agent — see
[Verifier Integrity](04-verification.md#verifier-integrity-keeping-the-check-unfakeable)):

| Exit | Category | Fires when |
|---|---|---|
| `0` | Completion check | the real check passes |
| `3` | No-progress | the objective score stays flat for K iterations |
| `2` | Max iterations | a hard iteration ceiling is hit |

Two design points sharpen the taxonomy:

- **Score the goal, not the activity.** No-progress is measured by an objective
  `score=<fraction>` line, where the scorer "exits 0 iff the goal is met." "Progress is
  the score moving, not 'did files change' — a busy-but-stuck agent still halts." A
  loop that watches for file edits or token spend mistakes motion for progress.
- **The verifier is external.** The loop runs the real check every iteration, so the
  worker cannot fake completion; the control system is fixed and deterministic while
  the worker is stochastic and swappable.

([uppifyagency/loop-kernel](https://github.com/uppifyagency/loop-kernel), Jun 2026; the same `0`/`2`/`3` contract appears independently in [firegnu/herdr-loop-lab](https://github.com/firegnu/herdr-loop-lab), Jun 2026.)

### Extension: tamper-evident contracts and named exit codes

Three exit codes are the floor, not the ceiling. A **Product Contract** — the goal,
acceptance criteria, verification commands, and stop conditions — can itself be
tampered with (by the agent under pressure to declare success, or by an external
edit); hashing the contract at approval time and treating any mismatch as its own
stop condition (`NEEDS_SPEC_DECISION`) closes a gap the basic taxonomy doesn't
address: *the spec drifting is a different failure than the work drifting*, and needs
its own detectable, named exit state. Expanding from 3 to **8 named exit codes**
(rather than reusing one code for several distinct failure classes) makes the caller
able to distinguish "no progress" from "spec tampered" from "reviewer disagreed"
without parsing log text.

([Aitne-sh/loop-kit](https://github.com/Aitne-sh/loop-kit), Jul 2026.)

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

(Claire Vo, Lenny's Newsletter, ["How I AI: How to write AI agent loops"](https://www.lennysnewsletter.com/p/how-i-ai-how-to-write-ai-agent-loops), Jun 2026.)

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

(session-orchestrator — [Kanevry/session-orchestrator](https://github.com/Kanevry/session-orchestrator), Jun 2026.)

## YAML-Declarative Loop Definition

Loops can be specified declaratively (rather than as imperative scripts), making the contract
machine-readable and auditable:

```yaml
# loop.yaml — VERDICT: PASS gate protocol
name: PR Babysitter
trigger:
  type: cron
  schedule: "*/15 * * * *"
scope:
  - src/
  - tests/
budget:
  max_usd: 1.00
  max_turns: 40
stop:
  verdict: PASS          # Missing verdict = FAIL; ambiguous completion = FAIL
  evidence: required     # Loop cannot exit without including test output or diff
escalation:
  after_attempts: 3      # After 3 failed verdict attempts, route to human inbox
```

**VERDICT: PASS gate:** a loop iteration is not done until it explicitly outputs `VERDICT: PASS`
with supporting evidence. An iteration that ends without a verdict is treated as `VERDICT: FAIL`.
This eliminates "looks done" exits where the agent ran out of turns mid-task.

**2-Layer Budget Ceiling:** loop-level cap (total run cost) AND per-step cap (cost per agent
invocation within the loop):

```yaml
budget:
  loop_max_usd: 2.00        # If exceeded: loop terminates and escalates
  step_max_budget_usd: 0.50 # Per-agent-invocation limit; passed as --max-budget-usd
```

([faisalishfaq2005/loopflow](https://github.com/faisalishfaq2005/loopflow), Jun 2026.)

## Self-Discovery Loop Pattern

Rather than relying on external work queues, a self-discovering loop finds its own tasks
from live system signals each run:

```
Schedule → Discover → Build → Verify → Repeat
```

1. **Schedule** — fire on cron or event; always exit early if nothing to discover
2. **Discover** — scan failing CI runs, open issues with matching labels, recent commits that touched scope files; produce a ranked task list
3. **Build** — each task runs in its own isolated git worktree; tasks are independent and can parallelise
4. **Verify** — CI or dedicated verifier agent confirms the fix before merge
5. **Repeat** — write learnings to GOAL.md / CLAUDE.md; next scheduled run starts from the updated state

Self-discovery eliminates the manual queue maintenance step: the loop knows what to work on
because it reads the same signals a human engineer would check in morning triage.

([Anthropic engineering practices](https://www.anthropic.com/engineering), Jun 2026.)

## Relationship to Goal Engineering

When a loop's STOP condition is deterministic and the task is non-recurring, the
loop degenerates into a **Goal** — a bounded task with a single verifiable completion
state. The [Goal Engineering](30-goal-engineering.md) doc covers the four Goal
Primitives and the GOAL.md persistent state file in detail.

## Cross-Run Memory Persistence

Every loop run should append a brief outcome record to a persistent memory file.
This gives the next run the context of what the previous run found, decided, and cost —
without requiring a human to summarise it.

```markdown
# .loopflow/memory/pr-babysitter.md  (appended after each run, prepended to next run's prompt)

## Run 2026-06-25 06:41 UTC
- **Outcome:** VERDICT: PASS — 2 stale PRs closed, 1 draft marked ready
- **Cost:** $0.31 (headroom: 69%)
- **Notable:** PR #88 auth migration — merge blocked on CI flake, not code
- **Next run:** re-check PR #88 first; CI flake in auth-tests is a known issue
```

"The agent forgets; the repo doesn't."

The memory file is distinct from STATE.md (execution phase) and GOAL.md (done conditions).
It is an episodic log optimised for the *next agent invocation* — not a recovery mechanism
but a continuity mechanism. See [Memory Patterns](16-memory-patterns.md) for storage backends.

([faisalishfaq2005/loopflow](https://github.com/faisalishfaq2005/loopflow), Jun 2026.)

## Gate Feedback Injection

When a VERDICT gate returns FAIL, inject the rejection reason into ALL agent prompts in
the next iteration — not just the gate step's prompt.

Standard retry pattern: gate fires → same loop re-runs → gate fires again.

Gate feedback injection: gate fires → rejection reason prepended to EVERY agent's system
prompt → next iteration starts with every sub-agent aware of why the previous attempt failed.

This is distinct from simply retrying. The failure context propagates laterally to agents
that weren't involved in the failing step — preventing them from repeating setup conditions
that contributed to the failure.

Example injection:
```
[PREVIOUS RUN FAILED] Gate rejection: "PR description is missing the test evidence section.
All PRs must include a test output block." — apply this constraint in all PR-related steps.
```

([faisalishfaq2005/loopflow](https://github.com/faisalishfaq2005/loopflow), Jun 2026.)

## Relationship to the Factory Model

The Loop Contract is the specification document for a factory model workflow. Just
as a factory floor has defined inputs, processes, and quality gates, the contract
defines what the loop accepts, does, and produces. See [The Factory Model](26-factory-model.md).
