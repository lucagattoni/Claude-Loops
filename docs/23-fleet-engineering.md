# Fleet Engineering

> When you have more agents than you can watch, you need fleet ops.

## What it is

Fleet engineering is the discipline of managing **multiple AI agents at enterprise scale** —
not designing individual loops, but operating the infrastructure that governs, observes,
and routes work across a pool of them.

Coined (or popularised) by Cobus Greyling (Jun 2026).

---

## How it differs from loop engineering

| Loop engineering | Fleet engineering |
|---|---|
| Designing a single loop (trigger → act → verify → state) | Operating many loops across an organisation |
| Concern: stopping conditions, guard scripts, state files | Concern: agent health, cost governance, audit trails, role assignment |
| Unit of design: one loop | Unit of design: the fleet |
| Audience: individual engineers | Audience: platform teams, AI ops |

---

## Core concerns

**1. Governance**
Which agents are authorised to run, with what tools, spending limits, and data access?
Fleet engineering answers these questions at the organisation level, not per-loop.

**2. Observability**
- Are agents completing their runs? With what success rate?
- Which agents are consuming the most tokens?
- Where are loops failing silently?

Tools like [LangSmith](https://docs.smith.langchain.com/) expose agent-level telemetry across all running loops.
**[Comet's Opik](https://github.com/comet-ml/opik)** (open-source) adds continuous LLM-quality scoring:
**Online Evaluation Rules** run a judge model against every agent output in production, alerting
when answer relevance or hallucination scores fall below threshold. This is the fleet
equivalent of a test suite — watching quality across the whole fleet, not just per-run exits.

**3. Routing and role assignment**
A fleet may have specialist agents (security reviewer, dependency updater, test writer).
Fleet ops decides which work goes to which agent — a higher-level scheduling problem than
a single loop's internal orchestration.

**4. Failure propagation**
In a fleet, a misconfigured prompt or runaway loop can cascade across many agents before
anyone notices. Fleet engineering adds circuit breakers, spend caps, and automated rollback.

---

## Relationship to loop engineering

Fleet engineering is *above* loop engineering in the stack:

```
Fleet engineering   ← routes, governs, observes N loops
    └── Loop engineering  ← designs, schedules, guards 1 loop
            └── Agent     ← a single Claude invocation
```

A practitioner who has mastered loop engineering designs excellent individual loops.
A fleet engineer asks: "What happens when we have 50 of these running simultaneously?"

---

## Fleet Four Pillars

Cobus Greyling (Jun 2026) defines fleet engineering around four operational concerns:

| Pillar | What it governs |
|---|---|
| **Delegate** | Which tasks flow to which agents — a routing and scheduling problem above individual loop design |
| **Improve** | Continuous tuning of agent prompts and harnesses based on fleet-level telemetry |
| **Approve** | [Human-in-the-loop](14-human-in-the-loop.md) gates for high-consequence actions across the fleet |
| **Connect** | Integration layer — MCP connectors, webhooks, APIs that wire agents into live organisational systems |

## Fleet Four Maturity Levels (F0–F3)

Distinct from developer maturity (docs/20) and per-loop readiness (L1/L2/L3 in docs/34):

| Level | Description | Gate to advance |
|---|---|---|
| **F0** | Ad-hoc: individual loops run manually with no coordination | At least 3 loops running reliably at L2+ independently |
| **F1** | Coordinated: loops share a STATE.md registry; no agent claims conflicting tasks | Zero collision incidents in 2 weeks; `acting_on` field enforced (see [Loop Patterns](34-loop-patterns.md)) |
| **F2** | Governed: Fleet budget guard active; spend visible per agent; approval gates for irreversible actions | Fleet budget never exceeded; audit log in place |
| **F3** | Autonomous: fleet self-governs; anomaly detection triggers automatic rollback; humans review summaries, not individual runs | No undetected runaway spend in 30 days; full observability coverage |

Start every fleet at F0, regardless of engineer experience. F3 requires F2 evidence.

**Still missing: observable per-gate indicators.** A governance-first harness enforcing
shared policy across Copilot, Claude Code, and Codex (a "baton workflow" handing
responsibility between role labels — Manager → Collaborator → Admin → Consultant)
documents fleet-aware routing, telemetry, and policy enforcement consistent with F0-F3
progression, but — like every other source checked so far — stops short of defining the
*concrete, checkable signal* that proves a fleet has passed a given gate (as opposed to
merely running the infrastructure a passing fleet would have). The gap remains open.
([chf3198/megingjord-harness](https://github.com/chf3198/megingjord-harness), Jul 2026.)

## Fleet Economics — Cost Attribution

Individual loop token budgets aggregate into fleet-level spend. At F2+, track cost per agent:

```
fleet-budget.md entries:
  Daily Triage Loop:    budget $0.50/day · actual $0.31/day · headroom 38%
  PR Babysitter:        budget $1.00/day · actual $0.67/day · headroom 33%
  CI Sweeper:           budget $0.20/run · actual $0.04/run · headroom 80% (early exit working)
  Fleet total ceiling:  $5.00/day
```

**Cost attribution rule:** if you cannot identify which agent generated a runaway cost event, you are below F2. Observability is a prerequisite for governance, not an enhancement.

([cobusgreyling/fleet-engineering](https://github.com/cobusgreyling/fleet-engineering) — Cobus Greyling, Jun 2026.)

## Claw vs. Assistant Identity Choice

At F1+, each agent in the fleet must have a declared identity:

| Identity | Behaviour | Use when |
|---|---|---|
| **Claw** (autonomous) | Takes action without per-action human approval; uses auto mode; emits structured audit log | Loop is well-tested at L2, action set is low-risk, fast turnaround required |
| **Assistant** (assisted) | Proposes actions for human approval before execution; uses ask mode | Loop is new (L1), action set is irreversible, or human oversight is required by policy |

Default all new fleet agents to Assistant until they reach L2 operational readiness.
Promote to Claw only after the L2→L3 gate is passed and the action set is proven safe.

([cobusgreyling/fleet-engineering](https://github.com/cobusgreyling/fleet-engineering), Jun 2026.)

## Org-Chart Coordination (an alternative to a graph topology)

Most fleet coordination is described as a graph — nodes (agents) and edges (handoffs).
An alternative: map agents onto an **org chart** instead — each agent has a role and a
reporting line, and agents coordinate the way a human org does, over **email** rather
than a shared state file or direct API calls. The org-chart framing gives fleet
designers a vocabulary non-engineers already understand (manager, report, cc'd
stakeholder) and makes escalation paths explicit by construction — a report's blocked
question routes to its manager the same way a human employee's would. Backend-agnostic:
agents in the chart can run on Claude Code, Codex, or OpenCode interchangeably.
([alookai/alook](https://github.com/alookai/alook), Jul 2026.)

**A third topology: swarm coordination via consensus protocols.** Where the graph and
org-chart framings coordinate through explicit messages or reporting lines, a swarm
topology coordinates through a **queen-led hierarchy backed by distributed-systems
consensus** (Raft, Byzantine fault tolerance, or gossip protocols) — the same class of
protocol used to keep database replicas agreed on state, applied here to keep agent
fleet state agreed across many concurrent workers. This trades the readability of an
org chart for the fault-tolerance guarantees of a consensus algorithm — appropriate
when the fleet must keep operating correctly through individual agent crashes, not just
coordinate cleanly when everything is healthy. ([ruvnet/ruflo](https://github.com/ruvnet/ruflo), Jul 2026.)

## Case Study: Gas Town — 20-30 Parallel Instances via Git-Persisted Work Units

Steve Yegge's "Gas Town" is a concrete, named production deployment of fleet
engineering at real scale: **20–30 parallel Claude Code instances** coordinated
through work units called **Beads**, persisted in git rather than in an external
queue or database. Two mechanisms make this survive at that concurrency:

- **Merge-queue management** — Beads flow through an explicit merge queue rather than
  each agent pushing directly to a shared branch, turning "many agents editing the
  same repo" from a collision risk into a serialized, auditable sequence.
- **Crash-surviving agent identities** — an agent's identity and in-progress work
  are anchored to git state, not to a live process; a crashed instance can be
  restarted and resumes against the same Bead rather than losing its claim or
  duplicating another instance's work.

This is a working example of the [Fleet Budget Guard](#fleet-four-pillars) and
[claimed-todo](16-memory-patterns.md#pattern-i-durable-objectives-with-evidence-logs)
ideas at a concurrency level (20–30 agents) well beyond what most documented fleets
in this KB report operating at. ([Steve Yegge, "Welcome to Gas Town"](https://steve-yegge.medium.com/welcome-to-gas-town-4f25ee16dd04), Jul 2026.)

## Case Study: Bun — 64 Parallel Instances Rewriting 535K Lines in 11 Days

Bun's port of its JavaScript-runtime internals from Zig to Rust is a second concrete,
named production deployment at real scale, larger in raw instance count than Gas Town:
**about 50 dynamic workflows over 11 days**, peaking at **64 parallel Claude Code
instances across 4 git worktrees** — "4 of these workflows at once each in a separate
worktree, each with 16 Claudes per workflow. About 64 Claudes at a time" (Bun, "Bun, in
Rust") — sustaining roughly **1,300 lines of code written per minute** at peak. Unlike
Gas Town's Beads-based coordination layer, this fleet ran on plain git worktrees with no
external work-unit queue — a data point for how far raw worktree parallelism scales
before a coordination layer becomes necessary.

### What "535,496 lines" actually measures

535,496 is the **source Zig codebase**, not a size of the rewrite or its output — and
this doc previously stated the figure without saying which of three legitimate,
independently-sourced numbers it was, which is exactly why a critic flagged it as
contradicting the ~750,000 figure quoted elsewhere. It doesn't; the three numbers measure
three different things:

| Number | What it measures | Source |
|---|---|---|
| **535,496 lines** | Lines of Zig in the *source* codebase, excluding comments, across 1,448 `.zig` files | [Bun, "Bun, in Rust"](https://bun.com/blog/bun-in-rust) |
| **~750,000 lines** | Anthropic's rounded count of the *resulting* Rust codebase | [Anthropic, "Introducing dynamic workflows in Claude Code"](https://claude.com/blog/introducing-dynamic-workflows-in-claude-code) |
| **1,009,272 lines** | Lines *added* in the final merged diff — "the diff that landed was +1,009,272" (Bun, "Bun, in Rust") — includes churn, not just net-new code | [Bun, "Bun, in Rust"](https://bun.com/blog/bun-in-rust) |

The general lesson generalises past this one case study: a line count (or any figure)
without its unit and its population is a claim waiting to be flagged as an error by the
next reader who finds a different, equally correct number for the same-sounding thing.

Two design choices carried the fleet through the port:

- **A checklist-shaped task, not a single instruction.** Fixing the cyclical
  dependencies "revealed about 16,000 compiler errors. A massive number for 1 human, but
  not a crazy number for 64 claudes at once" (Bun, "Bun, in Rust") — treated as a
  distributable checklist and spread across the 64 parallel instances — see the granular
  decomposition sequence in
  [The Factory Model](26-factory-model.md#named-factory-deployments).
- **[Blind adversarial review](04-verification.md#verifier-integrity-keeping-the-check-unfakeable)
  at fleet scale** — Bun describes the ratio as "1 implementer, 2 or more adversarial
  reviewers per implementer. The reviewer's only job: find bugs & reasons why the code
  does not work" (Bun, "Bun, in Rust"); Anthropic separately describes the same review
  layer as "hundreds of agents working in parallel with two reviewers on each file"
  (Anthropic, "Introducing dynamic workflows in Claude Code"). It produced 128 bug fixes
  in the v1.4.0 release against only 19 regressions introduced across the full rewrite.

Result: 6,502 commits over eleven days from first commit to merge, with **99.8% of the
existing test suite passing** on the resulting Rust codebase (Anthropic, "Introducing
dynamic workflows in Claude Code"), 128 bugs fixed vs. the prior release, and memory
leaks eliminated (one multi-build leak dropped from 6.7 GB to 609 MB over 2,000
iterations) — the class of bug the rewrite was undertaken to fix in the first place.
([Bun, "Bun, in Rust"](https://bun.com/blog/bun-in-rust), Jul 2026; [Anthropic,
"Introducing dynamic workflows in Claude Code"](https://claude.com/blog/introducing-dynamic-workflows-in-claude-code), May 2026.)

### Counterweight: an uncritical case study deserves its objections stated

Every figure above comes from the company that ran the fleet and wrote it up (Bun) or
the vendor that sold the platform it ran on (Anthropic) — this doc has not, until now,
carried anything from outside either party. The Hacker News discussion of Anthropic's
launch post raises two objections worth reading alongside the results:

**The result may not be specific to dynamic workflows.** A behaviour-preserving,
file-by-file port is close to a best case for coding agents regardless of the
orchestration framework running them:

> "Mechanical refactors are relatively straight forward for agents."
>
> — [SkyPuncher, comment on Hacker News item 48311705](https://news.ycombinator.com/item?id=48311705)

If that reading holds, the case study is stronger evidence that fleet parallelism scales
to 64 concurrent instances than it is evidence that *dynamic workflows specifically* —
as opposed to worktrees plus adversarial review, which Gas Town also uses without
dynamic workflows — caused the result.

**Token cost at this concurrency is unmeasured for the Bun port itself, and heavy at
comparable scale elsewhere.** Neither Bun's post nor Anthropic's names a token or dollar
figure for the 64-instance run. Other users of the same feature, on smaller, unrelated
jobs, reported burning through paid-plan allocations fast:

> "Tested this out on a 5x max plan, turns out I spun up 62 Opus 4.8 1M sub-agents for my
> dynamic workflow and maxed out my ~5hr cap in..... 18 minutes?"
>
> — [Syntaf, comment on Hacker News item 48311705](https://news.ycombinator.com/item?id=48311705)

> "I just hit my Claude Max limit for the first time *ever* thanks to workflows lol. Like
> 90 agents ran to do a code review of a fairly small package I have."
>
> — [ncphillips, comment on Hacker News item 48311705](https://news.ycombinator.com/item?id=48311705)

Read the throughput and bug-fix numbers above as real but vendor-reported and
favourable-case; treat the cost of reproducing this at similar concurrency as unstated by
either primary source and plausibly large, per what practitioners report when they run
the same feature at a fraction of the scale.

## Current state (June 2026)

- [cobusgreyling/fleet-engineering](https://github.com/cobusgreyling/fleet-engineering) is the primary reference implementation with six production patterns (Team Registry, Shared Inbox HITL, Hierarchical Delegation, Fleet Budget Guard, Cross-Agent Audit)
- [LangSmith](https://docs.smith.langchain.com/) is the leading commercial observability platform
- Most teams are still at F0–F1; F2+ governance is rare in the wild
- The term is new; expect terminology to stabilise as the discipline matures

---

## See also

- [The Six Building Blocks](03-building-blocks.md) — the foundation for individual loops
- [Learned Orchestration](22-learned-orchestration.md) — training the orchestrator vs. coding it
- [Fan-Out](10-fan-out.md) — parallelising at the loop level (a step toward fleet thinking)
- [Cost & Turn Control](11-cost-control.md) — mandatory at fleet scale
