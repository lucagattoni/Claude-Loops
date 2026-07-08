# Learned Orchestration

> Rather than coding the workflow, train the workflow.

## What it is

Learned orchestration is a multi-agent design pattern where the orchestrator itself is a
**trained model** rather than hand-written code. Instead of explicitly specifying which
sub-agent runs in which order, a learned orchestrator discovers the optimal coordination
strategy from data.

[Sakana AI](https://sakana.ai)'s **[Fugu](https://sakana.ai/fugu/)** (launched 22 June 2026) is the first production system to ship this
pattern as an API product: a 7B-parameter conductor model that learns to route tasks to a
pool of larger LLMs, assigning Thinker / Worker / Verifier roles dynamically per task.

---

## How it differs from a hand-designed loop

| Hand-designed loop | Learned orchestrator |
|---|---|
| You write the routing logic (`if plan_step then call planner_agent`) | The conductor model learns routing from training data |
| Adding a new agent type requires a code change | The orchestrator adapts to new agents without code changes |
| Failure modes are the ones you anticipated | The system can discover non-obvious collaboration sequences |
| Version-controlled, auditable DAG | Behaviour emerges from weights — harder to audit |

---

## The TRINITY / Conductor architecture ([Sakana Fugu](https://sakana.ai/fugu/))

Two ICLR 2026 papers underpin Fugu's design:

**TRINITY** — an evolved coordinator assigns adaptive roles across a pool of models:
- **Thinker**: deep reasoning about the problem
- **Worker**: execution — code generation, API calls, file writes
- **Verifier**: checks the worker's output before it returns to the caller

**Conductor** — uses reinforcement learning to discover "natural-language coordination
strategies": the communication prompts between agents are themselves learned, not
handcrafted.

---

## Loop engineering implications

1. **The harness as data, not code.** If orchestration can be learned, the harness becomes
   a training target rather than a codebase. This is a fundamentally different philosophy
   from the ClaudeWarp / hand-designed approach.

2. **Verification is still external.** Even learned orchestrators need humans (or a
   separate verification loop) to validate final outputs — the system doesn't know what
   it doesn't know.

3. **Provider-agnostic design matters more.** A learned orchestrator dynamically selects
   the best model for each sub-task; coupling your loop to a single provider blocks this.
   See [Failure Patterns](17-failure-patterns.md) → Provider lock-in.

---

## A Second Target for Learning: the Harness Itself, Not Just the Orchestrator

Fugu learns *which model does what* (orchestrator-as-trained-model). A distinct but
related idea trains the **harness as a control layer** while leaving the underlying
LLM frozen: treat the scaffolding around the model — retry policy, tool sequencing,
context management — as a learnable controller, trained via advantage-weighted
regression on execution traces rather than hand-coded if/else logic. The paper
introduces a **Harness Maturity Score** to make "how reliable is this harness's
execution pattern" a measured quantity rather than a judgment call, distinguishing
this from [Harness Patterns' self-improving harnesses](24-harness-patterns.md#self-improving-harnesses)
(which mutate the harness's *code*) by instead training a *policy* that sits on top
of a fixed harness. ([arXiv 2607.05458](http://arxiv.org/abs/2607.05458), Jul 2026.)

A hand-designed analog of the same instinct — replan rather than restart on failure —
appears in a large agent meta-harness's **Replanning Loop**: a GOAP-style A* planner
decomposes a goal into an action sequence and replans specifically from the point of
failure when state changes invalidate the current plan, instead of discarding
progress and starting over. Paired with a **Trust Loop** that scores agent behavior
(a weighted formula blending success rate, uptime, threat signals, and integrity) to
upgrade or downgrade an agent's permission level over time. Treat the vendor's
broader marketing claims (adoption numbers, "100+ agents") with skepticism — the
concrete planning and trust-scoring mechanics are independently verifiable from the
docs; the popularity claims are not. ([ruvnet/ruflo](https://github.com/ruvnet/ruflo), Jul 2026.)

## Benchmarks (Fugu Ultra, June 2026)

| Benchmark | Fugu Ultra | Best frontier comparison |
|---|---|---|
| SWE Bench Pro | 73.7% | Claude Opus 4.8: 69.2% |
| LiveCodeBench | 93.2% | Gemini 3.1 Pro: 88.5% |
| GPQA-D | 95.5% | Gemini 3.1 Pro: 94.3% |
| Humanity's Last Exam | 50.0% | Claude Opus 4.8: 49.8% |

## AutoResearch: a concrete loop engineering example

Sakana's own **AutoResearch** system ran 123 self-improvement experiments autonomously using Fugu as the orchestrator — each iteration proposed a hypothesis, implemented a change, evaluated results, and fed findings into the next iteration. The loop ran unattended; humans reviewed summaries.

This is a direct example of the self-improvement loop pattern: a loop whose primary goal is to improve the loop itself, with a learned orchestrator deciding which experiments to run next. See [The Loop Contract](27-loop-contract.md) → self-discovery pattern.

## Current state (June 2026)

- [Sakana Fugu](https://sakana.ai/fugu/) is available as an **OpenAI-compatible API** (swap endpoint, no SDK change) — two variants: Fugu ($5/$30 per 1M tokens) and Fugu Ultra ($30/$... per 1M; also $20–200/mo subscription)
- Fugu Ultra is unavailable in EU/EEA pending GDPR compliance
- [@steipete](https://x.com/steipete) and others are skeptical about closed-source multi-model routing performance in practice
- No open-source learned orchestrator has matched Fugu Ultra's benchmark claims yet
- This pattern is early-stage — most practitioners still use hand-designed loops

---

## See also

- [The Six Building Blocks](03-building-blocks.md) — the hand-designed equivalent
- [Fleet Engineering](23-fleet-engineering.md) — managing many loops at enterprise scale
- [Failure Patterns](17-failure-patterns.md) — what can go wrong in any orchestration approach
