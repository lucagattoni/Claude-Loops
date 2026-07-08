# The Paradigm Shift

> Stop writing prompts. Start designing loops.

| Old way | Loop engineering |
|---|---|
| Prompt → wait → review → prompt again | Design the loop once, let it run |
| Tactical, one-shot | Strategic, systemic |
| You are the verification step | The loop verifies itself |
| Session dies when you close your laptop | Loop runs on schedule or event trigger |

The key insight (credited to Boris Cherny, who built Claude Code):
**replace yourself as the person who prompts the agent**.

See [The Factory Model](26-factory-model.md) for the deeper treatment: what the
engineer's role becomes once implementation speed is no longer the bottleneck.

## AI Leverage Formula

> AI Leverage = Your Skill × Your Clarity

Where **Clarity** is your ability to articulate exactly what "done" looks like.

| Low clarity | High clarity |
|---|---|
| "Make the auth better" | "Fix the token refresh race condition described in ISSUE-42" |
| Produces plausible-looking output | Produces verifiable, targeted output |
| No stopping condition | The loop knows when to stop |

The formula implies two things:
1. **You cannot outsource clarity** — an agent given a vague brief produces vague work
2. **Skill multiplies clarity** — a skilled engineer's precise spec produces exponentially better output than a non-engineer's vague spec, even with the same model

(Sabrina Ramonov, ["AI Loop Engineering"](https://www.sabrina.dev/p/loop-engineering-claude-code-goal-routines), Jun 2026.)

## Why Loops Beat Single Turns — The Compound Probability Argument

A task requiring 10 sequential correct decisions, each at 90% individual accuracy,
has only **35% end-to-end success probability** (0.9^10 ≈ 0.35). As tasks grow more
complex, single-turn invocations fail not because the model is bad at any single step
but because compound error rates make reliability impossible without a correction loop.

> "The performance ceiling of any LLM-based system is not set by model quality —
> it is set by the quality of the loop surrounding the model." — [@roanbrasil](https://x.com/roanbrasil), Jun 2026

> "A mediocre model inside a well-engineered loop outperforms a frontier model invoked once."

| Era | Paradigm |
|---|---|
| 2022 | `f(prompt) → answer` — single-turn, no correction |
| 2023 | Agent loop (LangChain era) — ReAct scaffolding, but unstable |
| 2024–2026 | Stabilised harness architecture — the loop is the primary engineering surface |

([@roanbrasil](https://x.com/roanbrasil), "Loop Engineering: Designing the Execution Harness Around an LLM", Jun 2026.)

## The New Software Lifecycle

AI agents have collapsed implementation speed. This changes where engineering
effort concentrates:

| Old bottleneck | New bottleneck |
|---|---|
| Writing the code | Writing the spec |
| Implementation speed | Specification quality |
| Debugging your own code | Verifying agent output |
| Tool expertise | Harness design |

Engineers who thrive are those who excel at thinking at the right level of abstraction,
specifying work precisely, and verifying output rigorously — not those who type fastest.

The harness and the spec are now first-class engineering artefacts. "Vibe coding"
(accepting plausible-looking output without verification) is the new technical debt.
(Addy Osmani, ["The New Software Lifecycle"](https://addyosmani.com/blog/new-sdlc-vibe-coding/), Jun 2026.)

## Loop Engineering at Anthropic

> "More than 80% of Anthropic engineers now build with self-improving loops." — Anthropic engineer, Jun 2026

Anthropic published five canonical agent workflow patterns that underpin their internal loop engineering practice:

| Pattern | Description |
|---|---|
| **Prompt chaining** | Sequential steps where each model call processes the output of the previous |
| **Routing** | A classifier determines which specialised sub-pipeline handles each input |
| **Parallelization** | Independent sub-tasks run in parallel; outputs are aggregated |
| **Orchestrator-workers** | A coordinator breaks the task down; worker agents execute sub-tasks |
| **Evaluator-optimizer** | Generator and evaluator alternate; evaluator feedback drives the next generation |

The **evaluator-optimizer** is the canonical implementation of the maker/checker verification loop: the generator produces an artifact, the evaluator judges it against defined criteria, and the result drives the next generation. The loop exits when the evaluator's criteria are met — this is loop engineering's stopping condition in practice. See [Subagents](07-subagents.md) for the DOER/CHECKER pattern and evaluator tuning.

(Anthropic, ["Building Effective Agents"](https://www.anthropic.com/news/building-effective-agents), Dec 2024.)

## Who Benefits Most From the Shift

An analysis of roughly 400,000 Claude Code sessions found that **domain expertise —
not coding background — predicts how much work Claude does per instruction.** This
sharpens the [AI Leverage Formula](#ai-leverage-formula) above: "Skill" was framed
generically, but the data says the specific skill that compounds with Clarity is
domain knowledge of the problem being solved, not general programming ability. A
domain expert with limited coding background can write higher-leverage instructions
than a strong general-purpose engineer working outside their domain, because
clarity about *what "done" means in this domain* is what lets Claude do more per
turn — the throughline back to the compound-probability argument above: fewer,
clearer decisions per instruction compounds into fewer total turns needed.
(Anthropic Research, ["Claude Code expertise analysis"](https://www.anthropic.com/research/claude-code-expertise), Jul 2026.)
