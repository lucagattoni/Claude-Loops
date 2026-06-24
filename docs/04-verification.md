# Verification: The Non-Negotiable Foundation

> A loop is only as trustworthy as its ability to check its own work.

Without verification, the loop has no stopping condition — it either halts too early
("looks done") or spins forever. **Always give Claude a check it can run.**

A check is anything that returns a pass/fail signal Claude can read:

- Test suite (`npm test`, `pytest`, `cargo test`)
- Build exit code (`npm run build`)
- Linter (`eslint`, `ruff`)
- Script that diffs output against a fixture
- Browser screenshot compared against a design
- A separate evaluator model (a subagent that did not write the code)

## Verification strategies

| Scope | Mechanism | How to set it up |
|---|---|---|
| Single prompt | Ask Claude to run the check and iterate in the same message | `"implement X. run tests after. fix any failures."` |
| Across a session | `/goal` condition | `"my goal is: all tests pass and the build succeeds"` |
| Deterministic gate | Stop hook | Runs a script; blocks the turn from ending until it passes |
| Independent review | Verification subagent | Fresh model reviews the diff, not the work-in-progress |

## Making subjective goals gradable

Verification only works if the success criteria are specific enough for an agent to
check them. For subjective goals (design quality, code style, UX), convert them into
four measurable dimensions before writing the loop:

| Dimension | Question | Example criterion |
|---|---|---|
| **Quality** | Does it feel coherent — not fragmented or accidental? | No element looks like a default placeholder |
| **Originality** | Is there evidence of a deliberate decision? | At least one non-standard colour or layout choice |
| **Craft** | Are the technical details correct? | Typography scale consistent, contrast ≥ 4.5:1 |
| **Functionality** | Does it work independently of aesthetics? | All interactive elements respond correctly |

Weight the first two heavily to push models away from generic outputs. Encoding these
as explicit criteria (rather than prose instructions) makes them evaluable by a
separate agent and reduces the ambiguity that leads to self-evaluation bias.

(Prithvi Rajasekaran, Anthropic Engineering, Mar 2026.)

## The self-verifying loop pattern

```text
1. Claude implements the feature
2. Claude runs: npm test
3. If tests fail → Claude reads output, edits code, re-runs
4. Loop ends only when tests pass
5. Stop hook runs linter as a final gate before the turn closes
```

**Show evidence, not assertions.** Have Claude output the test result, the command
it ran, and what it returned. Reviewing evidence is faster than re-running
verification yourself.

## Simplification Before Testing

Standard practice: write tests, then verify the implementation passes them.
When AI generates the implementation, this creates a trap: if the AI produces
a working but structurally poor implementation, tests written against it cement
the suboptimal structure. Passing tests make refactoring feel risky.

**Inversion:** run a dedicated simplification pass on AI-generated code *before*
writing tests. The simplification agent has one job — make the code cleaner and
more intelligible — without the pressure of test coverage. Then write tests against
the simplified code.

This is Wave 4 in the five-wave execution model. See [Harness Patterns](24-harness-patterns.md).

(session-orchestrator — Kanevry/session-orchestrator, Jun 2026.)

## Verification of Memory, Not Just Code

Loops with persistent state (GOAL.md, STATE.md, PROGRESS.md) accumulate stale
entries over time. A verification pass that checks only code output misses a
category of failure where correct code acts on incorrect state.

Before acting on any persistent memory record:
1. Validate that referenced items still exist (PR not merged, issue not closed, branch not deleted)
2. Re-read the original source rather than trusting the memory summary
3. Treat any memory record older than a defined threshold (e.g. 24h) as unverified

> "Stale memory records must be revalidated against present reality before
> recommendations." — wquguru/harness-books

Apply this specifically to: STATE.md watchlists, GOAL.md execution logs,
PROGRESS.md task statuses, and any cached API responses.

(wquguru/harness-books, AgentWay, Jun 2026.)

## Real-world case study: Mozilla Firefox security harness

Brian Grinstead (Anthropic, Jun 2026) built a security bug-finding harness for
Mozilla Firefox with explicit verification at every stage:

1. **LLM file prioritization** — a scoring model ranked files by bug likelihood before
   allocating agents; agents spent time on high-signal targets, not a full codebase scan
2. **score → fix → verify pipeline** — three mandatory sequential stages; no stage was
   skipped even when previous output "looked correct"
3. **Dedicated verifier subagent** — a fresh agent, not the bug-finder, confirmed each
   fix and eliminated false positives; tuned explicitly to avoid accepting fixes with
   unresolved edge cases

**Result:** 423 security bug fixes in one month.

> "The harness was responsible for roughly 50% of the results — the model alone
> wouldn't have delivered this." — Brian Grinstead

This confirms the compound probability argument in [The Paradigm Shift](01-paradigm-shift.md):
the verification chain converts per-step model accuracy into end-to-end reliable output.
