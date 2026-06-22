# Learned Orchestration

> Rather than coding the workflow, train the workflow.

## What it is

Learned orchestration is a multi-agent design pattern where the orchestrator itself is a
**trained model** rather than hand-written code. Instead of explicitly specifying which
sub-agent runs in which order, a learned orchestrator discovers the optimal coordination
strategy from data.

Sakana AI's **Fugu** (launched 22 June 2026) is the first production system to ship this
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

## The TRINITY / Conductor architecture (Sakana Fugu)

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

## Current state (June 2026)

- Sakana Fugu is available as an OpenAI-compatible API (two variants: Fugu and Fugu Ultra)
- @steipete and others are skeptical about closed-source multi-model routing performance in practice
- No open-source learned orchestrator has matched Fugu Ultra's benchmark claims yet
- This pattern is early-stage — most practitioners still use hand-designed loops

---

## See also

- [The Six Building Blocks](03-building-blocks.md) — the hand-designed equivalent
- [Fleet Engineering](23-fleet-engineering.md) — managing many loops at enterprise scale
- [Failure Patterns](17-failure-patterns.md) — what can go wrong in any orchestration approach
