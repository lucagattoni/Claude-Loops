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
