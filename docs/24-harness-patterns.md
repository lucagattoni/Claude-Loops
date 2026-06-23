# Harness Patterns

The harness is the scaffolding around the agent — prompts, tools, context policies,
sandboxes, and feedback loops. It is a first-class engineering artefact that requires
continuous refinement, not a disposable wrapper.

## Harness vs. Loop — Two Architectural Layers

| Layer | Scope | Analogy |
|---|---|---|
| **Harness** | Single-agent safety wrapper — prompts, tools, context policies, sandboxes | Equipment |
| **Loop** | Multi-agent orchestration + scheduler that governs multiple harness cycles | Factory control plane |

The harness is prerequisite infrastructure; the loop is the control plane above it.
A well-designed loop depends on well-designed harnesses — but the loop's job is
coordination and termination, not execution.

> "Verification closure creates reliability; reliability creates scalability."

Verification built into the harness (a separate verifier agent, objective evidence
gates) is what makes a loop safe to scale up: you can run more iterations, more
agents in parallel, and larger budgets only when each cycle's output is trustworthy.

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

(Paramveer Singh, "Designing Autonomous AI Loops", Jun 2026.)
