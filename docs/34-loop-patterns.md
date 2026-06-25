# Loop Patterns Catalog

Named, composable production loop patterns with defined cadence, risk level, and
operational requirements. Each is a reusable blueprint that can be instantiated into
any repo using the standard six primitives.

(Cobus Greyling, [cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering), Jun 2026.)

**Note on readiness vs. developer maturity:** Loop readiness levels (L1/L2/L3) classify
each individual loop's operational trust. They are distinct from the 14-step developer
maturity progression in [Loop Maturity Model](20-loop-maturity-model.md), which
classifies the *engineer's* capability. A step-14 loop engineer still starts every new
loop at L1.

## Loop Readiness Levels

Before deploying any pattern, assign it a readiness level:

| Level | Mode | What the loop does | Gate to advance |
|---|---|---|---|
| **L1** | Report-only | Discovers work, notifies humans — no autonomous action | ≥1 week of zero false positives |
| **L2** | Assisted | Proposes fixes; human approves before merge | Full observability + loop-budget.md in place |
| **L3** | Autonomous | Auto-merges; fires without human approval | L2 gate + loop-run-log.md + LOOP.md BUDGET section |

**Default rule: start every new loop at L1.** The first week is observation-only
regardless of confidence. Advancing to L3 requires documented evidence of reliability,
not just absence of visible failures. `L3` should be explicitly gated in the loop's
own LOOP.md before any auto-merge is allowed.

## Pattern Catalog

### Daily Triage
**Cadence:** Morning once daily · **Default level:** L1

Scans open issues, failing CI, stale PRs, and dependency alerts. Outputs a structured
report to a channel or file. Never takes autonomous action — discovery and notification only.

| Property | Value |
|---|---|
| Risk | Low |
| State file | `STATE.md` (watchlist) |
| Human gate | Read report; prioritise manually |
| Token cost/run | ~50,000–80,000 |

---

### PR Babysitter
**Cadence:** Every 10–15 min · **Default level:** L2

Shepherds open PRs through CI and review. Responds to failing checks, updates
descriptions, pings reviewers on idle PRs, and merges when all conditions are met.

| Property | Value |
|---|---|
| Risk | Medium — can comment and ping team |
| State file | `STATE.md` (acting_on: pr-id — collision prevention) |
| Human gate | Merge approval at L2; explicit conditions required at L3 |
| Token cost/run | ~200,000–250,000 |

---

### CI Sweeper
**Cadence:** Every 15 min · **Default level:** L2

Reacts to failing CI. Reads the failure, determines root cause, applies a fix, pushes
to branch, monitors the next CI run. Hard limit: **3 fix attempts per failure**;
escalates to human after that.

| Property | Value |
|---|---|
| Risk | Medium-high — writes code autonomously |
| Attempt cap | 3 per failure (required — prevents infinite fix loop) |
| Early exit | If CI is green, exit immediately at <5k tokens |
| Token cost at 5 min without early exit | ~5M tokens/day |

**The early exit rule is mandatory.** Without it, a CI Sweeper running at 5-minute
cadence against a passing repo burns ~5M tokens/day on no-ops. The loop must check
for work before doing any triage; if the watchlist is empty, exit immediately.

---

### Dependency Sweeper
**Cadence:** Every 6 hours · **Default level:** L2

Patches CVEs and outdated packages. Patch-level changes only — no minor or major
bumps without explicit approval. Opens PRs, runs tests, merges if CI passes.

| Property | Value |
|---|---|
| Risk | Low-medium (patch-only) |
| Safe | Security patches, patch version bumps in test files |
| Escalate | Minor/major bumps, lockfile changes, dependency removals |

---

### Post-Merge Cleanup
**Cadence:** Off-peak (nightly) · **Default level:** L2

After each merge, scans for TODO comments, dead code, and debt markers. Files cleanup
PRs at low-traffic times. Never runs during active working hours.

| Property | Value |
|---|---|
| Risk | Low — additive cleanup |
| Constraint | Off-peak only; does not interrupt active work |
| Token cost/run | ~50,000–80,000 |

---

### Changelog Drafter
**Cadence:** Pre-release · **Default level:** L1

Reads commit history since last release and drafts a human-readable changelog. Draft
only — human reviews and approves before publish. **Never auto-publishes.**

| Property | Value |
|---|---|
| Risk | Minimal |
| Output | `CHANGELOG_DRAFT.md` (human approves before merge) |

---

### Issue Triage
**Cadence:** Companion to Daily Triage · **Default level:** L1–L2

Labels, prioritises, and categorises incoming issues. At L1: labels and comment
summaries. At L2: may close obvious duplicates or out-of-scope issues with an
explanation comment.

| Property | Value |
|---|---|
| Risk | Low (L1) · Medium (L2) |
| Human gate | Review labels before any auto-close actions |

---

## Token Cost Reference

Benchmarks from operating experience:

| Run type | Token cost |
|---|---|
| Noop pass (empty watchlist, early exit) | ~3,000–5,000 |
| Report-only triage | ~50,000–80,000 |
| Action run (implementer + verifier) | ~200,000–250,000 |
| CI Sweeper at 5 min cadence, no early exit | ~5M/day |

See [Cost & Turn Control](11-cost-control.md) for budget caps and `--max-budget-usd` usage.

## Multi-Loop Coordination

When multiple loops coexist in the same repo, uncoordinated writes cause conflicts.

### Priority ordering
When two loops both find work, higher-priority loops act first:
1. CI Sweeper (live failures — highest urgency)
2. PR Babysitter (in-progress reviews)
3. Dependency Sweeper (proactive patches)
4. Post-Merge Cleanup (low urgency)
5. Daily Triage (report-only — always last)

### Collision detection
Each action loop writes `acting_on: <branch-or-pr-id>` to its STATE.md before spawning
a fix. All other loops read all STATE.md files before starting work and **skip any
item that is already claimed**. Rule: one owner per branch per hour.

When a conflict cannot be resolved automatically, the loop writes to a human inbox
section in STATE.md and notifies rather than acting.

See [Fan-Out](10-fan-out.md) for scope-verified parallelism at the hook layer.

## Safety Defaults

**Auto-merge allowlist** (L3 only — nothing else auto-merges):
- Typo fixes in documentation
- Lint auto-fixes in test files
- Import ordering changes

**Never auto-merge at any level:**
- Dependency bumps or lockfile changes
- Behaviour-affecting code changes
- Database migrations
- Infrastructure configuration

**Path denylist** — never touch these files autonomously:
```
.env, **/secrets/**, auth/**, payments/**, **/migrations/**,
k8s/production/**, **/credentials/**
```

Add project-specific sensitive paths to this list in CLAUDE.md before deploying any L2+ loop.

## Three-Loop Onboarding Sequence

When introducing loops to a new codebase or team, start with exactly three patterns and
do not add a fourth until the first three are stable:

1. **Daily Triage** — read-only morning scan; zero risk; establishes observability habits
2. **PR Babysitter** — monitors existing PRs; limited write scope (labels, comments only at L1)
3. **Post-Merge Cleanup** — runs after merge; bounded scope (a closed PR cannot regress)

**Add CI Sweeper only after two weeks of zero collisions** in the first three loops. CI
Sweeper is more aggressive (writes code, opens PRs) and requires the collision-detection
infrastructure (STATE.md `acting_on` field) to already be working and trusted.

Starting with CI Sweeper before the triage + babysitter + cleanup loops are stable is a
common failure mode: the team gains no observability before the first high-risk loop runs.

([cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering), Jun 2026.)

## Debt Audit Loop

| Property | Value |
|---|---|
| **Trigger** | Weekly cron (Monday 08:00) |
| **Scope** | Entire codebase — read-only discovery pass |
| **Action** | Identify tech debt items (dead code, deprecated deps, TODO comments, coverage gaps); append to `.loopflow/reports/debt-audit.md` — never modifies code |
| **Cadence** | Weekly discovery; human reviews report and creates tickets manually |
| **Token cost** | ~80,000–120,000 (report-only run across large codebase) |
| **Readiness** | L1 only — report mode; never auto-creates issues or PRs |
| **Stop condition** | Report written; no open PRs to check |

The report file persists across runs. The loop appends new findings and marks
previously-reported items as "still open" or "resolved", giving the team a living
tech-debt register rather than a static weekly snapshot.

([faisalishfaq2005/loopflow](https://github.com/faisalishfaq2005/loopflow), Jun 2026.)

## Docs Sync Loop

| Property | Value |
|---|---|
| **Trigger** | Post-merge webhook (any commit to `src/`) |
| **Scope** | `docs/` only; runs in isolated git worktree |
| **Action** | Detects drift between code and documentation (API signatures, config fields, deprecated flags); proposes doc edits as a PR |
| **Token cost** | ~50,000–100,000 depending on diff size |
| **Readiness** | L2 — proposes PRs but does not auto-merge; human reviews before merge |
| **Stop condition** | `VERDICT: PASS` — all doc references match current code, or PR opened for any that don't |

([faisalishfaq2005/loopflow](https://github.com/faisalishfaq2005/loopflow), Jun 2026.)
