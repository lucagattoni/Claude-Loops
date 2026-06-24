# Goal Engineering

> Loops discover work. Goals finish it.

A **goal** is a bounded autonomous task with a defined completion state. Unlike a
loop (which recurs on a schedule or event), a goal runs once and terminates when
a verifiable criterion is met.

(Cobus Greyling, "Goal Engineering", Substack, Jun 2026.)

## Goals vs. Loops

Use this decision framework before designing a task:

```
Do you know what "done" looks like?
├── No  → clarify the objective first (you don't have a loop or a goal, you have a wish)
└── Yes → Is the work recurring on a schedule?
    ├── Yes → design a Loop
    └── No  → design a Goal
```

| Property | Loop | Goal |
|---|---|---|
| Trigger | Schedule or event | Single invocation |
| Termination | Runs until stopped | Stops when verifiable criterion is met |
| State | Progress tracked across iterations | State tracked in GOAL.md |
| Primary risk | Runaway cost without stop condition | Goal mirage (plausible-looking partial output) |

Production systems combine both: a cron loop discovers work and spawns Goals to
finish discrete units of it.

## The Four Goal Primitives

Every well-formed goal requires four components:

### 1. Objective
A single bounded statement with verifiable completion criteria — not a vague directive.

```
Bad:  "Improve the auth module"
Good: "Migrate to lib/auth/v2; done when all tests in /auth pass,
       zero legacy/auth imports remain, and GOAL.md checklist is complete"
```

The objective must be testable by the Verifier.

### 2. Verifier
An independent validation mechanism — tests, a subagent reviewer, a CI check.
The agent that wrote the code is a poor judge of its own work; the Verifier must
be separate. (See [Verification](04-verification.md) and [DOER/CHECKER](07-subagents.md).)

### 3. State — GOAL.md
A persistent external memory file the agent reads at the start of every context
window and writes to at meaningful milestones. GOAL.md contains:
- Objective (verbatim)
- Done conditions (checklist)
- Guardrails (what the goal must not touch)
- Execution log (what has been tried, discovered, completed)

GOAL.md is the solution to the context reset problem: when the agent's context is
cleared or compacted, GOAL.md preserves the goal's history and prevents re-doing
completed work or forgetting discovered constraints. Use an `update_goal` tool call
(or a simple file write) at meaningful milestones rather than after every micro-step.

### 4. Budget
Turn caps, token limits, and kill switches — the same hard stops as a loop.
A goal without a budget is a runaway process with a polished objective.

See [Loop Contract](27-loop-contract.md) for the full BUDGET property.

## Relationship to the Loop Contract

A goal is a single non-recurring iteration with a deterministic stopping condition.
The [Loop Contract](27-loop-contract.md)'s STOP property maps directly to the
Verifier primitive. The Anchor File pattern maps as follows:

| Anchor file | Goal primitive |
|---|---|
| `VISION.md` | Objective |
| `GOAL.md` | State |
| `CLAUDE.md` | Guardrails (within State) |
| Stop hook / CI | Verifier |
| `--max-budget-usd` | Budget |
