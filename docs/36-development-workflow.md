# The Development Workflow

This is the spine of Part II: the whole cycle of building software with Claude Code, and which
primitive does the work at each point.

The frame comes from Andrew Ng's
[AI Engineering Skills Map](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map/)
(2026-08-14) — four pillars synthesised, in his description, by a method *"akin to clustering on a
massive dataset of jobs and expert interviews"*: over 10,000 job postings, dozens of structured
interviews, plus survey data. One of the four pillars is **Using Coding Agents**, expanded in
[its own letter](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map-in-detail-using-coding-agents/)
(2026-09-04). That letter's three phases and five skills organise this page; the mapping to Claude
Code primitives is this KB's.

**Read the headline claim before anything else:**

> "most effective coding agent use is a complex, highly iterative process"
>
> — Ng, 2026-09-04, explicitly *not* autonomous long-horizon execution

If you have not yet decided whether your task belongs here or in Part I, start at
[Choosing Your Mode](35-choosing-your-mode.md).

---

## The three phases

| Phase | What happens | Primary Claude Code surface |
|---|---|---|
| **Planning** | Brainstorm, research the codebase, write a spec capturing requirements and technical design, generate an execution plan, review assumptions for security gaps | [Plan mode](15-explore-plan-implement.md), `Explore` subagent, [CLAUDE.md](05-claude-md.md) |
| **Execution** | Build, test and verify, with autonomy and oversight balanced | [Permissions](08-permissions.md), [subagents](07-subagents.md), [workflows](39-dynamic-workflows.md), [hooks](12-hooks.md) |
| **Deployment & monitoring** | Deploy, possibly gated by CI/CD; agents watch logs, surface issues, propose fixes | [Headless](09-headless-mode.md), [Routines](28-routines.md), [Claude Tag](31-claude-tag.md) — this is where **Part I** takes over |

The third phase is the handoff point between the two halves of this knowledge base. Monitoring is
recurring, well-specified and verifiable — the profile that passes
[the three tests](35-choosing-your-mode.md#the-three-tests).

### The spec scales with the risk, not with the task

> "the spec for a greenfield … prototype might be loosely described in a quickly written prompt"
> … whereas "the spec for a brownfield (pre-existing) project with many users might require much
> more effort."

This is the most-skipped judgement in phase 1. Writing a full spec for a throwaway prototype is
waste; skipping one on a brownfield service with users is how agents produce plausible, wrong,
expensive work. Match the ceremony to the blast radius. Part I's spec-first signals
([Factory Model](26-factory-model.md#spec-first-conditioned-on-maturity)) carry the same maturity
condition — read them as the mature-project case, not a universal rule.

---

## The five skills

### 1. Directing the workflow

Navigating the tradeoffs between **speed, cost, technical risk and human effort** — deciding at each
step how much is yours to do and how much is the agent's.

| In Claude Code | Where |
|---|---|
| Choosing interactive vs. delegated vs. unattended | [Choosing Your Mode](35-choosing-your-mode.md) |
| Model and effort selection, cost per unit of work | [Cost & Turn Control](11-cost-control.md) |
| Whether this needs one session or several | [Session Architecture](37-session-architecture.md) |

### 2. Enabling agent autonomy

Ng puts the core question directly:

> "Do you watch it and go back-and-forth interactively or delegate a larger chunk of work to it?"

and answers it with a caveat worth memorising:

> "being able to intervene with high-skill judgement gives much better results"

Autonomy is a dial, not a switch. In Claude Code the dial has real detents:

| Detent | Mechanism |
|---|---|
| Watch every action | plan mode; `default` permission mode |
| Approve edits, watch commands | `acceptEdits` |
| Classifier reviews each action | `auto` — **now the default on Pro, Max and Team plans**; see [Permissions](08-permissions.md) |
| Delegate a bounded side task | [subagents](07-subagents.md) |
| Delegate a large fan-out | [dynamic workflows](39-dynamic-workflows.md), [agent teams](38-agent-teams.md) |
| Nobody watching | [headless](09-headless-mode.md) + a hard `--max-turns` / `--max-budget-usd` |

On parallelism, Ng names the decision and the two costs around it:

> "you will decide when to set up many agents to run in parallel on a decomposition of the task",
> "having a human or a higher-level agent orchestrate these other agents", and
> "how to manage human attention across concurrent agent sessions."

That last clause is the one people discover late. Parallel agents do not just spend tokens; they
spend **your attention**, which is the scarcer resource. [Session Architecture](37-session-architecture.md)
covers when parallelism actually pays.

Context management belongs to this skill too — see [Context Management](13-context-management.md)
and [Memory Patterns](16-memory-patterns.md).

### 3. Reviewing the work

Matched behavioural and functional testing, LLM-as-a-judge evals, and security audits.

> "Some workflows will have all testing and validation fully automated so the agent can check its
> work and know when it has succeeded"

That sentence is the whole of [Verification](04-verification.md) compressed: the agent knowing when
it has succeeded *is* the stopping condition. Where full automation is not possible, Ng points at
eval sets, *"perhaps with LLM-as-a-judge"*.

Practical placement in Claude Code:

- `/code-review` and `/security-review` on a diff. **v2.1.215**: *"Claude no longer runs the
  `/verify` and `/code-review` skills on its own; invoke them with `/verify` or `/code-review` when
  you want them."* **v2.1.218** then *"Changed `/code-review` to run as a background subagent, so
  review work no longer fills your conversation."*

    **That v2.1.215 sentence no longer holds unqualified.** **v2.1.246**: *"Changed `/code-review`
    so Claude **can also start it on its own** on Bedrock, Vertex AI, and Foundry, through the Claude
    apps gateway, and when telemetry or non-essential traffic is disabled."* The word *also* implies
    autostart had already returned on other platforms — but **no changelog bullet records where it
    was reinstated** (the full 6,362-line file carries only these two entries on the subject, checked
    20260906). So: do not design a loop on the assumption that `/code-review` runs only when invoked.
    If you need it to stay manual, pin it with
    `skillOverrides: {"code-review": "user-invocable-only"}` (`skillOverrides` shipped **v2.1.129**)
    rather than relying on a default that has already flipped once.
- An adversarial review **subagent** in a fresh context, rather than a second session — the official
  best-practices page notes the subagent form works *"without you copying findings between windows."*
- Hooks for the checks that must never be skipped. Advisory text gets ignored; a `Stop` hook does not.

**The trap:** a reviewer prompted to find gaps will find some, whether or not any exist. Calibrate
the instrument before trusting it — see
[the calibration rule](37-session-architecture.md#practical-rules).

### 4. Customizing the agent and its environment

Skills, plugins, MCP servers, and standing context — Ng names the file explicitly, *AGENTS.md /
CLAUDE.md*, holding codebase information, architectural assumptions, code style and data-access
patterns — plus preserving state across sessions and coordinating across a team's agents.

| Concern | Doc |
|---|---|
| Standing context, and pruning it | [CLAUDE.md](05-claude-md.md) |
| On-demand procedure | [Skills](06-skills.md) |
| Deterministic rules | [Hooks](12-hooks.md) |
| State across sessions | [Memory Patterns](16-memory-patterns.md) |
| External tools | [MCP Security](19-mcp-security.md) |

The rule that governs this whole skill: **an instruction that must hold with zero exceptions does not
belong in prose.** Official guidance is blunt about it — *"Unlike CLAUDE.md instructions which are
advisory, hooks are deterministic and guarantee the action happens."* And on bloat: *"Bloated
CLAUDE.md files cause Claude to ignore your actual instructions!"* Run `/doctor` for proposed cuts.

### 5. Coding agent foundations

How the agent retrieves, how the context window is managed, and the failure modes that follow. Ng
names four:

> "overengineering a simple solution, losing rigor because the agent lacks an explicit verification
> process, stopping short of the goal"

and separately:

> "agent actions that risk destruction of files or production data"

The first three are addressed in [Common Failure Patterns](17-failure-patterns.md); the fourth in
[Permissions](08-permissions.md) and [Agent Security Hardening](33-agent-security-hardening.md).

**Overengineering is the one to watch for**, because it does not look like failure. It looks like
thorough work. It is the reason a spec that says what *not* to build is worth writing.

---

## What the other pillars contribute

The coding-agent skill does not stand alone in Ng's map.

**Software engineering fundamentals** ([2026-08-28](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map-in-detail-software-engineering-fundamentals/))
— the argument is that agentic tools *remove the friction that used to force* developers to confront
tradeoffs, so without fundamentals you make *"poor tradeoffs in latency, availability, consistency,
reliability, maintainability, simplicity, and/or cost"* without noticing the tradeoffs existed.

> "developers who deeply understand how software works vastly outperform those who vibe code without
> understanding"

This is the corrective to the idea that the model makes expertise optional. It makes expertise
*higher-leverage*, because expertise is now expressed as steering rather than typing.

**Building and deploying AI applications** ([2026-08-21](https://www.deeplearning.ai/the-batch/he-ai-engineering-skills-map-in-detail-building-and-deploying-ai-applications/))
— if what you are building is *itself* AI-powered, its outputs are unpredictable, which demands
*"iterative development processes where engineers continuously build, examine results, and decide
next steps based on intermediate findings."* Ng singles out one skill above the rest:

> "a disciplined evals/error analysis loop"

Note the shape of that: it is a **loop**, and its stopping condition is an eval. That is
[Part I](27-loop-contract.md)'s subject arriving from the other direction.

---

## A worked reference implementation

!!! warning "First-party disclosure"
    [ClaudeWarp](https://github.com/lucagattoni/Claude-Warp) is written by **the same maintainer as
    this knowledge base**. Every figure attributed to it here is **self-reported** and has not been
    independently reproduced. It is cited in five docs (`docs/11`, `docs/22`, `docs/24`, `docs/29`,
    `docs/35`) and that relationship applies to all of them.

    Two consequences worth stating plainly, because this KB applies the same scepticism to
    [BrainGrid](https://www.braingrid.ai/) and [Hindsight/Vectorize](https://hindsight.vectorize.io/)
    as vendor sources and owes itself no less:

    - **Treat it as a worked example, not as evidence.** Where it reports a measurement — the
      per-session cost floor in [Cost Control](11-cost-control.md) — the caveat there is the
      operative one.
    - **The dependency runs both ways.** ClaudeWarp ships `/claude-warp-sync-research`, a skill whose
      documented job is to fetch *this repository* via the GitHub compare API and implement what it
      finds. So a pattern this KB reads back out of ClaudeWarp may be a pattern ClaudeWarp read from
      this KB — citing it as an external corroboration would be circular. Where the two agree on a
      construct, assume shared origin unless the provenance is traced.

[ClaudeWarp](https://github.com/lucagattoni/Claude-Warp) is a public loop harness built on top of
Claude Code — *"scaffold, guard, and schedule autonomous loops in any project"* — and it is a useful
thing to read even if you never install it, because it makes the phase-3 handoff concrete.

Its own framing of the gap it fills:

> "Autonomous agents fail in two ways: they stop when you leave, and they say 'done' when it isn't."

Three of its design rules transfer without adopting the tool:

1. **State that outlives the session.** Goals, loops and task queues live in git, so a crash, a
   reboot, or a different machine can resume. Contrast the native primitives, which are
   session-scoped by design.
2. **A budget is part of the definition, not an afterthought.** Every scaffold carries a hard `$` and
   turn cap. See [Cost & Turn Control](11-cost-control.md).
3. **"Not run" is not "green."** An unrun check is reported as `not run`, and an uncertain result as
   `done_with_concerns` rather than rounded up to done. This is the same defect
   [Session Architecture](37-session-architecture.md#the-finding-that-actually-mattered) documents
   as a fan-out reporting clean after most of its agents died.

The property most worth copying is architectural:

> "the harness is built to disappear: `/claude-warp-sync` reads every Claude Code release and
> retires each component the moment it ships natively."

**A harness should be designed to shrink.** Every component you build on top of a platform that is
still moving is a liability with a maturity date. Building the retirement mechanism at the same time
as the component is what keeps the boundary honest — and it is the discipline this knowledge base
needs too, which is why eight stale facts had to be corrected in `v3.0.0`.

**Read that quotation as a design statement, not a result.** It is the project's own description of
what the mechanism is for, quoted as written. Measured against its own changelog, `/claude-warp-sync`
has run twice — reading 65 Claude Code releases in total — and retired **zero** components; both runs
record *"no Harness row is superseded."* The mechanism works, the platform simply has not yet
absorbed anything it covers. The full measurement, and the three lessons that follow from it, are in
[Harness Patterns § What the shrink mechanism actually
measured](24-harness-patterns.md#what-the-shrink-mechanism-actually-measured).

---

## Related

- [Choosing Your Mode](35-choosing-your-mode.md) — the decision that precedes this page
- [Session Architecture](37-session-architecture.md) — one session or many
- [Explore → Plan → Implement → Commit](15-explore-plan-implement.md) — phase 1 and 2 in practice
- [Verification](04-verification.md) — skill 3, in depth
- [The Loop Contract](27-loop-contract.md) — where phase 3 hands off to Part I
