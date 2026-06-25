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

## Harness-Agnostic Projection

A harness-agnostic design separates loop logic from the CLI or platform it runs on.
The pattern: define all agent roles, tools, and workflows in a single source directory
(`.apm/` or equivalent), then compile that source to the layout required by each target
harness (Claude Code, Codex, Copilot, Cursor, Gemini, Kiro).

Benefits:
- Portfolio-level consistency: same security, verification, and escalation policies apply across all harnesses
- Avoid lock-in: swap or add harness targets without rewriting loop logic
- Specialist agents (adversarial reviewer, security analyst) ship as portable units usable in any target harness

**Security review at specification stage:** In a harness-agnostic design, a dedicated security agent
reviews the compiled harness specification *before* any implementation begins — not after.
Fixing a security gap at specification costs 1×; fixing it post-implementation costs 10×+.

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

(Paramveer Singh, "Designing Autonomous AI Loops", Jun 2026.)
