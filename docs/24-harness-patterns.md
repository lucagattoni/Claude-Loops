# Harness Patterns

The harness is the scaffolding around the agent — prompts, tools, context policies,
sandboxes, and feedback loops. It is a first-class engineering artefact that requires
continuous refinement, not a disposable wrapper. An operational test for what actually
counts as a harness (as distinct from a framework, SDK, or orchestrator) — validated
against Claude Code, Codex CLI, Aider, Cline, OpenHands, and SWE-agent — is given in
["What makes a harness a harness"](https://arxiv.org/abs/2606.10106) (arXiv, Jun 2026).

## Harness vs. Loop — Two Architectural Layers

| Layer | Scope | Analogy |
|---|---|---|
| **Harness** | Single-agent safety wrapper — prompts, tools, context policies, sandboxes | Equipment |
| **Loop** | Multi-agent orchestration + scheduler that governs multiple harness cycles | Factory control plane |

The harness is prerequisite infrastructure; the loop is the control plane above it.
A well-designed loop depends on well-designed harnesses — but the loop's job is
coordination and termination, not execution.

### The Harness as an Org-Level Artifact

At scale the harness stops being a per-developer convenience and becomes the primary
*organizational* artifact — the shared substrate that defines how every agent in a
company behaves, what it may touch, and how its work is verified.

> "It is an org-level harness. The difference will become clearer over time."
> ([@karpathy](https://x.com/karpathy/status/2069822834160124091) on Claude Tag, Jun 2026)

The implication: harness design decisions (permission posture, verification gates,
credential handling) are no longer local choices — they propagate to every loop the
org runs. This is why the harness, not the model, is the leverage point ("the harness
now matters more than the model" — see [The Paradigm Shift](01-paradigm-shift.md)).

**Origin story.** Anthropic's own account of Claude Code's beginnings (internal codename
"clide") traces "harness design" back to 2022-2023 work on giving a model a persistent
shell and a bash tool — before Claude Code existed as a product, the prototype was
already fanning out 100 Haiku subagents in parallel, and the app itself was, in its
builders' words, "tool definitions in a loop and a simple REPL UI." The org-level-artifact
framing above isn't a new idea layered on top of the tool — it's the same concern the
original builders were solving for from day one.
([Anthropic, "The Making of Claude Code"](https://www.anthropic.com/features/making-of-claude-code), Jul 2026.)
The org-level harness is realised concretely as per-thread/per-channel agent instances
with their own memory and permissions — see [Claude Tag](31-claude-tag.md) — and
governed across many loops via [Fleet Engineering](23-fleet-engineering.md).

**The quantified version of the thesis:** LangChain reports moving their coding agent
"from Top 30 to Top 5 on Terminal Bench 2.0 by only changing the harness" — same model
(Opus 4.6 in Claude Code), harness-only changes. This is the hardest evidence to date
that harness design, not model swap, is the accessible leverage: a mid-pack agent
became top-5 with the model held fixed. (LangChain, ["The Anatomy of an Agent Harness"](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness), Mar 2026.)

Two benchmarks add further quantified weight to the same thesis. **StaminaBench**
(stress-testing coding agents over 100+ interaction turns) finds harness quality alone
creates up to a **6x performance gap** between otherwise-similar models, and that
feedback loops improve results by up to **12x** over single-shot attempts — the harness,
not the base model, dominates sustained-task performance.
([arXiv 2606.19613](http://arxiv.org/abs/2606.19613), Jun 2026.) **Claw-SWE-Bench**
(evaluating OpenClaw-style harnesses on coding tasks) found the *same backbone model*
scores only 19.1% with a minimal adapter versus **73.4%** with a full adapter — a 4x
swing from harness completeness alone, with the model held fixed.
([arXiv 2606.12344](http://arxiv.org/abs/2606.12344), Jun 2026.)

### Harness Conformance Testing (harness-bench)

If the harness is the leverage point, it needs its own tests — not just the code it
produces. A **harness conformance suite** validates whether a given harness meets a
standard capability contract (does it enforce stop conditions, isolate agents, gate
tools, recover state?), turning "is this harness production-grade?" into a benchmark
rather than a judgement call. This is a distinct evaluation primitive from output
verification ([docs/04](04-verification.md)): output verification asks "is the *work*
correct?"; conformance testing asks "is the *harness* capable?"
([omnigent-ai/omnigent](https://github.com/omnigent-ai/omnigent) `harness-bench`, Jul 2026.)

**Self-correcting capability tables.** A conformance bench is only as trustworthy as the
capability table it checks against — and that table can itself drift out of sync with
reality (e.g. an adapter wrongly declared "streaming-capable" for a harness that dropped
streaming support). The fix is structural: when a conformance run finds a declared
capability doesn't hold, the bench corrects the *source model* (the capability
declaration) rather than papering over it with a special-cased test — keeping the
declared contract and the bench itself from silently diverging over time. Supporting this,
the bench runs against three transport drivers (in-process SDK, full server, native TUI)
so a capability gap specific to one transport doesn't hide behind a pass on another.
([omnigent-ai/omnigent](https://github.com/omnigent-ai/omnigent) `harness-bench`, Jul 2026.)

**Cross-vendor observable policy denials.** A conformance suite is only useful if a
denial is actually *visible* to whatever is testing it. `harness-bench` added a
`PolicyDeniedEvent` so that when a native harness (Claude Code, Codex, etc.) blocks
a tool call under policy, that denial surfaces as an observable stream event rather
than a silent no-op — letting the same conformance probe verify deny-behavior
consistently across vendors instead of trusting each harness's own logs.
([omnigent-ai/omnigent](https://github.com/omnigent-ai/omnigent) `harness-bench` #2096, Jul 2026.)

### Schema-Level Conformance (Temper)

`harness-bench` tests *behavior* (does the harness enforce stop conditions, gate
tools, recover state at runtime?). A complementary, cheaper check is **schema-level
conformance**: does the `.claude/` directory itself — skills, rules, agents, hooks —
match a declared contract, before anything even runs? Temper implements this as a
compiler-like pipeline rather than a linter: `init` scans the whole `.claude/`
directory into one typed model, `emit` deterministically compiles author-declared
requirements into a lock file (regenerated twice to self-verify determinism), and
`check` gates the actual files against that lock in CI. The distinction from
harness-bench: this catches drift in the harness's *declared shape* (a skill file
that no longer matches its own schema) before a conformance run ever needs to
exercise it at runtime. ([duct-tape-and-markdown/temper](https://github.com/duct-tape-and-markdown/temper), Jul 2026.)

## Task-Shaped DAG Orchestration

An alternative to a fixed N-agent pipeline (two-part, three-agent, five-wave): compose
a **task-shaped DAG** per issue, sized to the issue's actual complexity rather than a
fixed role count. A simple fix becomes a single-node DAG; a complex feature fans out
into parallel research and implementation legs. Distinguishing mechanisms:

- **Fail-closed exit gates**: every node runs an act → check → close cycle; a
  post-dominance gate ensures a code-reviewer node evaluates *every* code-producing
  node reachable in the graph (no path bypasses review by construction), and a
  security-reviewer gate is inserted specifically for sensitive changes.
- **Classifier-gated parallelism**: before claiming parallel work, a pre-claim check
  (file overlap, shared dependencies, shared infrastructure) marks candidate work
  green / yellow / red / blocked — parallelism is only attempted where the classifier
  has already ruled out collision, rather than discovered after the fact (contrast
  with [Scope-Verified Parallelism](10-fan-out.md#scope-verified-parallelism), which
  catches collisions at the point of write instead of before dispatch — the two are
  complementary layers, not substitutes).
- **Mandatory synthesizer merge**: write-fan-outs proven disjoint still run in
  isolated per-node worktrees by default, and a dedicated synthesizer node
  octopus-merges divergent branches — parallel execution never merges itself.
- **Bounded review-fix loop**: capped at a maximum of 5 iterations with mechanical
  (not self-assessed) verdicts, preventing the [infinite fix loop](17-failure-patterns.md) pattern.

Durable state (`workflow-state.md`) records phase, step, pending gates, and per-node
evidence, so a session resumes mid-workflow across a context reset rather than
restarting the DAG. ([KaolaBrother/Kaola-Workflow](https://github.com/KaolaBrother/Kaola-Workflow), Jul 2026.)

## Self-Improving Harnesses

If the harness is the leverage point — and it can be tested
([harness conformance](#harness-conformance-testing-harness-bench)) — the next step is a
harness that **optimizes itself**. The 2026 research converges on a claim the rest of this
doc only implies: the harness is not a fixed, human-authored artifact but an **optimization
target with measurable returns**, and the optimizer can be the agent working on its own
execution traces — no stronger external model or human engineer required.

This is the disciplined answer to an under-performing loop (see
[Failure Patterns](17-failure-patterns.md)): instead of hand-tuning prompts, mine the traces
for the harness change that fixes the failure class. It is distinct from
[Learned Orchestration](22-learned-orchestration.md), which *trains a model* to orchestrate —
here the model stays fixed and the **harness config (tools, middleware, memory, control flow)**
is what evolves.

**Self-Harness — weakness mining → propose → validate.** A three-stage self-improvement loop
that needs no external engineer:

1. **Weakness Mining** — extract model-specific failure patterns from execution traces.
2. **Harness Proposal** — generate targeted, *minimal* harness edits addressing those failures
   (not generic prompt instructions).
3. **Proposal Validation** — regression-test each candidate before acceptance. The validate
   stage is itself a [verification gate](04-verification.md): a proposed harness edit is
   unverified until a held-out run confirms it.

Reported Terminal-Bench-2.0 gains, model held fixed: MiniMax M2.5 40.5%→61.9%,
Qwen3.5-35B-A3B 23.8%→38.1%, GLM-5 42.9%→57.1% (up to +21.4pp absolute). The point:
model-specific weaknesses become concrete, executable harness changes rather than more prose.
([arXiv 2606.09498](https://arxiv.org/abs/2606.09498), Jun 2026.)

**AHE — observability-driven evolution with verified prediction contracts.** Agentic Harness
Engineering makes the harness auto-evolvable by building on three observability pillars:

| Pillar | What it exposes |
|---|---|
| **Component observability** | Each editable harness element is file-level, explicit, and reversible |
| **Experience observability** | Raw trajectories are converted into a layered evidence corpus |
| **Decision observability** | Every edit ships a self-declared *prediction*, later verified against the next round's task outcomes |

Decision observability is the key discipline: each harness edit is a **falsifiable contract**
(a prediction a later run confirms or refutes) — the maker/checker principle applied to the
harness's own changes. Results: Terminal-Bench 2 Pass@1 69.7%→77.0% over 10 iterations,
*beating the human-designed Codex-CLI baseline* (71.9%); top SWE-bench-verified aggregate with
12% fewer tokens than the seed harness; cross-family transfer +5.1 to +10.1pp. **Ablation:**
the gains come from tools, middleware, and memory components — *not* system prompts — which
sharpens where harness effort actually pays. ([arXiv 2604.25850](https://arxiv.org/abs/2604.25850), Apr 2026.)

**HarnessX — a substitution algebra over typed primitives.** Frames runtime components as
*typed harness primitives* over a **substitution algebra** (any primitive can be swapped for
an equivalent), with an evolution engine (AEGIS) that refines prompts, tools, memory, and
control flow from execution traces. Reports +14.5% average across five benchmarks (ALFWorld,
GAIA, WebShop, and two others), up to +44.0%.
([Cobus Greyling](https://cobusgreyling.substack.com/p/harnessx-when-the-harness-starts) / [arXiv 2606.14249](https://arxiv.org/abs/2606.14249), Jul 2026.)

**SEAGym — evaluation environments for self-evolving harnesses.** A dedicated eval
environment for self-improving harnesses surfaces two risks the three approaches above
share: useful intermediate harness snapshots can **collapse** in later iterations (the
optimizer overfits to recent traces and regresses on cases it previously handled), and
**source diversity** — how varied the training traces are — materially affects harness
reliability after evolution. Practical implication: keep a fixed regression suite of
*earlier* snapshots' solved cases and re-check it every iteration, not just the newest
failures. ([arXiv 2606.17546](http://arxiv.org/abs/2606.17546), Jun 2026.)

**APEX — co-evolving harness, principles, and workflow together.** Rather than evolving
the harness alone, a three-layer framework simultaneously co-evolves the harness
configuration, the stated principles guiding it, and the workflow topology, raising a
composite "Health Score" from 0.300 to 0.570 — evidence that harness-only evolution
(the three approaches above) may be leaving gains on the table by holding principles and
topology fixed. ([arXiv 2606.15363](http://arxiv.org/abs/2606.15363), Jun 2026.)

**Darwin Mode — train/eval-disjoint held-out gating (closing the SEAGym collapse risk).**
SEAGym (above) warns that self-evolving harnesses can overfit to their own recent traces
and regress on cases they previously solved. A concrete gating mechanism closes this: the
optimizer mutates its own config, sandbox-tests each candidate mutation, and keeps *only*
mutations that measurably improve performance on a **held-out benchmark set strictly
disjoint from the traces used to generate the mutation** (e.g. SWE-bench Lite, LiveCodeBench).
Train/eval disjointness — not just "a regression suite exists" — is what prevents the
optimizer from mutating toward whatever the held-out set happens to reward. A companion
model router learns, from fleet-wide eval logs, the *cheapest sufficient* model per task
rather than always routing to the strongest — a fleet-maturity-relevant detail alongside the
harness-evolution one. ([ruvnet/metaharness](https://github.com/ruvnet/metaharness), Jul 2026.)

**Mechanized rules beat prose guidance, quantified.** A self-improving harness that
converts confirmed tool-call failures into durable, vote-weighted lessons (promoted into
an enforced hook once repeat evidence crosses a weight threshold) reports **~100%
compliance for mechanized rules versus ~70-90% for the equivalent prose guidance** in
CLAUDE.md. This is a directly quantified version of the "encode learnings as rules, not
prose" principle already implicit in [Experience Encoding](27-loop-contract.md) —
a rule the harness enforces is followed far more reliably than a rule the model is merely
told about. ([Aditya-Nagariya/harness-forge](https://github.com/Aditya-Nagariya/harness-forge), Jul 2026.)

**The shared shape:** all three are outer loops whose *product is a better harness*, each gated
by a verifier (regression run / prediction contract / benchmark). They validate the
harness-conformance idea from the other direction — not "does this harness pass a fixed
capability bar?" but "can the harness raise its own bar and prove it?" Keep the edits minimal
and reversible (component observability) and gate every proposed edit on a held-out run — an
un-validated harness edit is [Verifier Theater](17-failure-patterns.md) at the meta level.

**The cost case, quantified.** A Hugging Face proposer/accept-reject loop that rewrote *only*
the harness code around a frozen model matched Sonnet 4.6's legal-agent-benchmark score at
roughly **7x lower inference cost** — and with identical model and tasks, score ranged from
3.5% to 80.1% depending solely on harness quality. This is the sharpest evidence yet that
harness spend, not model spend, is where the marginal dollar buys reliability — the same
thesis as [The Paradigm Shift](01-paradigm-shift.md), now with a cost multiplier attached.
([Hugging Face, "Don't train the model, evolve the harness"](https://huggingface.co/spaces/joelniklaus/harness-optimization), Jul 2026.)

## Harness vs. Environment Engineering

Two complementary safety layers operating at different levels of the stack:

| Layer | Scope | Controls |
|---|---|---|
| **Harness engineering** | In-process | settings.json permissions, lifecycle hooks (PreToolUse/PostToolUse), MCP gates, CLAUDE.md rules |
| **Environment engineering** | Out-of-process | OS user per agent, container isolation, network filtering, credential broker |

The distinction matters for defense-in-depth:

- **Harness controls** are enforced by the Claude Code runtime — effective against autonomous bad decisions, but inside the same process as the agent.
- **Environment controls** are enforced by the OS or infrastructure — they limit what the agent *can* do regardless of what the model decides, and cannot be overridden by the model.

**Three reference deployment patterns:**

| Pattern | Harness posture | Environment posture | Use when |
|---|---|---|---|
| **Approval-First** | All file writes in ask list | Standard OS user | New loop, unknown scope |
| **Curated Allow-list** | Explicit allow list; everything else denied | Standard OS user | Loop scope is well-understood |
| **Sandboxed Full-Auto** | Auto mode, full tool access | Isolated container + network filter | Fully autonomous production loop |

Rule: start every new loop at Approval-First; advance to a higher pattern only after two weeks of zero policy violations at the current level.

See [Permissions & Auto Mode](08-permissions.md) for the full harness-layer control reference (allow/deny/ask lists, risk-tiered authorization, agent trust ramp).

(hidekazu-konishi, ["Claude Code Harness and Environment Engineering"](https://hidekazu-konishi.com/entry/claude_code_harness_and_environment_engineering_guide.html), Apr 2026.)

> "Verification closure creates reliability; reliability creates scalability."

Verification built into the harness (a separate verifier agent, objective evidence
gates) is what makes a loop safe to scale up: you can run more iterations, more
agents in parallel, and larger budgets only when each cycle's output is trustworthy.

## The "Unstable Components" Design Axiom

> "Models may speak like teammates, but they do not automatically gain
> teammate-grade stability."

This is the foundational posture for harness design: treat the model as an
**unreliable runtime component requiring containment**, not a collaborator requiring
instructions. The consequences for harness design:

- Every agent output is unverified until a deterministic check confirms it
- The harness enforces boundaries the model cannot override (hooks, OS-level isolation)
- Stability comes from the harness, not from model capability — model improvement
  shifts the cost boundary but does not eliminate the need for containment

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

## Ledger Closure for Interrupted Tool Calls

When a session is interrupted mid-tool-call, external systems reading the session
transcript get corrupted state unless ledger closure is enforced:

Every `tool_use` block **must** be paired with a `tool_result` block before the
session can be considered consistently closed. An interrupted session that leaves
a `tool_use` without a matching `tool_result` produces an uninterpretable trace —
orchestrators that resume from this state make decisions based on corrupted input.

**Applicability note:** Ledger closure is primarily relevant for orchestrators that
directly construct Claude API message arrays (custom harness, not CLI). Claude Code
CLI sessions do not expose the raw message array; this pattern applies when you
manage the conversation turn sequence programmatically.

Interrupt handling pattern:
1. Detect the interruption (timeout, crash, explicit stop)
2. Emit a `tool_result` for the pending `tool_use` with an error payload
3. Only then persist the session state to the state file

```json
{
  "type": "tool_result",
  "tool_use_id": "<id-of-the-interrupted-call>",
  "content": "Interrupted — result unavailable",
  "is_error": true
}
```

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

## The Two-Part Harness (Anthropic Engineering)

Anthropic's ["Effective Harnesses for Long-Running Agents"](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
defines a two-role harness split:

### 1. Initializer Agent
- Reads the high-level goal and generates a **structured JSON feature list** — a machine-readable work plan
- Sets up session state: which files are in scope, what the success criteria are, what constraints apply
- Writes a mandatory **session init routine** that the coding agent reads at the start of every context window

### 2. Coding Agent
- Executes tasks from the JSON feature list, one unit at a time
- Uses **browser automation testing** to verify UI/UX changes without requiring a human
- Applies **git-based recovery**: commits after each unit so any crash can resume from the last known-good state

The key invariant: the initializer runs once; the coding agent runs many times, each
time within its own context window, always starting by reading the session init file.

## The Four-Type Loop Taxonomy (Claire Vo / Lenny's Newsletter)

Every agent loop has a trigger type. Choosing the wrong trigger type is one of the
most common harness design mistakes:

| Type | Trigger | Notes |
|---|---|---|
| **Heartbeat** | Fixed interval (every N minutes) | Checks for work; exits immediately if nothing to do. Cheap if work is rare; expensive if the interval is too short |
| **Cron** | Scheduled time (daily, weekly) | Predictable resource usage; suits batch jobs and digests |
| **Hook** | Event-driven (push, PR, webhook, file change) | Only fires when work exists — no polling overhead. Preferred for reactive workflows |
| **Goal** | Runs until a success condition is met | Hardest to write; most likely to burn tokens without output. Requires a rigorous stop condition and budget cap |

The goal loop is the most powerful and the most dangerous: without a verifiable
stopping condition and a hard spend cap, it will run indefinitely.

See also: [Loop Contract](27-loop-contract.md) for mandatory BUDGET and STOP properties.

### The Official Claude Team Loop Types

Anthropic's own Claude Code team publishes a complementary four-way split, framed by
*how much human involvement the trigger requires* rather than by mechanism:

| Type | Trigger | Stops when | Best for |
|---|---|---|---|
| **Turn-based** | A user prompt | Claude judges the task complete or needs more context | Short, exploratory work |
| **Goal-based** (`/goal`) | A manual real-time prompt | Goal achieved OR max turns reached | Tasks with verifiable completion criteria |
| **Time-based** (`/loop`, `/schedule`) | A fixed interval | You cancel it, or the work completes | Recurring tasks, monitoring external systems (`/loop` runs locally, `/schedule` moves it to the cloud) |
| **Proactive** | An event or schedule, no human in real time | Each task exits on completion; the routine runs until manually stopped | Well-defined recurring work (bug triage, dependency upgrades) |

This taxonomy overlaps but doesn't map 1:1 onto Heartbeat/Cron/Hook/Goal above — it
splits out *turn-based* (conversational, human-prompted) as its own category, and folds
Heartbeat+Cron together into *time-based*. Use Claire Vo's table to pick a trigger
mechanism; use this one to decide how much of the loop should run without a human in
the room. (["Getting started with loops", claude.com/blog](https://claude.com/blog/getting-started-with-loops), Jun 2026.)

## Three-Agent Full-Stack Harness (Anthropic Engineering)

For complex, multi-feature applications, Anthropic extended the two-part harness
into a three-agent system (Prithvi Rajasekaran, Mar 2026):

| Agent | Role | Key behaviour |
|---|---|---|
| **Planner** | Converts 1–4 sentence prompts into detailed product specs | Ambitious on scope; avoids technical over-specification; identifies AI feature opportunities |
| **Generator** | Implements features from spec | Self-evaluates before QA handoff; uses git for recovery; works in sprint contracts |
| **QA / Evaluator** | Active testing with Playwright MCP | Tests UI, API endpoints, and database states like a real user; grades against 20+ predefined criteria |

The Planner prevents cascade errors from spec mistakes by staying high-level.
The Generator negotiates sprint contracts with the Evaluator before each build phase.

### Sprint Contract

Before each implementation sprint, the Generator and Evaluator **negotiate** a specific
set of deliverables and testable criteria — often 20+ per sprint:

```
Sprint N contract:
- What will be built: [specific features]
- Success criteria: [20+ testable, objective conditions]
- "Done" definition: all criteria pass in QA
```

This bridges the gap between high-level user stories and implementation detail
without over-constraining technical decisions upfront. It also eliminates ambiguity
about what the Evaluator is checking — the criteria are agreed before code is written.

### Load-Bearing vs. Optional Components

As models improve, harness components that were essential scaffolding become
unnecessary overhead. **Re-evaluate which components are load-bearing with every
significant model release:**

- With **Opus 4.5**: sprints, explicit decomposition, and per-sprint evaluation were essential
- With **Opus 4.6**: model capability increased enough that sprint removal did not degrade output; single end-evaluation often sufficient

Rule: *find the simplest solution possible, and only increase complexity when
needed.* An evaluator only adds value when the task sits beyond what the baseline
model handles reliably solo. As that boundary moves outward with each model
generation, periodically simplify your harness and measure whether quality holds.

## Dynamic Workflow Patterns (Anthropic Engineering)

Rather than fixing one harness shape per project, Claude Code can **write its own
custom multi-agent harness per task** by selecting from six named orchestration
patterns — the harness itself becomes a decision the agent makes, not just a
human-authored default:

| Pattern | Shape | Guards against |
|---|---|---|
| **Classify-and-act** | A router classifies the task, then dispatches to a matching specialist | Applying the wrong workflow shape to a task that didn't need it |
| **Fan-out-and-synthesize** | Independent workers cover sub-parts in parallel; a synthesizer merges results | Sequential work that could have been parallelized |
| **Adversarial verification** | A separate agent tries to *break* the work rather than confirm it | Self-preferential bias — an agent approving its own output |
| **Generate-and-filter** | Many candidate solutions generated, weak ones filtered before any single one is polished | Sunk-cost commitment to the first plausible draft |
| **Tournament** | Candidates compete head-to-head across rounds; a judge advances the strongest | Local optima from evaluating candidates independently rather than comparatively |
| **Loop-until-done** | Repeat generate → evaluate until a stopping condition is met | Goal drift — treat this as the canonical implementation of the Loop Contract's STOP property |

These are explicitly framed as countermeasures to three named failure modes:
**agentic laziness** (settling for a shallow but plausible-looking pass),
**self-preferential bias** (an agent trusting its own output more than external
evidence), and **goal drift** (the task definition eroding across iterations — see
[Failure Patterns → Context drift](17-failure-patterns.md)). Pick the pattern to
match the failure mode you are most exposed to, not by default habit.

(Anthropic, ["A harness for every task: dynamic workflows in Claude Code"](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code), Jul 2026.)

## Cross-Model Division of Labor

A recurring pattern across mid-2026 harness design: **split roles across models by
cost/quality tier, not just by function.** A stronger (and more expensive) model is
kept for specification, review, and destructive operations; a cheaper or
faster model does the bulk of implementation — inverting the naive default of
running one model for everything.

- **Advisor loop**: an executor session calls a stronger model only *on demand* for
  guidance, while a cheaper model does the bulk implementation work — the stronger
  model is consulted, not driving. ([@steipete](https://x.com/steipete/status/2074638582418231495), Jul 2026.)
- **codex-first SKILL.md**: a Claude Code skill formalizing this as a hard rule —
  Claude keeps design, review, and destructive operations; implementation is
  delegated to `codex exec --yolo` via temp-file specs, with escalation back to
  Claude after two failed delegation attempts (a bounded retry, not an infinite
  handoff loop). ([steipete/agent-scripts](https://github.com/steipete/agent-scripts/blob/main/skills/codex-first/SKILL.md), Jul 2026.)
- **Puppetmaster**: generalizes the pattern into a provider-neutral control plane —
  a supervisor in front of multiple agent CLIs (Cursor, Claude Code, OpenAI) with
  leased worker subprocesses and typed, deterministically-stitched artifacts, so the
  division of labor is enforced by the control plane rather than by convention.
  ([professorpalmer/Puppetmaster](https://github.com/professorpalmer/Puppetmaster), Jul 2026.)
- **Official first-party version**: OpenAI's own Claude Code plugin implements the
  same reviewer-executor separation as a supported product, not a community skill —
  a `/codex:adversarial-review` command and an optional gate that **blocks Claude's
  response pending Codex's validation**. Notable because the pattern now has
  official backing from a *different* vendor, not just community consensus.
  ([openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc), Jul 2026.)

This is the same underlying idea as [Subagents' "strong eyes, cheap hands"](07-subagents.md)
cost-asymmetric role allocation, generalized from same-vendor subagents to
cross-vendor sessions — the review/execution split survives the model boundary. It
is also the *cost-allocation* side of the same coin as
[Verification's cross-model independence](04-verification.md#verifier-integrity-keeping-the-check-unfakeable)
pattern 5: that section argues cross-model review is more *effective* (different
blind spots); this section is about why it is increasingly also cheaper (cheap model
implements, expensive model only reviews/advises on demand).

## Five-Wave Execution Model

A typed sequential execution pattern where agents deploy in parallel within each
wave and output feeds the next gate:

| Wave | Role | Mode |
|---|---|---|
| 1. Discovery | Read-only audit — gather context, identify scope | Read-only |
| 2. Impl-Core | Primary implementation, parallel agents | Write |
| 3. Impl-Polish | Edge cases, integration, secondary paths | Write |
| 4. Quality | **Simplification pass** — before any test authoring | Write |
| 5. Finalization | Commit, create carryover issues for incomplete items | Write + commit |

**Wave 4 (Quality) is an inversion of standard TDD:** a dedicated simplification pass
runs on AI-generated code *before* tests are written. This prevents tests from
cementing suboptimal implementations — once tests pass against an awkward structure,
that structure becomes load-bearing. Simplify first; then write tests against the
simplified code.

Between waves: a confidence-scored reviewer audits deliverables across multiple
dimensions; only findings at ≥80% confidence surface. Low-confidence findings are
logged but suppressed. (See [Subagents](07-subagents.md) for confidence-scored gates.)

(session-orchestrator — [Kanevry/session-orchestrator](https://github.com/Kanevry/session-orchestrator), Jun 2026.)

## Runtime Republic vs. Constitutional Control Plane

Two fundamentally different harness philosophies, each suited to different contexts:

| | **Runtime Republic** (Claude Code) | **Constitutional Control Plane** (Codex) |
|---|---|---|
| Authority source | Emerges from the dominant query loop — continuous negotiation with reality | Encoded upfront in types, policies, event systems |
| Decisions | Flow from conversation and context | Flow from the constitution |
| Flexibility | High — instructions and context steer behaviour | Low — constitution is fixed at deploy time |
| Predictability | Medium — model reasoning introduces variance | High — policy violations are structurally impossible |
| Best for | Exploratory, creative, or complex tasks | Regulated, auditable, compliance-sensitive workflows |

Neither is strictly better — the choice depends on how much variance you can accept
and how much authority you need to encode upfront before the loop runs.

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

### Control-Plane / Execution-Plane Split (kernel-gated mutation)

A stronger version of the constitutional control plane: rather than encoding policy in types
the agents *should* obey, route **all state mutation through a kernel** that is the only
authorized writer. Skill agents are **read-only** over raw state and may write *exclusively*
through kernel subcommands; the kernel owns the state machines, budget enforcement, circuit
breakers, integrity logging, and session handoff. A multi-phase loop
(discovery → triage → make/review/integrate → handoff) then persists across Claude sessions via
content-hash-anchored state and append-only event logs, with human-approval gates on
irreversible actions.

The difference from a plain allow-list: the agent physically *cannot* corrupt state because it
has no write path except the kernel's audited subcommands — governance is enforced by the
architecture, not by the model's compliance. This is the harness-level counterpart to the
repo-owned durable ledger in [Memory Patterns](16-memory-patterns.md#pattern-g-repo-owned-durable-ledger).
([Sungmin-Cho/claude-deep-loop](https://github.com/Sungmin-Cho/claude-deep-loop), Jul 2026.)

**Feeding the kernel's own history back into itself.** A follow-up release added an
`insights` kernel subcommand that mines the kernel's own chain-verified run history
into deterministic insights — feeding the proposal step of the next loop iteration
and the init step of the next loop entirely. This closes a hill-climbing feedback
loop *inside* the control plane: the harness doesn't just execute a fixed proposal
step, it proposes its own next move based on evidence from its own audited past runs,
without loosening the kernel's read-only-for-skills invariant (insights are emitted
via the same atomic-write + append-anchored-event path as any other kernel write).
([Sungmin-Cho/claude-deep-loop](https://github.com/Sungmin-Cho/claude-deep-loop) v1.4.0, Jul 2026.)

## Harness-Agnostic Projection

A harness-agnostic design separates loop logic from the CLI or platform it runs on.
The pattern: define all agent roles, tools, and workflows in a single source directory
(`.apm/` or equivalent), then compile that source to the layout required by each target
harness (Claude Code, Codex, Copilot, Cursor, Gemini, Kiro).

Benefits:
- Portfolio-level consistency: same security, verification, and escalation policies apply across all harnesses
- Avoid lock-in: swap or add harness targets without rewriting loop logic
- Specialist agents (adversarial reviewer, security analyst) ship as portable units usable in any target harness

**A lighter-weight version of the same idea**: instead of compiling to each target's
native layout, put the control flow itself (decompose → fan-out workers → aggregate →
review gate, looping on a negative review) in ordinary code behind one adapter
interface (`Agent.run()`), so any backend — Claude, Codex, opencode, aider — plugs in
without the harness knowing which one it's talking to. The same orchestration then
exposes itself two ways: as an MCP server (callable from Claude Code, Cursor, Cline)
and as a standalone CLI, with long-running MCP calls returning a `run_id` immediately
and polling a cursor-based tail rather than blocking a request past its timeout.
([luckeyfaraday/athena-loops](https://github.com/luckeyfaraday/athena-loops), Jul 2026.)

**Security review at specification stage:** In a harness-agnostic design, a dedicated security agent
reviews the compiled harness specification *before* any implementation begins — not after.
Fixing a security gap at specification costs 1×; fixing it post-implementation costs 10×+.

**The `.apm/` primitive manifest** — the canonical source format for a harness-agnostic agent stores six primitive types in separate subdirectories:

| Subdirectory | Contents |
|---|---|
| `skills/` | Reusable workflow files (SKILL.md schemas) |
| `instructions/` | Role-specific system prompts and CLAUDE.md fragments |
| `hooks/` | PreToolUse/PostToolUse/Stop hook scripts |
| `prompts/` | Reusable prompt templates |
| `commands/` | Slash-command definitions |
| `tools/` | MCP tool configurations and API definitions |

The compiler reads `.apm/` and generates the harness-specific layout (`.claude/` for Claude Code, `.codex/` for Codex, etc.). Primitive files contain no CLI-specific directives — portability is enforced by convention, not tooling.

(sergiocarvalhosa/[Monad-Harness](https://github.com/sergiocarvalhosa/Monad-Harness), Jun 2026.)

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Jun 2026.)

## 8-Phase DAG Execution Model (Tenet)

An extension of the five-wave model for harnesses covering 12+ hour development cycles:

| Phase | Role |
|---|---|
| 1. Bootstrap | Load goal, context, and existing state |
| 2. Interview | Clarify ambiguities; gather constraints before any code is written |
| 3. Spec | Produce a typed, reviewable specification (not code) |
| 4. Visuals | Design/mockup pass if UI is in scope |
| 5. Decomposition | Break spec into DAG of parallelisable tasks |
| 6. Execution | Implement tasks; each task assigned to one agent context |
| 7. Evaluation | Independent critic pass per deliverable |
| 8. Agile | Retrospective; carry incomplete items forward as first-class work units |

**3-Critic Pipeline:** The evaluation phase deploys three independent critics, each running
in a fresh context window with no access to the original implementer's reasoning — only the
output artifact. Fresh context prevents critics from reasoning from the same anchors as the
implementer. Each critic scores independently; disagreements surface boundary conditions.

**Steer Message Taxonomy:** Mid-run course corrections use a typed taxonomy rather than
freeform messages, to prevent loop breakage:

| Type | When to use | Effect |
|---|---|---|
| `context` | New information the agent needs (API changed, requirement clarified) | Adds context; does not redirect |
| `directive` | Explicit redirect to a different approach | Cancels current subtask; redirects |
| `emergency` | Safety or security concern requiring immediate halt | Stops current execution; escalates |

Never inject a `directive` steer mid-subtask without first completing or cancelling the in-progress work.
Injecting a directive into a write operation without a task boundary risks ledger corruption.

([JeiKeiLim/tenet](https://github.com/JeiKeiLim/tenet), Jun 2026.)

## Meta-Harness: 3-Tier Policy Hierarchy

A meta-harness governs multiple sub-harnesses (Claude Code, Codex, Cursor) under a unified
policy layer. Policies are layered in three tiers, with later tiers overriding earlier ones:

| Tier | Scope | Typical controls |
|---|---|---|
| **Server** | Organisation-wide | Spend limits, denied tool categories, audit logging policy |
| **Agent** | Per-agent-type | Allowed tools, permission mode, model selection |
| **Session** | Per-invocation | Task-specific overrides, context injection, budget adjustment |

**Harness-swap without state loss:** Switch the underlying CLI (Claude Code → Codex, or vice versa)
mid-project by externalising all state to standard files (GOAL.md, STATE.md, CLAUDE.md) that any
harness can read. The agent's context resets; the project state persists.

**Cross-device session continuity:** Serialize the session ID and connection parameters at the start
of each run. Any device or runner that has the session ID can resume the session without
re-establishing context from scratch.

**Compaction persistence** — context compaction events are persisted alongside the session state. When a session resumes (`claude --resume`), the harness replays the compaction log to reconstruct the effective context without requiring the agent to re-read all prior files — reducing resume latency significantly on long sessions.

**Spec reconstruction on resolve-miss** — if the agent spec file is missing when the harness tries to resume, the harness reconstructs it from the stored session event log rather than aborting. This prevents crash-loop failures caused by missing config files.

([omnigent-ai/omnigent](https://github.com/omnigent-ai/omnigent), Jun 2026.)

## Alternative Harness Architectures

The default pattern is a persistent orchestration graph (LangGraph, custom state
machine) where the loop retains state across turns. Two lighter alternatives:

### Event-Driven Architecture (EDA)

Rather than a persistent orchestration process, agents become lightweight **event
handlers** that subscribe to topics on a message broker (Kafka, AWS EventBridge):

```
Event source → broker topic → agent handler → output event → next topic
```

Each agent is stateless; state lives in the event stream. The loop is the sequence
of events, not a long-running process.

**Benefit:** Complexity scales as O(N) — adding a new agent adds one subscriber, not
a new edge in an O(N²) coordination graph.  
**Tradeoff:** Eventual consistency; asynchronous failures are harder to debug than
synchronous call stacks.

Use EDA when: you have many agent types that each do one thing, you need elastic
scaling, or you want natural audit trails (events are immutable and replayable).

### Serverless Loops

Stateless functions with hard execution time limits (e.g. 15 minutes on AWS Lambda):

- Each loop iteration is one function invocation — forced reset, no accumulated context
- Memory is externalised to Redis / PostgreSQL / S3 between invocations
- Hard timeout prevents infinite loop incidents without requiring a separate circuit breaker

**Benefit:** Elastic scaling, cost containment by construction (you pay per invocation,
not per idle minute), and the timeout acts as a built-in stopping condition.  
**Tradeoff:** Cold start latency; agents must read external state at the start of
every invocation.

Use serverless when: iterations are bounded and short, state is well-defined enough
to serialise, or you are operating in a cost-sensitive production environment.

(Paramveer Singh, ["Designing Autonomous AI Loops: A Practical Guide to Loop Engineering"](https://medium.com/@paramveers9451/designing-autonomous-ai-loops-a-practical-guide-to-loop-engineering-895f1f01d250), Jun 2026.)

## Agent YAML Definition Schema

Rather than configuring agents through CLI flags or code, defining an agent declaratively
as a YAML file makes it portable, auditable, and harness-agnostic:

```yaml
# github_agent.yaml (Omnigent-style)
name: github_agent
prompt: |
  You are a GitHub automation agent. Triage open issues, label them,
  and draft PR descriptions for ready branches.

executor:
  harness: claude-sdk    # or: openai-agents, codex, cursor, kiro-native, copilot, kimi,
                         #     antigravity (Gemini), qwen, pi, hermes, ...
  model: claude-sonnet-4-6
  auth:
    type: api_key
    env: ANTHROPIC_API_KEY

tools:
  github:
    type: mcp
    url: https://api.githubcopilot.com/mcp/

policies:
  session_budget:
    handler: cost.budget
    factory_params:
      ask_thresholds_usd: [5.00]   # ASK mid-run before hard cap
      max_cost_usd: 10.00          # Hard DENY

os_env: true        # expose local file/shell tools
async: true         # async work tools
cancellable: true
```

The `executor.harness` field drives which runtime executes the agent — the same YAML
compiles to a Claude Code session, an OpenAI Agents SDK agent, a Codex CLI agent, or any
of 15+ harnesses without changing the agent's instructions or tool definitions.

([omnigent-ai/omnigent](https://github.com/omnigent-ai/omnigent), Jun 2026.)

## Organizational Learning Stage

A mature loop has a 4th stage beyond the standard 3 (Plan → Execute → Review):

**Stage 4: Organizational Learning**

When a loop completes a run, it identifies implicit conventions discovered during
the run — patterns the team uses but has never written down. These discoveries
are surfaced as *proposed edits to project documentation*, not automatic writes.

Examples of discovered conventions:
- "All PR descriptions in this repo end with a test output block" (discovered after 5 PRs)
- "Migrations always run in a transaction" (discovered from existing migration files)
- "Functions touching payments have a `# AUDIT:` comment" (discovered from grep)

The loop proposes the edit; a human reviews and accepts or rejects it before it
becomes a standing rule. This is distinct from the Cross-Task Defect Ledger
([Verification](04-verification.md)) which tracks *failures* — Organizational Learning
tracks *implicit conventions*.

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Jun 2026.)

## Harness Update File Safety Contract

When the harness ships updates that modify shared files (CLAUDE.md, loop templates,
skill definitions), a naive update would overwrite local customizations.

The safe pattern: when an upstream harness change collides with a locally-modified file,
place the upstream version as a `.upstream` companion file rather than overwriting:

```
CLAUDE.md           ← your local version (protected, never overwritten)
CLAUDE.md.upstream  ← what the harness update wants to write
```

The human reviews the diff between the two and manually merges what they want to adopt.
No convention, rule, or template update ever auto-applies without explicit human acceptance.
This is especially important for CLAUDE.md and skill files, where silent overwrites would
change the loop's behavior without a visible change in any monitored file.

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Jun 2026.)
