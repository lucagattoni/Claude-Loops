# Loop Engineering Maturity Model

A progression framework for developers moving from manual prompting to full loop engineering.
Drawn from Boris Cherny's three-stage evolution and the community "14-step roadmap from
prompter to loop designer" ([@0xCodez](https://x.com/0xCodez/status/2068784463186932059), Jun 9 2026).

---

## Boris Cherny's three stages

| Stage | What you do | Model's role |
|---|---|---|
| 1. Autocomplete | Write code; model fills in the blanks | Directed tool |
| 2. Parallel sessions | Open 5–10 Claude sessions; prompt each manually | Accelerator |
| 3. Loops | Write the system that prompts Claude; delete your IDE | Autonomous worker |

Cherny's own words for Stage 3: ["I don't prompt Claude anymore. I have loops that are
running. They're the ones that are prompting Claude and kind of figuring out what to do.
My job is to write loops."](https://www.youtube.com/watch?v=RkQQ7WEor7w&t=11m45s) — *Acquired
Unplugged*, presented by WorkOS, Jun 2026 (~11:45).

*Cherny himself uninstalled his IDE at the end of Stage 1 — November 2025, after Opus 4.5
shipped — a stage before he began writing loops; by Stage 3 the IDE is gone either way.*

The altitude shift, as one observer summarised it: "The job did not vanish. It moved up an
altitude, from writing the code to writing the thing that writes the code."
([Matt Van Horn, "WTF Is a Loop? Peter Steinberger vs. Boris Cherny"](https://x.com/mvanhorn/status/2063865685558903149),
Jun 2026 — Van Horn's own framing, not a Cherny quotation.)

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
> bounds…" — [@steipete](https://x.com/steipete) / [@shivangchheda22](https://x.com/shivangchheda22)

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

For the eight named loop patterns with their default levels, token costs, and
coordination rules, see [Loop Patterns](34-loop-patterns.md).

(Cobus Greyling, [cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering), Jun 2026.)

**Recency-weighted maturity.** A later release of the same repo's readiness scorer weights
recent runs harder than artifact presence on disk: *"Loop Ready now weights recent runs harder
than files on disk. A 30-day-old STATE.md is not L3."* Closes an anti-gaming gap the table above
doesn't address — a loop that stops running should degrade its own readiness score, not keep
reading as mature because its artifacts are still on disk. A follow-on academic study cites this
repo (as Greyling, 2026b) as the "community reference repository" from which its loop-detection
heuristics were drafted (and, at its 2026-07-15 access, as having seven loop patterns).
([cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering), "Loop Ready" score, Sep 2026; [arXiv 2608.21884, Lulla et al., "Loop Engineering: Building Blocks, Adoption, and Impact"](https://arxiv.org/abs/2608.21884), Aug 2026.)

**Score what is proven, not what is present.** The same repo's own `loop-audit` scorer gave a
repo of 19 empty files (142 bytes) a 100/L3 because nearly every signal was a `fileExists()` check.
Per the [commit message](https://github.com/cobusgreyling/loop-engineering/commit/6b96a16d56532fe669819d59aa27e51ec37d0387)
(2026-10-10), it now ignores placeholders, requires name and description frontmatter for skills
and verifier agents, and gates L3 on `loop-drill.json` proofs that the current `gate.yaml`
(sha256-pinned, line-ending normalised) passes its drills in both directions. Read against the
table above, an L3 claim built on artifacts alone is the failure this fixes: the L2-to-L3 gate
should ask for evidence that the gate was exercised, not for the files that describe it. See also
[Loop Contract → guards that failed open](27-loop-contract.md#guards-that-failed-open).

## Four loop structures by trigger and exit

A Devoxx deck by Guillaume Laforge and Wietse Venema
([Speaker Deck](https://speakerdeck.com/glaforge/loop-engineering-beyond-prompt-context-and-harness-engineering),
2026-10-06; PDF text read, the slide checked as an image; see [Context vs. Loop Engineering](21-context-vs-loop-engineering.md#discourse-snapshot-2026-10-19))
sorts loops by who starts them and who ends them. The slide cites
[Macedo, arXiv 2607.00038](https://arxiv.org/abs/2607.00038); only that paper's abstract was read, so the quadrant
below is the deck's, not necessarily the paper's.

| Structure (slide label) | Trigger | Exit | Trigger / exit, as placed on the slide |
|---|---|---|---|
| Turn-based (exploratory) | user prompt | human review | manual / manual |
| Goal-based (measurable) | `/goal` command | evaluator model confirms criteria met | manual / autonomous |
| Time-based (recurring) | clock / cron interval | fixed routine completion | autonomous / manual |
| Proactive (standing resp.) | external event (webhook, Slack) | adversarial verifier agent signs off | autonomous / autonomous |

My reading, not the deck's: only the goal-based and proactive rows have an autonomous exit, so those are the rows where
the L2-to-L3 question above (has the verifier been shown to work, not merely exist) has to be answered.

**A second corpus count (abstract only).** Macedo's abstract reports a hand-coded corpus of fifty public loops (the "Loop
Library"): 70% verify in the "autonomous zone" of its five-level verification ladder and 74% name their terminal states,
while "automated triggering and durable memory remain comparatively underdeveloped". The weak dimension matches the
Lulla et al. finding in [docs/21](21-context-vs-loop-engineering.md) that almost none commit state files, though the
corpora and methods differ, and neither was replicated here.

## Related

- [The Paradigm Shift](01-paradigm-shift.md)
- [Common Failure Patterns](17-failure-patterns.md) — "No stopping condition"
- [Verification](04-verification.md)
- [Memory Patterns](16-memory-patterns.md)
