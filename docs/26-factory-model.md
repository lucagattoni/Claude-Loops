# The Factory Model

The factory model describes the transformation of the engineering role from
**writing code** to **orchestrating agent factories** — systems where AI agents
are the workers and engineers are the production managers.

## The Shift in Bottlenecks

AI agents have collapsed implementation speed. The new engineering bottlenecks are:

- **Specification quality** — poorly specified work produces plausible-looking but
  wrong output. The agent cannot ask clarifying questions mid-task; ambiguity in
  the spec becomes defects in the output.
- **Architectural thinking** — designing which agents do what, in which order,
  with what handoffs, and what verification gates between them
- **Output verification** — confirming the agent's output is actually correct,
  not just plausible-looking

Engineers who thrive in this model excel at thinking at the right level of abstraction
and verifying output rigorously — not at typing fast.

## The Manager Analogy

Factory model engineers think like engineering managers:
- Write precise specs before delegating
- Design the workflow, not just the task
- Verify output at each stage before handing it to the next agent

"My job is to write loops" (Boris Cherny) is the factory model expressed in one
sentence: the engineer's output is the production system, not the individual work
product.

## Practical Signals

You are operating in factory-model territory when:
- A task takes < 1 hour of agent time but > 1 hour of spec-writing time
- You have more than one agent running in parallel on sub-tasks of the same goal
- The bottleneck on your velocity is review bandwidth, not implementation bandwidth
- You are writing `PLAN.md` files more often than you are writing functions

## Spec-First, Conditioned on Maturity

[The Manager Analogy](#the-manager-analogy) and [Practical Signals](#practical-signals) above state
spec-first as unconditional. Andrew Ng conditions it on where the project is:

> "But when building quick 0-to-1 prototypes or applications in domains I'm unfamiliar with, I often
> move faster and with less deliberation. I find it convenient to jump quickly into directing a
> coding agent to start building, so I can examine what it has built in order to make the next set
> of decisions… Instead of 'spec drive development' becoming a new waterfall process where writing a
> spec is a gate to further progress, this allows me to more iteratively refine the spec."
>
> — Andrew Ng, [*Make All Your Tokens (and Your Brainwork)
> Count*](https://www.deeplearning.ai/the-batch/make-all-your-tokens-and-your-brainwork-count),
> 2026-07-10

The conditioning variable, stated directly in the same piece:

> "As a software project matures, coding agents will work longer (maybe hours) to build to more
> complex specs…"
>
> — Andrew Ng, [*Make All Your Tokens (and Your Brainwork)
> Count*](https://www.deeplearning.ai/the-batch/make-all-your-tokens-and-your-brainwork-count),
> 2026-07-10

The KB is not wrong, just unconditional where Ng is conditional: "write precise specs before
delegating" and the < 1 hour agent time / > 1 hour spec time signal are the **mature-project** case.
Early on, clarity is partly an *output* of the first loop iteration — build, inspect, refine — not a
precondition for starting one.

| | 0-to-1 / unfamiliar domain | Mature project / real users |
|---|---|---|
| Spec's role | Discovered by iterating: build, inspect, refine | Written before delegating |
| Spec effort vs. agent-time | Minutes writing a spec, agent runs briefly, repeat | Spec-writing time can legitimately exceed agent time |
| Failure mode if misapplied | **Spec-gating a prototype** — waterfall in a costume, the exact anti-pattern Ng names | **Skipping the spec on a brownfield service with users** — plausible, expensive, wrong output shipped |

Place the task on this table before applying the Practical Signals above as a rule rather than a
default.

## The Dark-Factory Ceiling and Its Bottleneck

Framing the factory model as a maturity progression: coding autonomy runs from
"spicy autocomplete" up to the **dark factory** — a fully autonomous spec-to-deploy
pipeline with no human bottleneck in the loop. A concrete five-layer version of that
pipeline is spec → planning agent → code-gen agents → testing → review agent →
deployment. The consistent finding across write-ups of this pipeline: the bottleneck
that remains once every layer is automated is **not** implementation speed or even
review throughput — it is **underspecified input** at the spec layer, i.e. exactly
the [New Software Lifecycle](01-paradigm-shift.md#the-new-software-lifecycle)
bottleneck this KB already names, restated as a pipeline-stage finding rather than a
general claim. Contrast this positive "dark factory" framing (a maturity target) with
[Failure Patterns' "Dark factory"](17-failure-patterns.md) entry (a warning) — the
difference is entirely whether mandatory human checkpoints exist; the pipeline shape
is the same either way.
([MindStudio](https://www.mindstudio.ai/blog/what-is-dark-factory-ai-coding-autonomous-pipeline-2/), Jul 2026.)

Cross-provider adoption data corroborates that engineers are already operating well
into this territory in practice, not just in theory: OpenAI reports its own engineers
now generate **99% of output tokens via Codex** rather than direct chat, with
99th-percentile users running 60+ hours of parallel agent turns per day. Read this as
external corroboration of the factory-model shift's direction, not as a Claude-Code
data point — the underlying pattern (agents doing the bulk of token-generating work,
humans orchestrating and reviewing) is provider-agnostic.
([OpenAI, "How agents are transforming work"](https://openai.com/index/how-agents-are-transforming-work/), Jul 2026.)

## Named Factory Deployments

- **Droid Shield 2.0** (Factory.ai): a coordinator agent decomposes work and
  dispatches to specialized "droids" (code, review, docs, test, knowledge) with
  explicit role boundaries — including a **dedicated review droid** as a first-class
  role, not an afterthought bolted onto the code droid. The 2.0 release adds learned
  secret detection to the review droid's scope.
  ([factory.ai/news/droid-shield-2-0](https://factory.ai/news/droid-shield-2-0), Jul 2026.)
- **Auto-merge as the factory's terminal stage**: a discussion (Thorsten Ball / Nate
  Berkopec) argues model-based code review now exceeds human review for routine PRs,
  and endorses a factory loop design that **auto-merges low-risk PRs within minutes**
  of opening — the review gate becomes a machine-speed stage rather than a
  human-paced one for the PRs it's confident about, with humans reserved for the
  PRs the gate itself flags as uncertain.
  ([@thorstenball repost via @steipete](https://x.com/thorstenball/status/2074377949181030491), Jul 2026.)
- **Bun's granular decomposition of a total rewrite**: rather than dispatching
  "rewrite Bun in Rust" as one instruction, the work was broken into a sequence
  small enough for parallel agents to execute mechanically: generate porting guides
  (`PORTING.md`, a lifetimes table) → port files mechanically → fix compiler errors
  (16,000 of them, distributed as a checklist across 64 parallel Claude instances,
  see [Fleet Engineering's case
  study](23-fleet-engineering.md#case-study-bun-64-parallel-instances-rewriting-535k-lines-in-11-days))
  → get subcommands working → run the test suite to green. Each stage produces a
  checkable artifact the next stage consumes, which is what makes a 535,496-line
  rewrite decomposable into agent-sized units at all. ([Bun, "Bun, in
  Rust"](https://bun.com/blog/bun-in-rust), Jul 2026.)

## Relationship to Other Concepts

- [Loop Contract](27-loop-contract.md) — the factory spec: what the loop is allowed to do and when it stops
- [Harness Patterns](24-harness-patterns.md) — the factory floor: how the workers are orchestrated
- [Verification](04-verification.md) — quality control: how finished work is checked before shipping
