# Loop Engineering Maturity Model

A progression framework for developers moving from manual prompting to full loop engineering.
Drawn from Boris Cherny's three-stage evolution and the community "14-step roadmap from
prompter to loop designer" (@0xCodez, Jun 9 2026).

---

## Boris Cherny's three stages

| Stage | What you do | Model's role |
|---|---|---|
| 1. Autocomplete | Write code; model fills in the blanks | Directed tool |
| 2. Parallel sessions | Open 5–10 Claude sessions; prompt each manually | Accelerator |
| 3. Loops | Write the system that prompts Claude; delete your IDE | Autonomous worker |

The altitude shift: "from writing the code to writing the thing that writes the code."

---

## Community 14-step roadmap (approximate stages)

The community has elaborated this into a finer progression:

**Prompter (steps 1–4)**
1. One-shot prompts, accept output as-is
2. Iterative prompting — correct mistakes by hand
3. Learn to write specific, scoped requests
4. Understand model limitations; scope prompts accordingly

**Parallel prompter (steps 5–7)**
5. Open multiple sessions for different tasks simultaneously
6. Write task descriptions rather than step-by-step instructions
7. Use CLAUDE.md to persist context between sessions

**Loop beginner (steps 8–10)**
8. First automated loop — a script that calls `claude -p` with a task
9. Add a verification step — loop only exits when the output passes a test
10. Use worktrees to isolate parallel loop runs

**Loop engineer (steps 11–14)**
11. Loops monitor external state (GitHub Issues, Slack, CI) to discover work
12. Maker/checker split — separate loops for producing and verifying
13. Memory layer — loops write and read progress state between runs
14. Factory model — dozens of loops running autonomously; your job is to write and maintain them

---

## Key insight: the stopping condition

The hardest part of each stage transition is defining a *verifiable* success criterion — the
condition the loop checks before stopping. Without it, loops either run forever or halt randomly.

> "The hard part isn't prompting, it's the stop condition. A useful loop needs trace logs,
> bounds…" — @steipete / @shivangchheda22

---

## Per-Loop Readiness Levels (Operational)

Distinct from developer maturity: each individual loop has its own readiness
classification based on its operational behaviour, not the engineer's experience.

| Level | Mode | Gate to advance |
|---|---|---|
| **L1** | Report-only — discovers work and notifies; no autonomous action | ≥1 week of zero false positives |
| **L2** | Assisted — proposes changes; human approves before any merge | Full observability + `loop-budget.md` in place |
| **L3** | Autonomous — auto-merges; fires without human approval | L2 evidence + `loop-run-log.md` + LOOP.md BUDGET section |

**Default rule: start every new loop at L1**, regardless of developer maturity.
A loop engineer at step 14 still runs a new loop's first week in report-only mode.
Operational trust is earned by each loop individually.

For the seven named loop patterns with their default levels, token costs, and
coordination rules, see [Loop Patterns](34-loop-patterns.md).

(Cobus Greyling, cobusgreyling/loop-engineering, Jun 2026.)

## Related

- [The Paradigm Shift](01-paradigm-shift.md)
- [Common Failure Patterns](17-failure-patterns.md) — "No stopping condition"
- [Verification](04-verification.md)
- [Memory Patterns](16-memory-patterns.md)
