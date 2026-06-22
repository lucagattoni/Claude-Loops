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

## Current state (June 2026)

- LangSmith Fleet is the leading commercial platform; others are emerging
- Most teams are still at the "multiple independent loops" stage, not true fleet ops
- The term is new; expect terminology to stabilise as the discipline matures

---

## See also

- [The Six Building Blocks](03-building-blocks.md) — the foundation for individual loops
- [Learned Orchestration](22-learned-orchestration.md) — training the orchestrator vs. coding it
- [Fan-Out](10-fan-out.md) — parallelising at the loop level (a step toward fleet thinking)
- [Cost & Turn Control](11-cost-control.md) — mandatory at fleet scale
