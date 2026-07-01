# Verification: The Non-Negotiable Foundation

> A loop is only as trustworthy as its ability to check its own work.

Without verification, the loop has no stopping condition — it either halts too early
("looks done") or spins forever. **Always give Claude a check it can run.**

Verification *is* the loop's success stop: it is the **completion check** in the
[Stop Condition Taxonomy](27-loop-contract.md#stop-condition-taxonomy). Budget,
max-iteration, and no-progress stops only contain a loop; the completion check is the
only one that lets it succeed — and it is exactly as trustworthy as the verifier behind
it. "An agent loop without a verifier just compounds its own mistakes on a schedule."

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

(session-orchestrator — [Kanevry/session-orchestrator](https://github.com/Kanevry/session-orchestrator), Jun 2026.)

## Verification of Memory, Not Just Code

Loops with persistent state (GOAL.md, STATE.md, PROGRESS.md) accumulate stale
entries over time. A verification pass that checks only code output misses a
category of failure where correct code acts on incorrect state.

Before acting on any persistent memory record:
1. Validate that referenced items still exist (PR not merged, issue not closed, branch not deleted)
2. Re-read the original source rather than trusting the memory summary
3. Treat any memory record older than a defined threshold (e.g. 24h) as unverified

> "Stale memory records must be revalidated against present reality before
> recommendations." — [wquguru/harness-books](https://github.com/wquguru/harness-books)

Apply this specifically to: STATE.md watchlists, GOAL.md execution logs,
PROGRESS.md task statuses, and any cached API responses.

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

## Verification Classification: Type A vs. Type B Work

Before designing a verifier, classify the work being verified:

| Type | Definition | Verification approach |
|---|---|---|
| **Type A** | Fully automatable mechanics — dispatch, execution, evidence collection, commit, index update | Machine-checkable gates (CI, exit codes, diff counts) — no human needed |
| **Type B** | Human judgment gates — design decisions, ambiguity resolution, irreversible actions requiring context | Mandatory human approval; cannot be delegated to an automated verifier |

The loop's job is to automate Type A completely and route Type B to humans reliably. A loop that tries to auto-verify Type B work (using LLM judges to approve irreversible actions) introduces [Verifier Theater](17-failure-patterns.md).

([void2610/loop](https://github.com/void2610/loop), Jun 2026.)

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

([void2610/loop](https://github.com/void2610/loop), Jun 2026.)

## Cross-Run Verification Patterns

Standard verification re-runs the same checks each loop iteration. Three patterns extend verification across independent runs:

**Clean-Room Review:** The reviewer agent runs in a fresh session with no access to the implementer's reasoning — only the output artifact (diff, PR, test results). This prevents the reviewer from reasoning from the same context as the implementer and catching failures the implementer reasoned itself into.

**Held-Out Test Layer:** A set of perturbed inputs is generated before coding begins and kept hidden from the implementing agent. After implementation, the held-out tests run. A passing implementation that fails on held-out perturbations reveals over-fitting to the expected examples.

**Cross-Task Defect Ledger:** When a run produces a defect (test failure, type error, security finding), the defect is logged to a shared ledger with root-cause category. Subsequent runs read the ledger before starting and explicitly check for the same root-cause categories. Defects stop being repeated rather than just fixed.

([JeremyW1990/loop-engineering-skill](https://github.com/JeremyW1990/loop-engineering-skill), Jun 2026.)

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

([qimen039-code/claim-boundary-harness](https://github.com/qimen039-code/claim-boundary-harness), Jun 2026.)

## A/A Baseline for Verifier Calibration

Before trusting a verifier's verdicts, establish a noise floor using A/A testing:

1. **Baseline run:** run the verifier on two identical implementations — it should produce identical verdicts; any disagreement is pure noise
2. **Noise floor:** if the verifier disagrees on ≥5% of identical cases, its signal is too noisy to trust for pass/fail gates
3. **Only deterministic graders** for binary gates: test exit codes, diff line counts, grep match counts — never LLM-generated scores
4. **Bootstrap confidence intervals:** when comparing two configurations, require ≥95% CI overlap to confirm a real improvement vs. noise

Verifiers calibrated only on happy-path inputs will fail on the edge cases that matter most — the A/A baseline catches this before deployment.

([thalys/agent-ab](https://github.com/thalys/agent-ab), Jun 2026.)

## Verifier Integrity: Keeping the Check Unfakeable

A verifier only protects the loop if the agent cannot quietly defeat it. Five
patterns, converging across independent Claude-Code loop harnesses (Jun 2026), keep
the check honest:

**1. The external verifier — the loop runs the check, not the agent.** In the
`loop-kernel` design the control loop itself executes the real check command every
iteration and reads the exit code; the worker never reports its own success.
"The kernel runs your REAL check every iteration (worker can't fake)" and "editing or
skipping your tests changes nothing — the kernel re-runs the real command every
iteration." The principle: **the control system is fixed and deterministic; the worker
is stochastic and swappable.** This is the architectural cure for [Verifier Theater](17-failure-patterns.md)
— the agent cannot approve itself because approval lives outside the agent.
([uppifyagency/loop-kernel](https://github.com/uppifyagency/loop-kernel), Jun 2026.)

**2. Mechanical gates vs. adjudicators — two kinds of check, kept separate.**

| Check type | Observes | Example |
|---|---|---|
| **Mechanical gate** | Runtime properties only the environment can see | `gate.sh` exit code, build, test suite, CI |
| **Adjudicator** | Whether a diff satisfies discrete acceptance criteria | read-only judge agent emitting structured JSON |

Keeping them separate is what prevents infinite loops: "adjudicators cannot mistake
weakened tests for correctness; gates catch what agents cannot verify structurally."
Correctness rests on `git + exit codes + structured JSON contracts`, decoupled from
the agent's output format. ([firegnu/herdr-loop-lab](https://github.com/firegnu/herdr-loop-lab), Jun 2026.)

**3. Frozen tests — pin the contract before the implementer can touch it.** A separate
role authors the test, it is pinned by **content-hash** and made read-only, and only
then does the implementing agent write code against it. The implementer "writes against
a read-only test it cannot touch," so it cannot pass by weakening the assertion.
Completion is reconstructed independently (`git diff` from the freeze commit + a real
test re-run), "not reported by the model."

This is complementary to [Simplification Before Testing](#simplification-before-testing),
not in conflict with it: simplification decides *what shape* the code and test should
take (and may run first); freezing decides *who may change the test afterwards* (the
implementer may not). ([orobsonn/claude-harness](https://github.com/orobsonn/claude-harness), Jun 2026.)

**4. Provenance-bound claims — every assertion must cite a verifiable artifact.** The
three patterns above keep the *check* honest; this one keeps the *report* honest. The
agent does not get to say "done" in prose — every finding or completion claim must cite
a git SHA, and a separate guard re-verifies the citation against the object store
(`git cat-file`) before the claim is accepted. A claim that points at no real artifact,
or at an artifact whose content does not match, is rejected automatically. Layered on
top: a **majority-vote / monitor council** — several independent read-only judges score
the same diff and completion is gated on their agreement, never on a single grader the
worker could collude with. Together these defeat the failure where an agent fabricates
evidence ("tests pass", "bug fixed at commit X") that no artifact supports. The
principle generalises the external-verifier idea from "re-run the check" to **"bind every
claim to an inspectable, unforgeable artifact and have more than one judge confirm it."**
([krishddd/Strive_Engineering](https://github.com/krishddd/Strive_Engineering), Jun 2026.)

**Isomorphic-perturbation checks (anti single-predicate reward-hacking).** A refinement
from the same harness: validate each claim under *two independent-but-equivalent* checks
(e.g. a literal `git cat-file -e` existence test **plus** a full object-ID re-derivation).
A gap that passes one check but fails its logical equivalent has found a single-predicate
shortcut — it is reward-hacking the specific predicate rather than genuinely satisfying the
goal — and the verifier exits non-zero. This generalises the [A/A baseline](#aa-baseline-for-verifier-calibration)
idea from "run the same check twice" to "run two equivalent checks once each; demand they
agree." ([krishddd/Strive_Engineering](https://github.com/krishddd/Strive_Engineering), Jun 2026.)

**5. Cross-model independence — the checker runs a different model than the maker.** The
first four patterns keep the checker *structurally* independent (fresh context, separate
role, external command). This pattern adds a **model-diversity** axis: the reviewer runs on
a *different model* from the implementer, so the two do not share training blind spots or
failure modes. The recurring Jun 2026 configuration is **Claude implements, Codex reviews** —
the implementer writes broad multi-file changes and a separate reviewer model independently
inspects the diff, with roles often not fixed (either model can implement or review). The
argument: a same-model checker, however fresh its context, can rationalise the same mistakes
the maker made because it reasons from the same priors; a *different* model is likelier to
catch what the first is systematically blind to, and the two models' disagreement becomes the
productive tension that drives another iteration. These harnesses pair the cross-model
reviewer with a **structured verdict schema** that separates blocking from non-blocking
findings — reviewers emit `VERDICT: PASS` / `VERDICT: BLOCK` plus advisory `SUGGEST:` lines —
and gate completion on a **dual stop condition**: the loop terminates only when the mechanical
test command exits 0 **and** the reviewer raises no `BLOCK`. Multiple reviewers on the same
workspace aggregate by "any blocker ⇒ blocked." ([Happenmass/Cliclaw](https://github.com/Happenmass/Cliclaw),
[mateaix/loope](https://github.com/mateaix/loope), [firegnu/herdr-loop-lab](https://github.com/firegnu/herdr-loop-lab),
[Llicklair/forja](https://github.com/Llicklair/forja), Jun 2026.)

These five together — external verifier, mechanical-gate/adjudicator split, frozen tests,
provenance-bound claims (with isomorphic-perturbation checks), and cross-model independence —
are the converging community answer to [Verifier Theater](17-failure-patterns.md): the
verifier, the contract, and the evidence all live outside the agent's reach, no single judge
can wave work through, and the judge that does check does not share the maker's blind spots.

## Eval Metrics: pass@k vs. pass^k

A single pass/fail run cannot tell you whether a loop is *reliably* correct or just
got lucky. Because agents are stochastic, measure success across repeated trials:

| Metric | Definition | Use it to answer |
|---|---|---|
| **pass@k** | At least one success in `k` attempts | "*Can* the loop do this?" — capability |
| **pass^k** | *All* `k` trials succeed | "Is it safe to run *unattended*?" — reliability |

`pass@1` is the raw first-attempt rate; `pass@3` allows up to two retries. A useful
target for capability evals is **`pass@3 > 90%`**; for critical paths that must not
fail even once, require **`pass^3 = 100%`**. The gap between a high pass@k and a low
pass^k is exactly the flakiness a stochastic loop hides — a loop can look capable
(pass@3 high) while being unsafe to automate (pass^3 low).

Grade each trial with one of three grader types (escalating in cost and subjectivity):

| Grader | Mechanism | When |
|---|---|---|
| **Code-based** | Deterministic — grep, test runner, build exit code | Objective, binary criteria (prefer for gates) |
| **Model-based** | A judge model scores open-ended criteria | Subjective quality (see [Opik](#llm-as-a-judge-verification-with-opik) below) |
| **Human** | Flagged for manual review, risk-tiered LOW/MED/HIGH | Type B / irreversible work (see [Human-in-the-Loop](14-human-in-the-loop.md)) |

Only code-based graders belong in a binary pass/fail gate — this is the same
constraint the [A/A Baseline](#aa-baseline-for-verifier-calibration) imposes: never
gate on an LLM-generated score. pass^k on a code-based grader is the quantitative
form of the "safe to run unattended" question the [Loop Readiness Levels](34-loop-patterns.md)
answer qualitatively.

([affaan-m/ecc](https://github.com/affaan-m/ecc) `eval-harness` skill, Jun 2026.)

**Blend human and model grading with an explicit weight.** When neither a code-based
grader nor an LLM judge alone is trustworthy, blend them at a stated ratio rather than
picking one. One reusable model-comparison harness scores with **70% human "vibe" +
30% LLM-judge**, using a local HTML page that exports gut-feel ratings to JSON for a
blind comparison — the weighting is a design decision, not an accident, and it keeps a
human majority-stake in subjective calls while still scaling. (Claire Vo, ["Sonnet 5
review: I ran 64 generations"](https://www.lennysnewsletter.com/p/sonnet-5-review-i-ran-64-generations), Jun 2026.)

## Proof-of-Work Artifacts: the Verifiable Demo

Not every hand-off can be reduced to a pass/fail exit code. For UI/UX work, the
verification artifact can be a **recorded demo the agent produces itself**: the agent
writes a YAML "storyboard" of interaction steps, Playwright drives the browser, and the
result is a video that shows the feature actually working — "the importance of having
coding agents produce demos of their work." This is a *human-viewable* verification
artifact, complementary to (not a replacement for) the machine-checked gates above:
it closes the gap for behaviour a test suite can't fully assert, and it is what a human
reviews at a [handoff](14-human-in-the-loop.md) checkpoint.

(Simon Willison, ["shot-scraper video"](https://simonwillison.net/2026/Jun/30/shot-scraper-video/), Jun 2026.)

## LLM-as-a-Judge Verification with Opik

**[Comet's Opik](https://github.com/comet-ml/opik)** (open-source, 40M+ traces/day) provides a verification layer
specifically designed for LLM output quality — not just pass/fail exit codes.

**Evaluation metrics** (callable via `.score()` API):
- `hallucination` — detects factual claims not grounded in the context
- `answer_relevance` — scores whether the agent's output addresses the actual task
- `context_precision` — measures how precisely the context supports the answer
- `moderation` — flags unsafe or policy-violating output

**Online Evaluation Rules** — configure continuous scoring against a running production loop:
a judge model monitors every run and alerts when metric scores fall below a threshold.
This is the fleet-level equivalent of a test suite: instead of checking one run, it
watches the whole fleet continuously.

**PyTest CI/CD integration** — evaluations run in CI pipelines as part of the test suite.
A harness that passes code tests but fails answer-relevance scores is not production-ready.

The distinction from the A/A Baseline (which establishes noise floor on a verifier's
*consistency*): Opik's metrics measure the *quality* of agent output directly.

repo: [github.com/comet-ml/opik](https://github.com/comet-ml/opik)

(Comet ML, Jun 2026.)

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

## "Surface" — the Canonical Stopping Verb

When a loop reaches a point requiring human judgment, the agent's action has a precise name:

**Surface** — stop the current loop, emit a short description of the situation (what happened,
what you tried, what state things are in), and wait for human direction.
**Do not retry, do not redispatch, do not silently reset.**

This is the distinction from other verdicts:
- `fail` — retryable; the agent should try again with attempt cap
- `stopped` — hard gate fired; investigate root cause
- `handoff` — human judgment required; **this is the Surface action**: emit a clear situation
  report and halt

A loop that surfaces correctly is more trustworthy than one that retries indefinitely: it
shows the agent knows the boundary of its own competence.

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Jun 2026.)

## Verification Mode Discipline

Before writing any test or verifier, declare which of three verification modes applies.
A mode-mismatched test passes for the wrong reason.

| Mode | When to use | Key constraint |
|---|---|---|
| **TDD** | Pure functions, state machines, protocols | Test must pin a real invariant — not mirror the implementation. Tests that change in lockstep with production code are mirrors, not contracts. |
| **Goal-based check** | Verify an artifact exists or has a shape | The one-liner verification *is* the contract; no extra test file needed. |
| **Visual / manual QA** | UI behaviour, rendering, layout | Invariants must be named (not "no crash"); input variation must be recorded or seeded reproducibly. |

**Level-of-abstraction rule:** verification level must match the behavior boundary being tested.
UI behaviors need tests that simulate the user's gesture and assert on rendered/visible state —
not unit tests on the controller. "Mode-mismatched verification produces tests that pass for
the wrong reason."

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Jun 2026.)

## Self-Coverage Gate

A formal stopping condition that requires every item in the loop's declared scope to have at least one verification artifact before the loop can exit (eugenelim/agent-ready-repo, RFC-0051, Jun 2026).

**The gate asks:** for every scope item, does a corresponding artifact exist (test, goal-check, visual proof)? If not, the loop is incomplete — it has missing coverage, not just failing tests.

The self-coverage check differs from test pass/fail:
- Test failure → implementation is wrong; retry
- Coverage failure → the verification layer itself is incomplete; the loop must write the missing check before it can exit

**Implementation:** a Stop hook reads SCOPE.md and checks every scope item against the current test/check index. Items without coverage artifacts fail the gate and prevent the turn from closing. See [Hooks](12-hooks.md) for the Stop hook exit code contract.

**Traceability-lint** — a related gate checking that every output artifact carries a traceable chain from scope item → task → implementation → verification → done evidence. A traceability-lint failure means the evidence chain is broken: the artifact exists, but its link to the original scope requirement is missing. Implemented as a pre-commit hook that validates task metadata.

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), RFC-0048/RFC-0051, Jun 2026.)

## Oracle Problem in AI-Generated Tests

When the same agent writes both code and tests in the same session, tests exhibit
~6% precision — they verify what the implementation *does* rather than what it *should* do.

This is the **oracle leakage** problem: the agent uses its knowledge of the implementation
to construct tests that are tautologically true. A test for `add(2, 3)` that expects `5`
is a valid oracle; a test for `process_record(x)` that expects the same output as the
function currently produces is a tautology, not a contract.

Mitigation: the critic or verifier agent must explicitly guard against oracle leakage —
checking that tests would still fail if the implementation returned a semantically different
result, not just a different bit pattern.

([JeiKeiLim/tenet](https://github.com/JeiKeiLim/tenet), Jun 2026.)

## Structured Critic Finding Taxonomy

A critic that produces a binary pass/fail verdict cannot be triaged, routed, or tracked
over time. Critic output should use structured finding categories:

| Category | Meaning | Downstream action |
|---|---|---|
| `product_bug` | Incorrect behaviour in the feature being built | Block merge; loop must fix |
| `test_bug` | Test is wrong, not the implementation (oracle leakage) | Fix the test; loop continues |
| `harness_bug` | Issue is in the loop infrastructure itself | Pause loop; human fixes harness |
| `evidence_mismatch` | Verdict claim not supported by submitted evidence | Reject; require evidence |
| `contention` | Two concurrent loop changes conflict with each other | Route to coordination layer |
| `scope_conflict` | Change touches paths outside the declared scope | Reject; loop must re-scope |

`harness_bug` and `contention` are non-retriable: they should surface as `handoff` verdicts
and never trigger automatic retry.

([JeiKeiLim/tenet](https://github.com/JeiKeiLim/tenet), Jun 2026.)

This confirms the compound probability argument in [The Paradigm Shift](01-paradigm-shift.md):
the verification chain converts per-step model accuracy into end-to-end reliable output.
