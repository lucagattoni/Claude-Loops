# Fleet Engineering

> When you have more agents than you can watch, you need fleet ops.

## What it is

Fleet engineering is the discipline of managing **multiple AI agents at enterprise scale** —
not designing individual loops, but operating the infrastructure that governs, observes,
and routes work across a pool of them.

Coined (or popularised) by Cobus Greyling (Jun 2026), building on LangSmith Fleet's
enterprise rollout.

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

Tools like LangSmith Fleet expose agent-level telemetry across all running loops.

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

(cobusgreyling/fleet-engineering — Cobus Greyling, Jun 2026.)

## Claw vs. Assistant Identity Choice

At F1+, each agent in the fleet must have a declared identity:

| Identity | Behaviour | Use when |
|---|---|---|
| **Claw** (autonomous) | Takes action without per-action human approval; uses auto mode; emits structured audit log | Loop is well-tested at L2, action set is low-risk, fast turnaround required |
| **Assistant** (assisted) | Proposes actions for human approval before execution; uses ask mode | Loop is new (L1), action set is irreversible, or human oversight is required by policy |

Default all new fleet agents to Assistant until they reach L2 operational readiness.
Promote to Claw only after the L2→L3 gate is passed and the action set is proven safe.

(cobusgreyling/fleet-engineering, Jun 2026.)

## Current state (June 2026)

- cobusgreyling/fleet-engineering is the primary reference implementation with six production patterns (Team Registry, Shared Inbox HITL, Hierarchical Delegation, Fleet Budget Guard, Cross-Agent Audit)
- LangSmith Fleet is the leading commercial observability platform
- Most teams are still at F0–F1; F2+ governance is rare in the wild
- The term is new; expect terminology to stabilise as the discipline matures

---

## See also

- [The Six Building Blocks](03-building-blocks.md) — the foundation for individual loops
- [Learned Orchestration](22-learned-orchestration.md) — training the orchestrator vs. coding it
- [Fan-Out](10-fan-out.md) — parallelising at the loop level (a step toward fleet thinking)
- [Cost & Turn Control](11-cost-control.md) — mandatory at fleet scale
