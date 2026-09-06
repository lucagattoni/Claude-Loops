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
([arXiv 2606.12344](http://arxiv.org/abs/2606.12344), Jun 2026.) A smaller independent
pilot corroborates the pattern at the opposite end of the scale: comparing Claude Code
against the Pi harness on 19 Terminal-Bench tasks with the model pinned identical, both
harnesses reached the **same 87.7% task success rate**, but Claude Code used **5.2x more
tokens (geometric mean)** to get there — after the author corrected an initial pass that
had shown a contaminated 7-14x gap. Read together with the StaminaBench/Claw-SWE-Bench
results above: harness choice can move *either* the success rate or the cost at matched
success, and a harness comparison that only measures one of the two will miss which lever
actually moved. ([nmlemus/harness-token-efficiency](https://github.com/nmlemus/harness-token-efficiency), Sep 2026.)

### Two Settings Tripled a Benchmark Score — and the Vendor Didn't Sell the Harness

The sharpest evidence yet for "the harness matters more than the model" came from a vendor
demonstrating it about *itself*. OpenAI found that the "official" ARC-AGI-3 harness was
**erasing the model's private reasoning and truncating its history every move** — enabling
reasoning-retention plus context compaction **tripled the score (13.3%→38.3%) at 1/6th the
tokens**, with the model held completely fixed.
([OpenAI, "How enabling two settings tripled our scores on the ARC-AGI-3 benchmark"](https://openai.com/index/how-two-settings-tripled-our-arc-agi-3-scores), Jul 2026.) The
compaction mechanism itself — opaque, loss-aware, server-side compression of prior
reasoning/tool calls — is documented as a first-class API primitive precisely because
naive truncation this badly starves a long-running loop of exactly the context it needs to
avoid repeating dead ends.
([OpenAI, Compaction developer guide](https://developers.openai.com/api/docs/guides/compaction), Jul 2026.)

The same pattern recurred at the other end of 2026, this time *without* the vendor's own
admission. GPT-6 Astra's headline **98.6% ARC-AGI-3 score came from an undisclosed
evaluation harness/system** wrapped around the model — a harness OpenAI does not sell to
developers — rather than the raw model under conditions anyone could reproduce.
([The New Stack, "OpenAI will sell you Astra, but not the system that scored 98.6%"](https://thenewstack.io/openai-astra-harness-arc-agi-3/); [The New Stack, "GPT-6 Astra's score of 98.6% looked like AGI. Then researchers read the fine print."](https://thenewstack.io/astra-arc-agi-benchmark/), Sep 2026.) Read the two events together and the lesson sharpens past
"the harness matters": a vendor that understands this thesis has an incentive to under-disclose
which parts of a benchmark score are harness rather than model — see
[Benchmark and Eval Integrity](04-verification.md#benchmark-and-eval-integrity-sept-2026-corpus)
for the verification-side treatment of the same disclosure gap.

**Persistent "megathreads" as the harness-level fix for long-running work.** A companion
practice guide from the same period generalizes the reasoning-retention lesson into a
standing recommendation: keep one long-lived agent thread alive and deliberately compact it
on purpose (rather than starting fresh each task), decompose goals into independently
verifiable steps, and decide upfront which steps get full delegation versus which keep a
human checkpoint. This is the harness-design counterpart to
[Long-Running Agents](25-long-running-agents.md)' session-recovery patterns — persistence by
keeping the thread alive, rather than by reconstructing state after a reset.
([OpenAI, "Codex-maxxing for long-running work"](https://openai.com/index/codex-maxxing-long-running-work), Jun 2026.)

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

**A first-party production instance: Warp's inner/outer skill split.** An inner (base) skill
does the actual per-task work (e.g. PR review); an outer "improver" skill runs as a
**scheduled observer, not per-task** — it pulls accumulated human feedback, compares what
the base skill suggested against how humans actually responded, and proposes a small,
focused edit to the base skill. Critically, the update path is not autonomous: "these
updates, which are reviewable, approvable, and mergeable, can flow through a normal
PR/code-review workflow; once merged, the next run of the inner skill inherits the
improvement." Warp runs this same pattern across separate spec-writing, review, and triage
agents, each carrying its own self-improvement loop — a concrete, shipped answer to "who
improves the harness" that keeps a human gate on every change, unlike the fully autonomous
research systems below. ([Anthropic, "How Warp builds self-improving agents on
Claude"](https://claude.com/blog/how-warp-builds-self-improving-agents-on-claude), Aug 2026.)

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

**Fix the process, not the code (Bun case study).** The self-improving-harness research
above assumes an automated optimizer; the same discipline works manually and is easy to
skip under time pressure. During Bun's 11-day, 64-parallel-instance Zig→Rust rewrite,
Claude instances began repeatedly running dangerous git commands (`git stash`, `git
reset`) mid-task. The response was not to intervene per-instance or hand-fix the
resulting damage — it was to edit the workflow instructions once, globally, so the fix
applied to every future instance rather than the one caught in the act. The author's own
framing: "fixed the process that generates the code instead of hand-fixing the code."
This is the manual, single-engineer version of what
[Self-Harness](#self-improving-harnesses) and [AHE](#self-improving-harnesses) do with an
automated weakness-mining step — the failure class, not the individual failure, is what
gets patched. ([Bun, "Bun, in Rust"](https://bun.com/blog/bun-in-rust), Jul 2026.)

**JIT-Agent — harness intelligence as a trainable dimension, orthogonal to model scale.**
Rather than evolving one fixed harness, a trained model synthesizes a **task-adaptive**
harness on-the-fly for whatever off-the-shelf LLM it is paired with — enabling a smaller
model with a JIT-synthesized harness to surpass a larger model running the generic default.
This reframes "harness intelligence" as a capability you can train *for*, not just a
one-time engineering artifact. ([arXiv 2608.25593, "JIT-Agent"](https://arxiv.org/abs/2608.25593), Aug 2026.)

**HarnessLens — cheaper verification for harness evolution.** The self-improving approaches
above all gate mutations on some form of re-evaluation; HarnessLens replaces full
re-evaluation with **behavior-aware verification**, improving held-out performance by
7.6–13.6% while using substantially less evaluation budget per candidate — the efficiency
counterpart to Darwin Mode's train/eval-disjoint *correctness* gate above: cheaper does not
mean less rigorous if the verification still catches regressions.
([arXiv 2608.27311, "Verify Smarter, Evolve Further"](https://arxiv.org/abs/2608.27311), Aug 2026.)

**EvoUndo — recoverability as its own gate, alongside correctness.** A framework that
checks whether a model's self-modification to its own harness is *recoverable* before
accepting it, independent of whether the mutation measurably improves performance. Oracle
analysis found 197 capability-improving mutations that failed a recoverability check; an
extended recovery calculus recovered 191 of the 197 — meaning most "good but risky"
mutations can be made safe rather than simply rejected outright. This closes a gap none of
the approaches above name explicitly: Darwin Mode gates on *whether a mutation helps*;
EvoUndo gates on *whether you can undo it if it doesn't*.
([arXiv 2608.28363, "EvoUndo"](https://arxiv.org/abs/2608.28363), Aug 2026.)

**HarnessDev — can a model build its own execution infrastructure from a minimal seed?**
Tests whether LLMs can construct and refine their own agent harness rather than only tuning
an existing one. Generated harnesses lag human-authored references on code and search tasks,
but match or exceed them on writing and ML-experimentation tasks — a domain-dependent
answer, not a uniform yes or no, to the question the self-improving-harness cluster above
otherwise treats as settled. ([arXiv 2609.01437, "HarnessDev"](https://arxiv.org/abs/2609.01437), Sep 2026.)

**Harness-of-Harness — a multi-day case study.** Coding agents iteratively improve their own
software via planning-coding-testing loops sustained over *multiple days*, reporting a
52.25% average relative gain across three benchmarks and, as a demonstration, autonomously
building a working FPS game over **70+ iterations**. This is the sharpest available evidence
that the self-improving-harness pattern holds up over genuinely long horizons, not just a
handful of iterations in a benchmark run — see
[Long-Running Agents](25-long-running-agents.md) for the session-continuity mechanics a run
this long depends on. ([arXiv 2609.01481, "Harness-of-Harness"](https://arxiv.org/abs/2609.01481), Sep 2026.)

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

## Generic Harness + Good Feedback Loop Beats Bespoke Scaffolding

A domain-specific evaluation of computer-aided-engineering (CAE) simulation agents found
that a **single-agent, generic multi-turn tool-use harness matches specialized systems**
built purpose-fit for the domain — and that execution-feedback repair (re-running the
simulation and reacting to the actual error) beats scripted reflection (a fixed
self-critique prompt) as the correction mechanism. This is direct evidence for
[When to Remove Harness](#when-to-remove-harness)'s removal test applied one level up: not
just "which components of *my* harness are load-bearing," but "do I need a bespoke harness
for this domain at all, or does a generic one plus a real feedback loop already match it."
([arXiv 2609.03718, "What Do CAE Simulation Agents Really Need Beyond a Generic Harness?"](https://arxiv.org/abs/2609.03718), Sep 2026.)

**Adversarial self-play as a harness-level robustness loop.** A red-teaming system using
self-play to generate multi-step adversarial attack paths and improve prompt-injection
robustness applies the same verification-loop/adversarial-review pattern this doc documents
for correctness ([Self-Improving Harnesses](#self-improving-harnesses)) to model *safety*
instead — the harness evolves against attacks the same way it evolves against task failures.
([OpenAI, "GPT-Red: Unlocking Self-Improvement for Robustness"](https://openai.com/index/unlocking-self-improvement-gpt-red), Jul 2026.)

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
- **Unified Harness Protocol (UHP)**: an open standardization attempt in the same
  direction — a self-hosted router exposing five harnesses (Codex, Claude Code, Hermes,
  Pi, DeepSeek Harness) behind one OpenAI-compatible API, with concurrent isolated-workspace
  sessions, SSE streaming, and cancellation. Notable for shipping a runnable, versioned
  conformance suite (`uhp-conformance --class full`) against a public spec, not just a
  wrapper library — 664 stars.
  ([HarnessRouter/harnessrouter](https://github.com/HarnessRouter/harnessrouter), Sep 2026.)
- **Official first-party version**: OpenAI's own Claude Code plugin implements the
  same reviewer-executor separation as a supported product, not a community skill —
  a `/codex:adversarial-review` command and an optional gate that **blocks Claude's
  response pending Codex's validation**. Notable because the pattern now has
  official backing from a *different* vendor, not just community consensus.
  ([openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc), Jul 2026.)

- **HydraFusion**: GitHub Copilot's own multi-model orchestration research preview,
  routing across Single/Cascade/Critique workflow shapes rather than picking one model per
  session — GitHub's announcement claims 4.9pp higher quality than Claude Opus 5 at 67%
  lower workflow cost on TerminalBench 2.1. Treat this as a competing vendor's *self-reported*
  benchmark rather than independently verified — but it is a first-party instance of a
  competitor betting on orchestration-shape choice, not model choice, as the lever, which
  corroborates this section's thesis regardless of whose numbers are right.
  ([GitHub, "Project HydraFusion"](https://github.blog/ai-and-ml/github-copilot/project-hydrafusion-frontier-quality-via-multi-model-orchestration/); [explainx.ai coverage](https://explainx.ai/blog/github-copilot-hydrafusion-multi-model-orchestration-2026), Sep 2026.)

- **Mechanically-enforced review-before-merge**: rather than trusting the orchestrating
  agent to run cross-model review before merging a worker's isolated-worktree branch, the
  merge operation itself blocks unless a review receipt matches the exact snapshot's
  session ID — the enforcement lives in the merge code path, not in a convention the
  agent could skip under time pressure.
  ([DrSeedon/orchestra](https://github.com/DrSeedon/orchestra), Sep 2026.)

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

## The Query Loop as System Heartbeat

A book-length treatment of Claude Code's own runtime argues the query loop — not the
model, not any single tool call — is the unit that determines system maturity. Analysis
of the published npm package identifies **nine tracked state variables** assembled into
one `State` object per conversation (`messages`, `toolUseContext`, `autoCompactTracking`,
`maxOutputTokensRecoveryCount`, `hasAttemptedReactiveCompact`, `pendingToolUseSummary`,
`stopHookActive`, `turnCount`, `transition`), and a strict **pre-model input governance
pipeline** that runs before the model ever sees a token: memory prefetch → skill-discovery
prefetch → truncate to compact-boundary → apply tool-result budget → history snip →
microcompact → context collapse → autocompact attempt. The thesis: governing input is the
runtime's job, done *before* inference, not left for the model to sort out mid-turn.

**Layered recovery** follows the same ascending-cost-and-destructiveness principle this KB
already applies elsewhere: a `prompt-too-long` error tries context collapse first and only
escalates to a full reactive compact if that's insufficient; a `max_output_tokens` cutoff
first raises the token cap, and only once the cap is already maxed does it append a
continuation message telling the model to resume from where it was cut off — never an
apology or a re-summary.

The analysis catalogues **eight distinct termination/recovery modes** in the stop-condition
matrix: stream ends with a pending tool call (follow-up), stream ends clean (stop hooks
fire), user interrupt (abort + synthetic tool-result for orphaned calls), recoverable
prompt-too-long (collapse, escalating to compact), output-cap-not-yet-maxed (raise and
retry), output-cap-already-maxed (continuation message), a stop-hook block recurring after
compact was already attempted (an explicit "double failure" guard that skips the hook and
surfaces the error directly rather than looping forever), and an API error (return
immediately, no retry). Compare this granularity to the [Stop Condition
Taxonomy](27-loop-contract.md#stop-condition-taxonomy) — the same idea, at the level of
one runtime's actual state machine rather than a design abstraction.

**Caveat:** this is a third-party technical analysis of Claude Code's published package
(chapter cites specific file/line references, e.g. `query.ts:203-217`), not an Anthropic
disclosure — treat the state-variable names and line numbers as this analysis's own
findings about a specific build, not a stable public API.
([Harness Books — AgentWay](https://harness-books.agentway.dev/book1-claude-code/chapter-03-query-loop-heartbeat.html), undated, fetched Sep 2026.)

### Ten Principles of Harness Engineering

The same book distills its analysis into ten principles, several of which this KB already
documents under different names — listed here as a compact index, cross-referenced rather
than restated:

1. Treat the model as an unstable component, not a colleague — see [The "Unstable Components" Design Axiom](#the-unstable-components-design-axiom)
2. The prompt is part of the control plane, alongside runtime, tool schema, memory, and hooks
3. **The query loop is the heartbeat of the agent system** — see above
4. Tools are managed/governed execution interfaces, not raw function calls
5. Context is working memory — governability matters more than quantity — see [Context Management](13-context-management.md)
6. **Error paths are the mainstream paths** — prompt-too-long, max-output-tokens, interrupts, hook loops, and compact failures are daily weather, not edge cases, and must be designed for up front
7. The goal of recovery is to keep working, not to apologize
8. Multi-agent's purpose is partitioning uncertainty — research/implementation/verification/synthesis run in separate containers, recombined by a coordinator — see [Subagents](07-subagents.md)
9. **Verification must be independent** — the system cannot grade its own homework — see [Verification](04-verification.md)
10. Team/organizational process matters more than individual skill — layered `CLAUDE.md`, explicit approvals, executable skills, lifecycle hooks, traceable transcripts, and a unified definition of "verified" across the team

([Harness Books — AgentWay, "Ten Principles of Harness Engineering"](https://harness-books.agentway.dev/book1-claude-code/chapter-09-ten-principles.html), undated, fetched Sep 2026.)

## Object-Oriented / Code-as-Action Agents (NOOA)

A third alternative to the persistent-orchestration-graph and event-driven/serverless
patterns above: model agents as **Python objects** rather than prompts or graph nodes.
NVIDIA-labs' NOOA (NVIDIA-labs Object-Oriented Agent framework) gives a class's
docstrings-as-prompts and lets methods with a literal `...` body be completed at runtime
by an LLM-driven agent loop, while methods with a normal body stay ordinary deterministic
Python — so control flow, state, and non-agentic logic are just code, and only the
genuinely agentic pieces are model-driven. The framework names six model-facing
capabilities it unifies onto one object: typed input/output, pass-by-reference over live
objects, code-as-action (the model acts by writing Python in a Jupyter-style REPL with
access to `self`, imports, and helpers), **"programmable loop engineering,"** explicit
object state, and model-callable harness APIs — replacing prompt templates, tool schemas,
callbacks, and workflow graphs with one substrate.

Reported results: **82.2% on SWE-bench Verified with GPT-5.5, at roughly half the token
cost of competing harnesses**; the paper additionally reports on Terminal-Bench 2.0 and
ARC-AGI-3. Fully open source, no GPU/NVIDIA hardware required — any local or API-based LLM
works. The open-source implementation ships as separate packages: `nooa-cli` (CLI + trace
viewer), `nooa-acp` (an Agent Client Protocol implementation for hosts like Zed),
`nooa-memory`, and `nooa-bench` (a Harbor benchmark runner) — Apache 2.0, 1,991 stars,
daily commit cadence as of Sep 2026.
([Cobus Greyling](https://cobusgreyling.substack.com/p/nvidia-labs-object-oriented-agent), Aug 2026;
[arXiv 2607.20709](https://arxiv.org/abs/2607.20709), Jul 2026;
[NVIDIA-NeMo/labs-OO-Agents](https://github.com/NVIDIA-NeMo/labs-OO-Agents), fetched Sep 2026.)

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

### YAML-Defined Process DAGs (Archon)

A different use of the same idea: rather than a YAML file defining *one agent's*
portable config (above), define an entire **coding process** as a YAML DAG whose nodes
mix deterministic steps (bash, scripts, test runs, git operations) with AI steps
(plan/implement/validate/review/PR), each node running in its own isolated git worktree.
The pitch is explicit: "Dockerfiles for infra, GitHub Actions for CI/CD, Archon for AI
coding workflows" — a process definition invoked identically from a CLI, a web UI, or
Slack/Telegram/GitHub triggers, addressing LLM-agent non-determinism by keeping the
control flow itself outside the model's discretion.

At 23,389 stars, 3,465 forks, and near-daily merged PRs, this is by a wide margin the
most externally validated harness-builder in this KB's corpus — a generalized workflow
engine rather than one more implementation of a fixed pattern, which is the gap most of
the small single-purpose harness repos surfaced alongside it do not fill.
([coleam00/archon](https://github.com/coleam00/archon), fetched Sep 2026.)

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

## When to Remove Harness

Everything above this line is accretion — a growing corpus of components to add. Harness
complexity is not a one-way ratchet: it is a **depreciating asset with a stated decay
direction**. Every component built on top of a moving platform is a liability with a
maturity date, not a permanent fixture.

> "Today's agents need much more scaffolding — that is, code that guides its step-by-step
> actions — rather than just letting an LLM have access to some tools and fully
> autonomously decide what to do."
>
> "Building a reliable agent today requires much more scaffolding to guide it; but as LLMs
> become more capable, we will see successful agents built with less scaffolding."
>
> — Andrew Ng, ["Build an Autonomous Agent Using This Simple Recipe!"](https://www.deeplearning.ai/the-batch/build-an-autonomous-agent-using-this-simple-recipe), Dec 2025

Six months later, Ng reports the prediction starting to hold — with coding agents named as
the leading edge, not the exception:

> "So far, most practical Agentic AI workflows (except for coding agents) have not relied on
> the LLM to this extent to decide what to do next. Instead, they have relied more on
> developer-specified workflows to deliver higher reliability. But in the past few months,
> frontier LLMs have advanced sufficiently for this style of harness design to provide an
> important, if still not entirely reliable, alternative."
>
> — Andrew Ng, ["Agents on the Desktop"](https://www.deeplearning.ai/the-batch/agents-on-the-desktop), Jun 2026

Read together: coding agents (Claude Code among them) were already leaning on the LLM to
decide more, before the rest of the field caught up. That does not exempt this doc from the
trend it documents — it means the trend arrives here *first*.

### The removal test

Ng also gives the operational criterion — not just the direction, but when to act on it:

> "For example, one very common pattern is ripping out scaffolding and letting the LLM do
> more. This is often a good move when you now have access to a smarter LLM than you did
> when you first built a workflow."
>
> — Andrew Ng, ["Evals and Error Analysis, Part 2"](https://www.deeplearning.ai/the-batch/improve-agentic-performance-with-evals-and-error-analysis-part-2), Oct 2025

And the diagnostic for *which* component to cut first:

> "One way to spot opportunities for doing this is if error analysis shows that a sequence
> of steps collectively underperforms compared to what a human might do, even though the
> performance of each individual step is good."
>
> — Andrew Ng, ["Evals and Error Analysis, Part 2"](https://www.deeplearning.ai/the-batch/improve-agentic-performance-with-evals-and-error-analysis-part-2), Oct 2025

That is a symptom of rigidity, not of insufficient scaffolding — a pipeline whose every step
scores well but whose combined output still lags a human is a case for removing a gate, not
adding one.

**A concrete removal test**, runnable against any component catalogued in this doc:

1. Re-run the task on the current frontier model with the component removed.
2. If quality holds, the component was load-bearing for an older, weaker model and is now
   pure overhead — remove it.
3. If quality drops, keep it, and repeat the test at the next model release rather than
   assuming the answer is permanent.

This doc already has one instance of the test applied concretely — see
[Load-Bearing vs. Optional Components](#load-bearing-vs-optional-components): sprint
decomposition was essential with Opus 4.5 and became removable overhead with Opus 4.6, found
by the same re-run-and-compare method.

**The engineering expression of the same idea** already lives in
[The Development Workflow](36-development-workflow.md#a-worked-reference-implementation):
ClaudeWarp's `/claude-warp-sync` skill retires each of its own components the moment Claude
Code ships the equivalent natively — "the harness is built to disappear." Read that section
for the mechanism; the rule it encodes is the one this section argues for: **a harness
should be designed to shrink, not just to grow.**

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
