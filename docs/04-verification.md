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

## Verification Classification: Type A vs. Type B Work

Before designing a verifier, classify the work being verified:

| Type | Definition | Verification approach |
|---|---|---|
| **Type A** | Fully automatable mechanics — dispatch, execution, evidence collection, commit, index update | Machine-checkable gates (CI, exit codes, diff counts) — no human needed |
| **Type B** | Human judgment gates — design decisions, ambiguity resolution, irreversible actions requiring context | Mandatory human approval; cannot be delegated to an automated verifier |

The loop's job is to automate Type A completely and route Type B to humans reliably. A loop that tries to auto-verify Type B work (using LLM judges to approve irreversible actions) introduces [Verifier Theater](17-failure-patterns.md).

(void2610/loop, Jun 2026.)

## Loop Verdict Taxonomy

Every loop run should produce one of six verdicts — not just pass/fail:

| Verdict | Meaning | Next action |
|---|---|---|
| **pass** | All done conditions met; evidence present | Merge / deploy / close |
| **fail** | Done conditions not met; retryable | Retry with attempt cap |
| **handoff** | Type B work reached; human judgment required | Route to human inbox |
| **timeout** | Turn or budget cap hit before completion | Resume or escalate |
| **stopped** | Hard stop triggered (security gate, denial hook) | Investigate root cause |
| **awaiting-merge** | Completion gated on an external event | Monitor; do not retry yet |

A loop that only outputs pass/fail misses the handoff, timeout, and stopped states that require different downstream responses.

(void2610/loop, Jun 2026.)

## Cross-Run Verification Patterns

Standard verification re-runs the same checks each loop iteration. Three patterns extend verification across independent runs:

**Clean-Room Review:** The reviewer agent runs in a fresh session with no access to the implementer's reasoning — only the output artifact (diff, PR, test results). This prevents the reviewer from reasoning from the same context as the implementer and catching failures the implementer reasoned itself into.

**Held-Out Test Layer:** A set of perturbed inputs is generated before coding begins and kept hidden from the implementing agent. After implementation, the held-out tests run. A passing implementation that fails on held-out perturbations reveals over-fitting to the expected examples.

**Cross-Task Defect Ledger:** When a run produces a defect (test failure, type error, security finding), the defect is logged to a shared ledger with root-cause category. Subsequent runs read the ledger before starting and explicitly check for the same root-cause categories. Defects stop being repeated rather than just fixed.

(JeremyW1990/loop-engineering-skill, Jun 2026.)

## Belief State Machine for Claim Verification

When agent output contains factual claims (about APIs, configurations, security posture), classify each claim before acting on it:

| State | What it means | Required evidence |
|---|---|---|
| **source_prior** | Claim comes directly from a cited source (doc, test, API response) | Source URL or command output |
| **bounded_claim** | Claim is agent-generated but grounded in cited source_prior evidence | Explicit derivation from source_prior |
| **validated** | Claim has been independently checked by a deterministic verifier | Test result, grep, CI output |

Never act on a claim that remains in the `source_prior` or `bounded_claim` state for irreversible actions (deploys, security changes, data migrations). Require `validated` evidence.

**R0–R5 Risk Classification** — score tasks at intake before execution:

| Level | Risk | Policy |
|---|---|---|
| R0 | Read-only | Auto-approve; no verifier required |
| R1 | Reversible write | Auto-approve; commit-level evidence required |
| R2 | Merge-gated | Human review gate; test suite must pass |
| R3 | Prod-adjacent | Human review gate + second reviewer |
| R4 | Irreversible (data, secrets) | Explicit human approval before execution |
| R5 | Security-critical | SECURITY_MATRIX.md gate + security reviewer (see [Agent Security Hardening](33-agent-security-hardening.md)) |

(qimen039-code/claim-boundary-harness, Jun 2026.)

## A/A Baseline for Verifier Calibration

Before trusting a verifier's verdicts, establish a noise floor using A/A testing:

1. **Baseline run:** run the verifier on two identical implementations — it should produce identical verdicts; any disagreement is pure noise
2. **Noise floor:** if the verifier disagrees on ≥5% of identical cases, its signal is too noisy to trust for pass/fail gates
3. **Only deterministic graders** for binary gates: test exit codes, diff line counts, grep match counts — never LLM-generated scores
4. **Bootstrap confidence intervals:** when comparing two configurations, require ≥95% CI overlap to confirm a real improvement vs. noise

Verifiers calibrated only on happy-path inputs will fail on the edge cases that matter most — the A/A baseline catches this before deployment.

(thalys/agent-ab, Jun 2026.)

## Production Trace to Regression Test

Production failures are the most valuable input for improving loop verification. When a
loop run fails in production:

1. Capture the full execution trace (tool calls, inputs, outputs, error state)
2. Convert the trace into a deterministic regression fixture that reproduces the exact failure
3. Add to the held-out test suite — the same failure cannot now recur silently

**Comet's Opik** (open-source) implements this automatically: it traces every tool call
and, when a run produces an unexpected verdict, generates a regression fixture from the
failing trace.

The distinction from the A/A Baseline (which establishes noise floor on passing cases):
this pattern captures *real failure modes* from production runs, not synthetic variations.
The two are complementary — the A/A baseline cleans up the verifier before deployment;
the production trace pattern hardens it afterward.

repo: github.com/comet-ml/opik

(@akshay_pachaar, DailyDoseofDS, Jun 2026.)

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
