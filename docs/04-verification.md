# Verification: The Non-Negotiable Foundation

> A loop is only as trustworthy as its ability to check its own work.

Without verification, the loop has no stopping condition — it either halts too early
("looks done") or spins forever. **Always give Claude a check it can run.**

Verification *is* the loop's success stop: it is the **completion check** in the
[Stop Condition Taxonomy](27-loop-contract.md#stop-condition-taxonomy). Budget,
max-iteration, and no-progress stops only contain a loop; the completion check is the
only one that lets it succeed — and it is exactly as trustworthy as the verifier behind
it. "An agent loop without a verifier just compounds its own mistakes on a schedule."
([@bojan_ai](https://x.com/bojan_ai/status/2070433693957558636), Jun 2026.)

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

(Prithvi Rajasekaran, [Anthropic Engineering — "Harness design for long-running application development"](https://www.anthropic.com/engineering/harness-design-long-running-apps), Mar 2026.)

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

> "…memory records can become stale; before giving recommendations from memory, verify
> current state; when memory conflicts with present reality, trust the current observed
> state and update or delete stale memory."
> — [wquguru/harness-books](https://github.com/wquguru/harness-books), ch. 7 §7.7

Apply this specifically to: STATE.md watchlists, GOAL.md execution logs,
PROGRESS.md task statuses, and any cached API responses.

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

## Verification Classification: Type A vs. Type B Work

Before designing a verifier, classify the work being verified:

| Type | Definition | Verification approach |
|---|---|---|
| **Type A** | Fully automatable mechanics — dispatch, execution, evidence collection, commit, index update | Machine-checkable gates (CI, exit codes, diff counts) — no human needed |
| **Type B** | Human judgment gates — reviewing raw run output for trustworthiness and failure points, real-time calls when an agent is stuck on policy or permissions, and approving irreversible actions (e.g. merging a PR) | Mandatory human approval; the resulting lessons feed future automated-verifier design, but the judgment itself cannot be delegated to one |

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

**The holdout wall — evaluator-only, path-only disclosure.** A refinement that hardens
where the held-out layer physically lives: the acceptance checklist exists only inside the
evaluator's role, and the generator (which negotiates its own "done" contract) is passed
the holdout's *path*, never its content, and receives back only the evaluator's parsed
verdict — never the checklist itself. This closes a gap the basic pattern leaves open: a
"hidden" test the implementer's agent could still read from disk if both roles share a
filesystem view. Cross-model pairing (e.g. Claude builds, Codex judges) is configured
explicitly per role rather than auto-selected, which sharpens *how* to hold a test out but
leaves *which model pair* to use an open, user-judged choice.
([Kristopher Baker, "Sparra"](https://krisbaker.com/building/sparra/), Jul 2026 — the GitHub repo this project page links to now returns 404, checked 2026-09-05.)

**Cross-Task Defect Ledger:** When a run produces a defect (test failure, type error, security finding), the defect is logged to a shared ledger with root-cause category. Subsequent runs read the ledger before starting and explicitly check for the same root-cause categories. Defects stop being repeated rather than just fixed.

([JeremyW1990/loop-engineering-skill](https://github.com/JeremyW1990/loop-engineering-skill), Jun 2026.)

## Reviewer Freshness Enforcement

Clean-Room Review (above) says the reviewer must run in a fresh session. This pattern
gives a mechanism for *why that isn't enough on its own* and what "fresh" must actually
mean.

**Two independence axes, not one.** "Model independence" (a different AI system reviews
the work) and "perspective independence" (the *same* model, but with no shared
conversation history) catch different failure classes — a same-model reviewer with a
clean session still avoids context-poisoning from the implementer's rationalizations,
even though it shares the model's blind spots. Both axes are needed; neither substitutes
for the other.

**Priming defeats freshness.** A reviewer told what verdict is expected — even
implicitly, by seeing the implementer's draft or reasoning before forming its own
judgment — produces compliance, not review. The enforcement rule: a fresh reviewer must
see only the problem statement and constraints, **never the draft**, until it has
produced its own independent solution. The divergence between the reviewer's independent
solution and the original draft is the highest-signal output of the whole review — it
surfaces hidden framing assumptions the implementer couldn't see from inside their own
reasoning.

**The synthesizer problem.** Even with a perfectly fresh reviewer, the *human or agent who
reconciles* the two solutions remains the most biased party in the loop — they already
have an opinion before synthesis begins. Mitigation: log every rejection alongside every
acceptance (not just the accepted changes), and define convergence operationally as "no
further draft changes after synthesis" rather than "the synthesizer feels satisfied."

This is a concrete answer to the reviewer-freshness-enforcement question Clean-Room
Review leaves open: freshness isn't just "spawn a new session" — it requires withholding
the draft until independent judgment is formed, and auditing the synthesis step itself for
the same bias the fresh reviewer was meant to avoid.

([beingcognitive/unprimed-dialectic](https://github.com/beingcognitive/unprimed-dialectic), Jun 2026.)

## Belief State Machine for Claim Verification

When agent output contains factual claims (about APIs, configurations, security posture), classify each claim before acting on it:

| State | What it means | Required evidence |
|---|---|---|
| **source_prior** | Claim comes directly from a cited source (doc, test, API response) | Source URL or command output |
| **bounded_claim** | Claim is agent-generated but grounded in cited source_prior evidence | Explicit derivation from source_prior |
| **validated** | Claim has been independently checked by a deterministic verifier | Test result, grep, CI output |

Never act on a claim that remains in the `source_prior` or `bounded_claim` state for irreversible actions (deploys, security changes, data migrations). Require `validated` evidence.

**R0–R5 Risk Classification** — score tasks at intake before execution. The ladder below is
this KB's own generalized tiering (its R5 row folds in this KB's own
[SECURITY_MATRIX.md](33-agent-security-hardening.md) convention); it is not a verbatim policy
from any single cited project:

| Level | Risk | Policy |
|---|---|---|
| R0 | Read-only | Auto-approve; no verifier required |
| R1 | Reversible write | Auto-approve; commit-level evidence required |
| R2 | Merge-gated | Human review gate; test suite must pass |
| R3 | Prod-adjacent | Human review gate + second reviewer |
| R4 | Irreversible (data, secrets) | Explicit human approval before execution |
| R5 | Security-critical | SECURITY_MATRIX.md gate + security reviewer (see [Agent Security Hardening](33-agent-security-hardening.md)) |

The additive risk-routing *idea* — classify at intake, keep the highest level, union the required
gates — is shared with [qimen039-code/agent-cognitive-continuity-framework](https://github.com/qimen039-code/agent-cognitive-continuity-framework)
(Jun 2026), but that project's own R0–R5 tiers route by *task shape*, not by this
read/write/prod/security ladder: R0 is the default for trivial tasks, R1 read-only inspection,
R2 artifact/report, R3 implementation or governance-doc edits, R5 confirmed destructive actions
(`git push`, delete). It defines no `SECURITY_MATRIX.md` — that is this KB's own convention,
sourced in [Agent Security Hardening](33-agent-security-hardening.md) to jahwag/clem.
The adjacent `source_prior` / `bounded_claim` / `validated` taxonomy above *is* verbatim from
that project's README and stays as written.

## A/A Baseline for Verifier Calibration

Before trusting a verifier's verdicts, establish a noise floor using A/A testing:

1. **Baseline run:** run the verifier on two identical implementations — it should produce identical verdicts; any disagreement is pure noise
2. **Noise floor:** derive the noise floor empirically from the A/A run itself rather than assuming a fixed cutoff — agent-ab's own design note calls an assumed threshold (its example, "3× median") "the exact fragility this tool exists to avoid". Treat any specific disagreement percentage as a per-verifier rule of thumb you calibrate, not a figure from this source
3. **Only deterministic graders** for binary gates: test exit codes, diff line counts, grep match counts — never LLM-generated scores
4. **Bootstrap confidence intervals:** when comparing two configurations, compute a 95% bootstrap confidence interval on the *difference* of means — if that interval excludes zero, the effect is larger than run-to-run noise (agent-ab's own criterion; it is not a test of two intervals "overlapping")

Verifiers calibrated only on happy-path inputs will fail on the edge cases that matter most — the A/A baseline catches this before deployment.

([thalys/agent-ab](https://github.com/thalys/agent-ab), Jun 2026.)

## Verifier Integrity: Keeping the Check Unfakeable

A verifier only protects the loop if the agent cannot quietly defeat it. Five
patterns, converging across independent Claude-Code loop harnesses (Jun 2026), keep
the check honest:

**1. The external verifier — the loop runs the check, not the agent.** In the
`loop-kernel` design the control loop itself executes the real check command every
iteration and reads the exit code; the worker never reports its own success.
The repo puts it plainly: "The **kernel** runs it, not the worker. Editing or skipping
your tests changes nothing — the kernel re-runs the real command every iteration." The principle: **the control system is fixed and deterministic; the worker
is stochastic and swappable.** This is the architectural cure for [Verifier Theater](17-failure-patterns.md)
— the agent cannot approve itself because approval lives outside the agent.
([uppifyagency/loop-kernel](https://github.com/uppifyagency/loop-kernel), Jun 2026.)

**2. Mechanical gates vs. adjudicators — two kinds of check, kept separate.**

| Check type | Observes | Example |
|---|---|---|
| **Mechanical gate** | Runtime properties only the environment can see | `gate.sh` exit code, build, test suite, CI |
| **Adjudicator** | Whether a diff satisfies discrete acceptance criteria | read-only judge agent emitting structured JSON |

Keeping them separate is what prevents infinite loops: adjudicators cannot mistake weakened
tests for correctness, and gates catch what agents cannot verify structurally. The repo's own
framing is "两道闸:机械门(退出码)+ 跨模型对抗裁判" — two gates: a mechanical exit-code gate
plus a cross-model adversarial judge. Correctness rests on "git + exit codes + a structured JSON
contract, decoupled from agent output format." ([firegnu/herdr-loop-lab](https://github.com/firegnu/herdr-loop-lab), Jun 2026.)

**3. Frozen tests — pin the contract before the implementer can touch it.** A separate
role authors the test, it is pinned by **content-hash** and made read-only, and only
then does the implementing agent write code against it. The implementer "writes against
a read-only test it cannot touch," so it cannot pass by weakening the assertion.
Completion is reconstructed independently (`git diff` from the freeze commit + a real
test re-run), "not reported by the model." A later hardening of the same harness anchors this
completion capture to a **real run-record**: the capture-verified gate re-checks the recorded
run rather than trusting a stored capture, so a stale or faked capture can no longer satisfy the
stop — closing the gap where the *evidence of a passing run* was itself forgeable.

This is complementary to [Simplification Before Testing](#simplification-before-testing),
not in conflict with it: simplification decides *what shape* the code and test should
take (and may run first); freezing decides *who may change the test afterwards* (the
implementer may not). ([orobsonn/claude-harness](https://github.com/orobsonn/claude-harness) — repo no longer publicly reachable; 404 as of 2026-09-05, Jun 2026.)

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
findings — mateaix/loope's reviewers emit `VERDICT: PASS` / `VERDICT: BLOCK` plus advisory
`SUGGEST:` lines, while the other harnesses use their own verdict vocabularies (herdr-loop-lab's
judge emits `met`/`unmet` per acceptance criterion in JSON; forja's emits `VEREDICTO: PASS |
REJECT | BLOCKER`) —
and gate completion on a **dual stop condition**: the loop terminates only when the mechanical
test command exits 0 **and** the reviewer raises no `BLOCK`. Multiple reviewers on the same
workspace aggregate by "any blocker ⇒ blocked." ([Happenmass/omux](https://github.com/Happenmass/omux),
[mateaix/loope](https://github.com/mateaix/loope), [firegnu/herdr-loop-lab](https://github.com/firegnu/herdr-loop-lab),
[Llicklair/forja](https://github.com/Llicklair/forja), Jun 2026.)

**Information asymmetry — the checker sees the output, never the maker's reasoning.** A design
principle that sharpens patterns 2–5: deliberately withhold the implementer's reasoning trace
from the validator, so the validator judges only the *artifact*. A checker that never sees *why*
the maker did something cannot inherit the maker's buried assumptions, cannot collude with its
rationalisations, and — in the source's framing — "can't lie about code it didn't write." The
loop rejects-and-retries until every independent validator approves or the gates pass. This is
the anti-collusion rationale behind the fresh-context critics of the
[8-phase DAG](24-harness-patterns.md#8-phase-dag-execution-model-tenet) and the majority-vote
council above, stated as a first-class rule rather than a side effect of fresh context.
([the-open-engine/zeroshot](https://github.com/the-open-engine/zeroshot), Jul 2026.)

These five together — external verifier, mechanical-gate/adjudicator split, frozen tests,
provenance-bound claims (with isomorphic-perturbation checks), and cross-model independence —
are the converging community answer to [Verifier Theater](17-failure-patterns.md): the
verifier, the contract, and the evidence all live outside the agent's reach, no single judge
can wave work through, and the judge that does check does not share the maker's blind spots.

**Arbitrating disagreement between cross-model reviewers.** Once you pair multiple
independent models as reviewers (pattern 5), a new question follows: what do you do when
they disagree? A multi-model (Claude + Codex + Gemini) reconciliation harness found that
**~85–90% of findings are caught by exactly one reviewer** — not by consensus — which
argues for *model-family diversity* over adding more reviewers of the same family for
consensus voting: the marginal reviewer that catches something new is more valuable than
a second vote on something already caught. To reconcile severity across reviewers it uses
**verdict-driven severity**: a verifier's confirmed/refuted judgment overrides the raw
severity a reviewer assigned, with a "promote-on-confirm" rule that floors any
independently-*confirmed* bug at high severity regardless of how mild the original
reviewer rated it. Cross-reviewer overlap is tracked mechanically (a findings database
with an `agreement_n` count per finding) rather than argued about at review time, and the
whole reconciliation is bounded to 3 rounds, gating only on blocker/high severity so minor
disagreements don't stall the loop. ([houshuang/compound-review](https://github.com/houshuang/compound-review), Jun 2026.)

**The same non-overlap holds outside LLM-judge harnesses, in shipped code-review
products.** Four commercial AI code reviewers (CodeRabbit, Sentry Seer, Greptile,
Cursor BugBot) run in parallel across 146 real PRs over three weeks produced 679
findings, and **93.4% were caught by exactly one tool**, and no line was ever flagged by all four tools at
once (37 lines drew exactly two, 4 drew exactly three). This corroborates the ~85–90% figure above with an
independent, non-LLM-judge data source: the non-overlap is not an artifact of how
LLM-as-judge harnesses are built, it recurs in production tools built by different
vendors on different review philosophies. ([dev.to, "Best AI Code Reviewer in 2026?"](https://dev.to/_vjk/best-ai-code-reviewer-in-2026-we-ran-4-in-parallel-for-3-weeks-146-prs-679-findings-1c0f), May 2026.)

**Per-criterion independent verification as the stopping condition.** A distinct
refinement of pattern 1 above: instead of one verifier judging the whole diff, define
"done" as a **manifest of acceptance criteria**, and spawn one independent verifier
*per criterion* rather than one verifier for the whole task — no single verifier
holds (and can rationalize around) the full picture, and completion requires every
criterion plus a global invariant check to pass, not an aggregate judgment call. This
is preceded by an adversarial understanding gate that challenges assumptions and reads
the codebase *before* any manifest is written, on the premise that most agent failures
are actually upstream — confidently solving the wrong problem — not downstream
verification gaps. The manifest is a more granular version of
[GOAL.md's done-conditions checklist](30-goal-engineering.md): where GOAL.md tracks
one checklist for the whole goal, a manifest gives each criterion its own
independent verifier. ([doodledood/manifest-dev](https://github.com/doodledood/manifest-dev), Jul 2026.)

**Adversarial gate quantified in production: 43% fabrication rate caught.** A
zero-polling fleet orchestrator (one orchestrator dispatching to Claude Code workers,
[Fan-Out](10-fan-out.md)) ran a separate, cheaper reviewer model against every
worker's output before integration. Across 28 dispatch cycles and roughly 100
reviewed changes in one overnight run, the adversarial gate caught a **43%
fabrication rate in generated summaries** — plus fabricated benchmark numbers,
wrong pricing, and broken UI links that the implementer's own report had missed
entirely. A concrete number for what "the checker catches what the maker cannot
self-see" is worth in practice, not just an argument for why cross-checking matters.
([walidboulanouar/loop-engineering](https://github.com/walidboulanouar/loop-engineering), Jul 2026.)

**Language-independent test suite as verifier for a full rewrite.** A distinct technique
for keeping the verifier honest during a *cross-language* rewrite: write the test suite in
a **third language**, independent of both the old and new implementation. Bun's Zig→Rust
port (535,496 lines, 11 days) verified every change against an existing TypeScript test
suite with roughly a million assertions — a verifier that cannot be gamed by matching
implementation-specific quirks in either Zig or Rust, because it was never coupled to
either. This generalises pattern 1 above (external verifier) one step further: not just
"the loop runs the check, not the agent," but "the check is written in a language the
rewrite cannot influence." ([Bun, "Bun, in Rust"](https://bun.com/blog/bun-in-rust), Jul 2026.)

**Blind adversarial review, quantified on a full production rewrite.** A concrete
large-scale instance of the information-asymmetry pattern above: on the same Bun rewrite,
one Claude Code instance implemented while a separate instance — with no visibility into
the implementer's reasoning — was charged with a single mandate: "find bugs & reasons why
the code does not work." Run at fleet scale (peak 64 parallel instances across 4
worktrees, see [Fleet Engineering's case
study](23-fleet-engineering.md#case-study-bun-64-parallel-instances-rewriting-535k-lines-in-11-days)),
this produced 128 bug fixes in the v1.4.0 release with only 19 regressions introduced
across the full 535,496-line rewrite — a real-world data point for what blind adversarial
review buys at scale, not just at single-diff granularity. ([Bun, "Bun, in Rust"](https://bun.com/blog/bun-in-rust), Jul 2026.)

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
- `Hallucination` — detects factual claims not grounded in the context
- `AnswerRelevance` — scores whether the agent's output addresses the actual task
- `ContextPrecision` — measures how precisely the context supports the answer
- `Moderation` — flags unsafe or policy-violating output

(Instantiate the class, then call `.score(...)` on it — e.g. `Hallucination().score(...)`.)

**Online Evaluation Rules** — configure continuous scoring against a running production loop:
a judge model monitors every run and alerts when metric scores fall below a threshold.
This is the fleet-level equivalent of a test suite: instead of checking one run, it
watches the whole fleet continuously.

**PyTest CI/CD integration** — evaluations run in CI pipelines as part of the test suite.
A harness that passes code tests but fails answer-relevance scores is not production-ready.

The distinction from the A/A Baseline (which establishes noise floor on a verifier's
*consistency*): Opik's metrics measure the *quality* of agent output directly.

repo: [github.com/comet-ml/opik](https://github.com/comet-ml/opik)

(Comet ML, ["Evaluation Metrics Overview"](https://www.comet.com/docs/opik/evaluation/metrics/overview), Jun 2026.)

## Real-world case study: Mozilla Firefox security harness

Brian Grinstead, Christian Holler, and Frederik Braun (Mozilla, May 2026) built a security
bug-finding harness for
Mozilla Firefox with explicit verification at every stage:

1. **LLM file prioritization** — a scoring model ranked files by bug likelihood before
   allocating agents; agents spent time on high-signal targets, not a full codebase scan
2. **score → verify → fix pipeline** — a bug candidate is confirmed real (a proof-of-concept
   testcase that trips the sanitizer) before any fix is attempted, not after
3. **Dedicated verifier subagent** — a fresh agent, not the bug-finder, confirmed each
   fix and eliminated false positives; tuned explicitly to avoid accepting fixes with
   unresolved edge cases

**Result:** 423 security bug fixes in one month.

Brian Grinstead has put the credit close to 50/50 between harness and model — the harness did
about as much of the work as the model itself. (Paraphrased: the interview is a podcast and the
exact wording could not be verified against a transcript, so it is not quoted here.)

(Mozilla Hacks — Brian Grinstead, Christian Holler & Frederik Braun, ["Behind the Scenes Hardening Firefox with Claude Mythos Preview"](https://hacks.mozilla.org/2026/05/behind-the-scenes-hardening-firefox/), May 2026; credit-split framing from Brian Grinstead interviewed by Claire Vo, ["How Claude Mythos found a 15-year-old bug in Mozilla Firefox"](https://www.lennysnewsletter.com/p/how-claude-mythos-found-a-15-year), Jun 2026.)

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
| **Visual / manual QA** | UI behaviour, rendering, layout | Invariants must be explicitly named — e.g. "no crash, no overflow, layout holds" — rather than left implicit; input variation must be recorded or seeded reproducibly. |

**Level-of-abstraction rule:** verification level must match the behavior boundary being tested.
UI behaviors need tests that simulate the user's gesture and assert on rendered/visible state —
not unit tests on the controller. "Mode-mismatched verification produces tests that pass for
the wrong reason."

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Jun 2026.)

## Self-Coverage Gate

A design-decision-disposition discipline for a loop's convergence gate: every open design or
scope item must be marked either **resolved-with-referent** (cite what settled it) or
**surfaced-with-reason** (value origination, irreversible risk, or value conflict) before the
loop can declare its gate reached ([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), RFC-0051, Jun 2026).

**The gate asks:** for every scope item, does a corresponding artifact exist (test, goal-check, visual proof)? If not, the loop is incomplete — it has missing coverage, not just failing tests.

The self-coverage check differs from test pass/fail:
- Test failure → implementation is wrong; retry
- Coverage failure → the verification layer itself is incomplete; the loop must write the missing check before it can exit

**Implementation:** the gate is enforced as a done-checklist refusal inside the loop controller's
own context — the loop may not declare itself done until the disposition record exists and every
fresh-context finding is resolved. RFC-0051 is explicit that this is doctrine, not a runtime lock:
"Make it non-skippable by a controller-gate + checklist-refusal mechanism — doctrine + a mechanical
coverage record, not a runtime lock."

**Traceability-lint** — a related gate checking that every output artifact carries a traceable chain from scope item → task → implementation → verification → done evidence. A traceability-lint failure means the evidence chain is broken: the artifact exists, but its link to the original scope requirement is missing. Invoked in one of two sanctioned ways — as an agent-run finish-time checklist step, or as an
explicit CI gate. It walks the nine-node chain (outcome → opportunity → capability → screen →
action → service → contract → spec → component) and flags structural orphans: nodes with no
producer above them or no consumer below them.

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), RFC-0048/RFC-0051, Jun 2026.)

## Oracle Problem in AI-Generated Tests

When the same agent writes both code and tests in the same session, tests exhibit very low
precision — they verify what the implementation *does* rather than what it *should* do.

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

All six categories are retryable in some form in tenet; there is no non-retriable `handoff`
verdict. `harness_bug` is retried or remediated with scope limited to build/CI/scripts, and
`contention` is retried from report scope with a context steer — either one escalates to a human
only when the source job is report-only, or when contention recurs after a readiness re-check.

([JeiKeiLim/tenet](https://github.com/JeiKeiLim/tenet), Jun 2026.)

This confirms the compound probability argument in [The Paradigm Shift](01-paradigm-shift.md):
the verification chain converts per-step model accuracy into end-to-end reliable output.

## The Non-Probabilistic Node Rule

A concrete design rule falls out of the [loops-vs-graphs cost debate](21-context-vs-loop-engineering.md#the-debate-continues-sep-2026-cost-control-theory-and-a-maturity-ladder):
put at least **one non-probabilistic node** (a compiler, type-checker, linter, or test run —
something that returns the same verdict on the same input every time) on every critical
verification path, not just LLM judges. The reasoning is the same one behind
[Verifier Integrity](#verifier-integrity-keeping-the-check-unfakeable)'s cross-model
independence pattern, sharpened with a cost argument: **parallel same-model reviewers are
correlated, not independent — the article's own framing is that a fan-out of identical reviewers
"is not an ensemble. It is a chorus" by default. Three instances of the same
model reviewing the same output in parallel can share the same blind spot the way three
microphones on one melody add volume, not information, and that redundant spend often costs
*more* than a single well-verified sequential pass. A deterministic node breaks the
correlation entirely, because it has no model-specific blind spot to share.
([LinkedIn — Rubén Domínguez Ibar](https://www.linkedin.com/pulse/forget-loop-engineering-its-all-graph-now-rub%C3%A9n-dom%C3%ADnguez-ibar-2cyzf/), Sep 2026.)

## Benchmark and Eval Integrity (Sept 2026 corpus)

Several independent findings converge on the same warning: a claimed result is only as
trustworthy as the eval that produced it, and evals themselves fail silently far more often
than practitioners assume.

- **~30% of a widely-used benchmark was broken.** OpenAI audited SWE-Bench Pro and found
  roughly 30% of its 731 tasks were unsound, withdrawing its recommendation of the benchmark
  entirely — the [oracle problem](#oracle-problem-in-ai-generated-tests) above, at the scale
  of an industry-standard eval rather than one AI-generated test file.
  ([OpenAI, "Separating signal from noise in coding evaluations"](https://openai.com/index/separating-signal-from-noise-coding-evaluations), Jul 2026.)
- **A headline benchmark score depended on an undisclosed harness, not the model.** OpenAI's
  98.6% ARC-AGI-3 score for GPT-6 Astra came from an undisclosed evaluation harness/system
  wrapped around the model — a harness OpenAI does not sell to developers — not from the raw
  model under the settings a developer could reproduce. This is the eval-integrity mirror of
  [Harness Patterns' quantified harness>model corpus](24-harness-patterns.md#the-harness-as-an-org-level-artifact):
  the same fact that makes harness investment worthwhile (the harness dominates the score) is
  exactly what makes an undisclosed harness a misleading benchmark claim.
  ([The New Stack, "OpenAI will sell you Astra, but not the system that scored 98.6%"](https://thenewstack.io/openai-astra-harness-arc-agi-3/); [The New Stack, "GPT-6 Astra's score of 98.6% looked like AGI. Then researchers read the fine print."](https://thenewstack.io/astra-arc-agi-benchmark/), Sep 2026.) The
  benchmark itself is explicitly designed around this gap: ARC-AGI-3 scores **action
  efficiency** on novel, turn-based environments with no explicit instructions or win
  conditions given, specifically to penalize brute-forcing — as of March 2026, humans solve
  100% of its environments while frontier AI systems solve under 1%, a far starker gap than
  the model-generation benchmarks this KB usually cites.
  ([ARC Prize Foundation, arXiv 2603.24621](https://arxiv.org/pdf/2603.24621), Apr 2026.)
- **A rubric induced before execution, not graded after it.** AutoSciRub builds a
  task-specific, *executable* rubric before a research agent runs — decomposing a vague
  instruction into atomic, literature-grounded goals — then uses that rubric both to guide
  execution and to grade the result, rather than writing the grading criteria after seeing
  what the agent produced. Reported gains: **+2.08 points** across three backbone models
  under a fixed harness, **+2.95 points** across three different harnesses under a fixed
  backbone, and **+16.8 points** on a research-discovery benchmark subset — three separate
  comparisons, not one continuous range. The design principle generalizes past research
  agents: writing the verifier before the run, from the spec rather than from the output,
  is the same discipline [Goal Engineering](30-goal-engineering.md)'s GOAL.md schema applies
  to coding tasks. ([arXiv 2608.31076, "Learning to Evaluate Before Improving"](https://arxiv.org/abs/2608.31076), Aug 2026.)
- **Early-trajectory confidence does not predict failure — only late-trajectory confidence
  does.** On long-horizon research tasks, verbal self-reported confidence reliably
  distinguishes a failing run from a succeeding one only at the very end of the trajectory
  (mean AUROC 0.85 at completion); every uncertainty signal tested stays below AUROC 0.60 at
  the halfway point. The proposed cause is "path switching" — agents frequently abandon
  their current approach mid-run, which decouples an early confidence reading from the
  eventual outcome. Practical implication for a loop's own stopping condition: a
  low-confidence *mid-run* signal is not yet reliable evidence to abort early — save an
  uncertainty-based abort decision for the run's final step, or rely on an external
  verifier instead of the agent's self-reported confidence for early intervention.
  ([arXiv 2608.29685, "Last Step Matters"](https://arxiv.org/abs/2608.29685), Aug 2026.)
- **Eval gates belong in the product, not just the test suite.** Repeatable evaluation gates,
  fixed test scenarios, and execution-path tracing need to be built into the product itself so
  agent reliability holds *across releases* — treating eval as a one-time pre-ship check
  rather than a standing gate is how regressions ship silently.
  ([The New Stack, "AI agent evaluations are part of the product"](https://thenewstack.io/ai-agent-evaluation-gates/), Sep 2026.)
- **DISH — making safety audits harder to detect.** DISH (Deployment-Imitating SWE-Agent
  Harness) wraps a target model in an agent harness such as Claude Code so its system prompt,
  tool definitions and system reminders match deployment. Paired with "critique refinement", it
  addresses *evaluation awareness*: a capable model that can tell it is inside a safety audit
  behaves differently, which weakens what the audit can conclude. This is a different class of
  problem from the Astra story above — that one is a benchmark score depending on an undisclosed
  harness; this one is about making a safety test indistinguishable from deployment.
  ([arXiv 2609.02302, "Improving Evaluation Realism with Inference-Time Compute and Deployment Scaffolds"](https://arxiv.org/abs/2609.02302), Sep 2026.)
- **A consumer-facing instance of the same discipline.** A "Loop Method" guide for improving
  ChatGPT workflows runs three improvement loops with a **panel of sub-agents adversarially
  reviewing each cycle**, identifying the biggest weakness and validating against success
  criteria before proceeding — the same maker/checker discipline this doc documents for
  coding agents, appearing independently in a non-engineering product context.
  ([therundown.ai, "Use the loop method to get better results from ChatGPT"](https://app.therundown.ai/guides/use-the-loop-method-to-get-better-results-from-chatgpt), Aug 2026.)
