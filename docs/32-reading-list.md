# Loop Engineering — Reading List

A curated, slim collection of the best reading on loop engineering — articles,
essays, and reference implementations. **Content is selected for depth and longevity,
not recency.** Weaker pieces are removed when better ones arrive; the list stays
short by design.

Each entry records why it earned a place — a reference for future curation decisions.

---

## Why Loops: The Case for the Shift

Articles that establish *why* the shift from prompting to loop design matters.
These belong in every practitioner's reading queue before anything else.

---

### [Loop Engineering](https://addyosmani.com/blog/loop-engineering/) — Addy Osmani
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** The founding document of loop engineering as a named discipline.
Osmani coined the vocabulary adopted by the whole community — "replace yourself as
the person who prompts the agent" — and defined the New Software Lifecycle
(spec quality and verification replace implementation speed).

**Summary:** Argues that AI agents have collapsed implementation speed, shifting the
engineering bottleneck to specification quality and verification. Defines loop
engineering as the practice of designing the system that prompts the agent instead of
prompting it yourself. Introduces the Explore → Plan → Implement → Commit workflow
and the concept of "vibe coding" as the new technical debt.

---

### [The Anthropic leader who built Claude Code now writes loops](https://thenewstack.io/loop-engineering/) — The New Stack
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** Primary source — Boris Cherny (Claude Code's creator) in his own words.
The phrase "my job is to write loops" comes from this piece. Gives the creator's
framing of where the discipline is headed, not a third-party interpretation.

**Summary:** Interview with Boris Cherny explaining the shift from prompt engineering
to loop engineering. Describes how Anthropic internally structures agent workflows,
why the terminal is just the first surface ("Claude Everywhere"), and how the role
of a software engineer changes when implementation is no longer the bottleneck.

---

### [Loop Engineering: Designing the Execution Harness Around an LLM](https://medium.com/p/loop-engineering-designing-the-execution-harness-around-an-llm-936afeb6a72d) — @roanbrasil
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** The best quantified argument for loops over single-turn prompting.
The 0.9^10 = 35% compound probability example is the sharpest demonstration that
reliability requires a correction loop, not a better model.

**Summary:** Proves mathematically why single-turn invocations fail for complex tasks:
10 sequential decisions each at 90% accuracy yields only 35% end-to-end success.
Argues the performance ceiling of any LLM system is set by the loop quality, not
the model. "A mediocre model inside a well-engineered loop outperforms a frontier
model invoked once." Frames the historical progression: 2022 (f(prompt)→answer) →
2023 (LangChain agent loops) → 2024–2026 (stabilised harness architecture).

---

### [The Coming Loop](https://lucumr.pocoo.org/2026/6/23/the-coming-loop/) — Armin Ronacher
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** The necessary counterpoint. Flask's creator identifies two failure modes
that optimists miss — amplification effect and cognitive dependency — and defines
the domains where loops genuinely work. Reading only pro-loop material produces
brittle practitioners; this article prevents that.

**Summary:** Names the amplification effect (each loop iteration adds defensive
complexity, making systems less understandable while appearing more robust) and
cognitive dependency (codebases become unmaintainable without permanent AI
participation). Argues loop-generated code exhibits weaker invariants and unnecessary
complexity. Also defines where loops legitimately excel: code porting, performance
benchmarking, security scanning, research exploration, and disposable outputs.
Essential reading before deploying loops in production systems.

---

## Getting Started: Practical How-Tos

Tutorials, walkthroughs, and frameworks for writing your first loops.

---

### [AI Loop Engineering: Build Autonomous Agents with Claude Code /goal + Routines](https://www.sabrina.dev/p/loop-engineering-claude-code-goal-routines) — Sabrina Ramonov
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** The most direct step-by-step tutorial for loop engineering with
Claude Code specifically. Introduces three of the most-cited concepts in the
community: DOER/CHECKER, the AI Leverage Formula, and the stopping-condition test.
Practical, opinionated, and reproducible.

**Summary:** Covers the DOER/CHECKER pattern ("never let the AI grade its own output"),
the AI Leverage Formula (AI Output = Your Skill × Your Clarity), and the stopping
condition prerequisite: "If you can't say what done looks like, you don't have a loop.
You have a wish." Demonstrates building an autonomous loop using /goal and Routines,
with concrete examples of bounded vs. unbounded tasks.

---

### [Agentic Loops: From ReAct to Loop Engineering (2026 Guide)](https://datasciencedojo.com/blog/agentic-loops-explained-from-react-to-loop-engineering-2026-guide/) — Data Science Dojo
**Added:** 2026-06-24 · **Published:** 2026

**Why here:** Best taxonomy of loop evolution for practitioners who need historical
context. The Inner/Outer Dual Loop pattern is uniquely well-explained here and not
documented as clearly elsewhere.

**Summary:** Four-generation taxonomy: AutoGPT-era (2023) → ReAct (2024) →
OODA/Dual Loop → Ralph/goal loops (2026). The Inner/Outer Dual Loop: an outer loop
monitors the inner loop and resets strategy when it fails repeatedly, preventing
the agent from grinding indefinitely on a blocked sub-goal. Includes cost benchmarks:
~4× tokens for single-agent loops, ~15× for multi-agent, vs. standard chat.

---

### [How I AI: How to write AI agent loops in Claude Code and Codex](https://www.lennysnewsletter.com/p/how-i-ai-how-to-write-ai-agent-loops) — Claire Vo / Lenny's Newsletter
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** Introduces job-description framing — the most intuitive technique for
writing loop prompts that practitioners with a product background can apply
immediately without deep engineering knowledge.

**Summary:** Covers heartbeat/cron/hook/goal loop types with live demos. The key
contribution is job-description framing: write loop prompts as employee onboarding
documents (frequency, output deliverables, escalation contacts, performance standard)
rather than technical specifications. The framing captures intent and judgment
boundaries — exactly what an autonomous loop needs to act without constant supervision.

---

### [Loop Engineering for 0-to-1 Product Development](https://info.deeplearning.ai/a-new-generation-studies-ai-apples-recipe-for-on-device-models-glm5.2-tackles-open-ended-problems-1) — Andrew Ng (The Batch)
**Added:** 2026-06-26 · **Published:** Jun 2026

**Why here:** The clearest mental model for *where the human fits* once loops run the
implementation, from one of the field's most authoritative voices. The three-nested-
feedback-loops framing (and the "context advantage" that keeps humans necessary) is
not articulated this cleanly anywhere else in the list.

**Summary:** Frames AI-powered product development as three interconnected feedback
loops at different cadences: the agentic coding loop (agents build and test a new
version every few minutes), the developer feedback loop (humans review at intervals of
tens of minutes to hours), and the external feedback loop (user data over days). The
better the inner loop closes itself, the longer agents "work productively without human
intervention" — but the human loop persists because humans hold a *context advantage*:
they understand user needs better than current AI. The engineer's role becomes holding
the context the agent lacks and steering at the cadence the agent cannot self-correct.

---

## Harness Design & Architecture

Deep-dive articles on the engineering of the harness — the scaffolding around the agent.

---

### [Harness Design for Long-Running Application Development](https://www.anthropic.com/engineering/harness-design-long-running-apps) — Anthropic Engineering (Prithvi Rajasekaran)
**Added:** 2026-06-24 · **Published:** Mar 2026

**Why here:** The authoritative first-party reference on harness design. Real cost
data, the three-agent architecture, and the "load-bearing vs. optional" principle are
not available elsewhere at this level of detail and credibility.

**Summary:** Documents Anthropic's own harness evolution from a two-part (initializer +
coding agent) to a three-agent system (Planner + Generator + QA/Evaluator). Introduces
sprint contracts (generator and evaluator negotiate 20+ testable criteria before each
build phase), the load-bearing vs. optional principle (re-baseline complexity with each
model release), and real cost benchmarks: solo agent $9/20min (broken) vs. full harness
$200/6h (working). Key finding: Claude Sonnet 4.5 required context resets; Opus 4.6
largely eliminated the need.

---

### [How Claude Mythos found a 15-year-old bug in Mozilla Firefox](https://www.lennysnewsletter.com/p/how-claude-mythos-found-a-15-year) — Brian Grinstead / Lenny's Newsletter
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** The best published case study of a production security harness.
Concrete, verified, with outcome data (423 fixes) and the engineer's direct
attribution split between model and harness. Most articles describe patterns;
this one shows a working harness at scale.

**Summary:** Describes a modular security harness built on top of Claude for Mozilla
Firefox: LLM scoring to prioritize files by bug likelihood before allocating agents,
a mandatory score→fix→verify pipeline where each stage cannot be skipped, and a
dedicated verifier subagent separate from the bug-finder. Result: 423 security fixes
in one month. Grinstead attributes ~50% of results to the harness architecture and
~50% to model capability — the harness is not incidental.

---

### [Loop Engineering: Why You Should Never Argue with an Agent](https://www.linkedin.com/pulse/loop-engineering-why-you-should-never-argue-agent-martin-dilger-uql8e/) — Martin Dilger
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** Best practical treatment of mid-loop agent behaviour and the iteration
discipline that prevents context pollution. The Never Argue rule and Event Modeling
are immediately applicable to anyone running multi-turn agent sessions.

**Summary:** Establishes the Never Argue rule: agents don't learn from corrections,
they agree and carry the confusion forward — extended back-and-forth accumulates
"decision noise" that degrades output predictably. Introduces Event Modeling: slice
work into discrete status-transition units (Planned → In Progress → Blocked → Done),
execute each in one clean context window, record learnings, clear context, restart.
"Clean iterations with recorded learnings will outperform long, polluted conversations
every single time."

---

### [Harness Books](https://harness-books.agentway.dev) — AgentWay (wquguru)
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** The most rigorous theoretical treatment of harness design published to
date. Introduces the "unstable components" axiom as a foundational stance, ledger
closure (every tool_use must pair with tool_result), input governance pipeline, and
the runtime republic vs. constitutional control plane distinction — concepts not
covered at this depth elsewhere.

**Summary:** A collection of essays arguing the model is an unreliable runtime
component requiring containment, not a collaborator requiring instructions. Key
contributions: ledger closure for interrupted tool calls, five-step input governance
pipeline (prefetch/snip/microcompact/collapse/autocompact), reactive compact with
circuit breaker (reserve 20K output tokens, early-warning at 13K remaining, halt
after 3 consecutive failures), synthesis as the non-delegable orchestration bottleneck,
and the runtime republic (Claude Code) vs. constitutional control plane (Codex) framing.
Essential reading once you have working harnesses and want to make them production-grade.

---

### [Building Effective Agents](https://www.anthropic.com/news/building-effective-agents) — Anthropic
**Added:** 2026-06-26 · **Published:** Dec 2024

**Why here:** The canonical first-party reference for agent workflow architecture. The five patterns defined here — evaluator-optimizer especially — are the vocabulary the entire field now uses, regardless of whether practitioners trace it back to this document. Pre-dates "loop engineering" as a named discipline but is the foundational design reference every serious practitioner converges on.

**Summary:** Defines five composable patterns for multi-step agent systems: prompt chaining (sequential processing where each call processes the previous output), routing (a classifier directs each input to a specialised sub-pipeline), parallelization (independent sub-tasks fan out in parallel, outputs aggregated), orchestrator-workers (coordinator breaks the task down; specialist agents execute sub-tasks), and evaluator-optimizer (generator and evaluator alternate until the evaluator's criteria are met — the canonical maker/checker loop). Includes guidance on when not to use agentic frameworks and how to design for reliability in each pattern.

---

## Self-Improving Harnesses

Research on harnesses that optimize *themselves* — the harness as an evolvable
artifact with measurable, benchmarked returns, not a fixed human-authored wrapper.

---

### [Agentic Harness Engineering: Observability-Driven Automatic Evolution of Coding-Agent Harnesses](https://arxiv.org/abs/2604.25850) — arXiv 2604.25850
**Added:** 2026-07-02 · **Published:** Apr 2026

**Why here:** The strongest evidence to date that a harness can improve itself and *beat a
human-designed baseline* — and the only source that isolates *which* harness components carry
the gains (ablation), which no other entry in the KB does.

**Summary:** Automates harness evolution on three observability pillars: component observability
(each editable element is file-level, explicit, reversible), experience observability (raw
trajectories → a layered evidence corpus), and decision observability (every edit ships a
self-declared prediction later verified against the next round's outcomes — a falsifiable
maker/checker contract applied to the harness's own changes). Results: Terminal-Bench 2 Pass@1
69.7%→77.0% over 10 iterations, beating the human-designed Codex-CLI baseline (71.9%); top
SWE-bench-verified aggregate with 12% fewer tokens than the seed harness; cross-family transfer
+5.1 to +10.1pp. Ablation: gains come from tools, middleware, and memory — not system prompts.

---

### [Self-Harness: Harnesses That Improve Themselves](https://arxiv.org/abs/2606.09498) — arXiv 2606.09498
**Added:** 2026-07-02 · **Published:** Jun 2026

**Why here:** The cleanest statement of the self-improvement *loop* — a three-stage procedure an
agent can run on its own traces with no stronger external model or human engineer — and the
first to report per-model gains from turning weaknesses into executable harness edits.

**Summary:** A three-stage loop: (1) Weakness Mining extracts model-specific failure patterns
from execution traces; (2) Harness Proposal generates targeted, minimal harness edits addressing
them; (3) Proposal Validation regression-tests each candidate before acceptance. Key claim: it
converts model-specific weaknesses into concrete, executable harness changes rather than generic
prompt instructions. Terminal-Bench-2.0 gains with the model held fixed: MiniMax M2.5 40.5%→61.9%,
Qwen3.5-35B-A3B 23.8%→38.1%, GLM-5 42.9%→57.1% (up to +21.4pp absolute).

---

### [Don't Train the Model, Evolve the Harness](https://huggingface.co/spaces/joelniklaus/harness-optimization) — Hugging Face (Joel Niklaus)
**Added:** 2026-07-04 · **Published:** Jul 2026

**Why here:** The sharpest *cost* evidence in this group — the other two entries report
accuracy gains with the model held fixed; this one reports a **7x cost reduction** at
matched accuracy, and isolates harness quality as the sole variable across a 3.5%–80.1%
score range with model and tasks both held constant.

**Summary:** A proposer/accept-reject loop rewrites only the harness code around a frozen
model, evaluated on a legal-agent benchmark. The evolved harness matches Sonnet 4.6's score
at roughly 7x lower inference cost; holding model and tasks fixed, score varies from 3.5%
to 80.1% depending solely on harness quality. Reinforces the KB's central thesis — the
harness, not the model, is the leverage point — with a cost multiplier attached rather
than only an accuracy delta.

---

### [HarnessX: A Composable, Adaptive, and Evolvable Agent Harness Foundry](https://arxiv.org/abs/2606.14249) — arXiv 2606.14249
**Added:** 2026-07-06 · **Published:** Jun 2026

**Why here:** The only entry in this group that frames harness components as a
**substitution algebra** (any typed primitive can be swapped for an equivalent) rather
than an ad-hoc set of editable parts — a structural contribution the other two entries
don't make, and the paper most directly cited elsewhere in this KB ([docs/24](24-harness-patterns.md)).

**Summary:** Frames runtime components — prompts, tools, memory, control flow — as typed
harness primitives over a substitution algebra, with an evolution engine (AEGIS) that
refines them from execution traces. Reports +14.5% average gains across five benchmarks
(ALFWorld, GAIA, WebShop, and two others), up to +44.0%. Distinct from Self-Harness
(weakness-mining loop) and AHE (observability pillars) by contributing the *typing and
substitution* formalism underneath both.

---

## Goal Engineering & Stopping Conditions

The stopping condition is where most loops fail. These articles address it directly.

---

### [Goal Engineering](https://cobusgreyling.substack.com/p/goal-engineering) — Cobus Greyling
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** Introduces a formal vocabulary that the broader community lacks: the
Goals vs. Loops distinction and the four Goal Primitives. Fills the gap between
"define a good stopping condition" (advice) and the specific mechanism (GOAL.md,
Verifier, Budget) for achieving it.

**Summary:** Draws a decision boundary: if the work is recurring → Loop; if it has
a deterministic completion state → Goal. Defines four Goal Primitives: (1) Objective
(bounded, verifiable statement), (2) Verifier (independent validation — tests, CI,
subagent), (3) State (GOAL.md file persisting across context resets), (4) Budget
(turn/token caps). GOAL.md is the key practical contribution: a lightweight file
agents write and read between iterations to survive context resets without losing
progress or re-doing completed work.

---

## Loops in Production

Articles documenting real deployed systems using loop engineering.

---

### [Introducing Claude Tag](https://www.anthropic.com/news/introducing-claude-tag) — Anthropic
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** The first deployed product that makes loop engineering visible to
non-engineers. Claude Tag is loop engineering manifested as a team tool — ambient,
self-scheduling, org-aware. It concretises Karpathy's "third LLM paradigm" and
Cherny's "Claude Everywhere" thesis in a form you can demo to a stakeholder.

**Summary:** Claude Tag is Claude Code deployed as a persistent Slack agent.
Architecture: channel-scoped instances with isolated memory and tool access,
ambient context built from channel history, self-scheduling (plans follow-ups
autonomously over hours or days), isolated sandbox per task invocation. Governance:
token caps per org/channel, audit logging, role-based memory separation. Signal:
65% of Anthropic's product team code is created using their internal version.
"The beginning of an evolution of Claude Code: more proactive, works better with
a full team."

---

### [No Figma. No Jira. No docs. How Gusto built a new product line with Claude Code](https://www.lennysnewsletter.com/p/no-figma-no-jira-no-docs-how-gusto) — Eddie Kim (Gusto CTO) / Lenny's Newsletter
**Added:** 2026-06-30 · **Published:** Jun 2026

**Why here:** The clearest case study of *process replacement* under loop engineering, with
hard outcome data. Where the Firefox study shows a security harness at scale, this shows a
whole product org restructured around loops — and names a concrete, reusable practice (the
"trash-can method") that the other production entries do not.

**Summary:** A five-person Gusto team shipped a tier-one AI product in ten weeks by treating
Claude Code as a primary team member and discarding the usual process artifacts (Figma, Jira,
spec docs). The headline practice is the **trash-can method**: Claude-generated PRs become
*disposable product proposals* — most are closed/discarded, making failed experiments cheap
and letting non-engineers ship features that developers later refine. Bug-fixing runs an
eval-first loop (write a reproducing eval/test, fix, re-run as the stopping condition, gate on
human review before commit). The lesson is organizational: the bottleneck moved from
implementation to deciding which disposable proposal is worth keeping.

---

## Reference Implementations

Open-source projects demonstrating complete loop engineering implementations.
Curated for depth of design and breadth of patterns covered — not for popularity.

---

### [goal-engineering](https://github.com/cobusgreyling/goal-engineering) — Cobus Greyling
**Added:** 2026-06-25 · **Published:** Jun 2026

**Why here:** The only reference implementation that provides both a GOAL.md schema
and a readiness scoring tool (G0–G3). Fills the gap between the "write a good stopping
condition" principle and a reproducible implementation pattern with six canonical goal templates.

**Summary:** Six canonical goal patterns (Tests Green, Migrate Module, Fix Bug, Refactor,
Docs Update, Security Scan) each with a typed GOAL.md template, done conditions, and natural
verifier. Includes a G0–G3 readiness scoring tool (run before launching a goal to verify
objective clarity, verifier independence, state file presence, and budget definition) and
a goal-cost estimator that predicts token spend from objective scope.

---

### [fleet-engineering](https://github.com/cobusgreyling/fleet-engineering) — Cobus Greyling
**Added:** 2026-06-25 · **Published:** Jun 2026

**Why here:** The only published reference implementation for fleet-level governance. The
six production patterns and Fleet Economics cost attribution framework are not documented at
this level of operational detail elsewhere — including F0–F3 maturity gates, Claw vs.
Assistant identity choice, and fleet-budget.md as a first-class artefact.

**Summary:** Six production fleet patterns: Team Registry, Shared Inbox HITL, Hierarchical
Delegation, Fleet Budget Guard, Cross-Agent Audit, and Fleet Economics. The Fleet Budget Guard
pattern implements per-agent and per-fleet spend ceilings with automatic rollback on breach.
Fleet Economics introduces cost attribution as a fleet primitive — identifying which agent
generated a runaway cost event is a prerequisite for F2 governance, not an optional feature.

---

### [session-orchestrator](https://github.com/Kanevry/session-orchestrator) — Kanevry
**Added:** 2026-06-24 · **Published:** Jun 2026

**Why here:** The most complete reference implementation combining patterns from
across the whole field: five-wave execution model, confidence-scored inter-wave gates,
STATE.md wave crash recovery, governed cross-session learning, scope-verified
parallelism via Pre-Edit hooks, and explicit hook exit code safety contract. Ideal
to study before building a production orchestrator from scratch.

**Summary:** Implements a five-wave sequential architecture (Discovery → Impl-Core →
Impl-Polish → Quality → Finalization) where Wave 4 is a dedicated simplification pass
run before test authoring — preventing tests from cementing suboptimal AI-generated
code. Inter-wave quality gates are confidence-scored (≥80% threshold). STATE.md
tracks wave-level execution so crashes resume from the last completed wave rather than
from the start. The /evolve + /reconcile commands enable governed cross-session pattern
extraction where no rule auto-applies without human review.

---

### [loop-kernel](https://github.com/uppifyagency/loop-kernel) — uppifyagency
**Added:** 2026-06-28 · **Published:** Jun 2026

**Why here:** The smallest reference implementation that makes the stopping-condition
taxonomy concrete and *provable*. Where other repos describe stop conditions, this one
ships them as three deterministic exit codes with an external, unfakeable verifier —
the cleanest illustration of "the control system is fixed; the worker is swappable."

**Summary:** An autonomous loop that provably halts via three hard stops: success
(`exit 0`, the real check passes), no-progress (`exit 3`, the objective score stays
flat for K iterations), and cap (`exit 2`, hard iteration ceiling). Two ideas stand
out: the kernel runs the real check every iteration so the worker cannot fake
completion, and progress is defined as *the score moving* (a `score=<fraction>`
contract), not files changing — "a busy-but-stuck agent still halts." A LEDGER keeps
the judge's checklist alive across context compaction, and every wave must paste proof
("an unproven wave never counts").

---

### [Strive_Engineering](https://github.com/krishddd/Strive_Engineering) — krishddd
**Added:** 2026-06-29 · **Published:** Jun 2026

**Why here:** Where loop-kernel makes the *check* unfakeable, this repo makes the
*report* unfakeable — the cleanest implementation of provenance-bound verification, a
technique none of the other reference implementations demonstrate. It answers the
failure where an agent fabricates evidence ("fixed at commit X") that no artifact backs.

**Summary:** A loop-engineering runtime built on an L0-L3 autonomy ladder where every
finding must cite a real git SHA, and a guard (`loopguard`) re-verifies the citation
against the object store via `git cat-file` before accepting the claim — a citation that
points at no matching artifact is rejected automatically. Layered on top: diff-integrity
and prompt-injection scanning, and a `majority_vote` across independent judges so no
single grader the worker could collude with can wave work through. Together these
generalise the external-verifier idea from "re-run the check" to "bind every claim to an
inspectable, unforgeable artifact and have more than one judge confirm it."

---
