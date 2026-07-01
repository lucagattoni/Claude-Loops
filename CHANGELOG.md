# Changelog — Loop Engineering

All notable changes to `LOOP_ENGINEERING.md` and the `docs/` knowledge base are recorded here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/):
- **MAJOR** — existing doc removed/renamed, or `LOOP_ENGINEERING.md` index restructured
- **MINOR** — ≥1 new `docs/*.md` file created (new concept documented)
- **PATCH** — existing docs updated or new findings added to digest with no new doc files
- **None** — zero findings and zero doc changes (no commit made)

---

## [Unreleased]

### Added
### Changed

---

## [2.5.0] — 2026-07-01

### Added

- **Published documentation site** (MkDocs Material, 3-column layout — left nav / content / right on-this-page TOC) mirroring the Claude-Warp setup, deployed to GitHub Pages via `.github/workflows/docs.yml` (uv → `mkdocs build --strict` → Pages).
  - `mkdocs.yml` — Material theme, deep-purple/deep-orange palette with light/dark toggle, search, full nav grouped as in `LOOP_ENGINEERING.md` (Foundations → … → Reference).
  - `docs/index.md` — site home (intro, design spine, grouped topic links, links to the live news digest/sources/changelog).
  - `requirements-docs.txt` — pins `mkdocs-material`.
  - **External links open in a new tab with an external-link icon** — `docs/javascripts/external-links.js` (Material `document$` hook, survives instant navigation; adds `target=_blank` + `rel=noopener noreferrer`) and `docs/stylesheets/external-links.css` (currentColor-masked icon; internal links untouched).
  - `site/` added to `.gitignore` (build output is generated in CI, not committed).

Verified locally: `mkdocs build --strict` passes with zero warnings (all 120 intra-doc links/anchors resolve); 3-column layout and external-link new-tab+icon confirmed in-browser (23/23 external links marked, 0 internal false-positives).

Loop news run 2026-07-01 12:35 UTC — 9 findings. A gap-driven run: filled three documented KB gaps and added the first quantified harness>model evidence.

### Added

- `docs/33-agent-security-hardening.md` — **Credential Rotation Mid-Session** (Credential-Sentinel: verify-before-revoke cutover — promote→repoint→verify, revoke old only after verify passes, rollback on fail; 4-state classify with default-deny on unknowns; two human gates) [fills gap] + **Runtime Policy Gating** (omnigent: blast_radius, intent_gate default-deny, phase-scoped tool access) [partial SECURITY_MATRIX fill].
- `docs/30-goal-engineering.md` — **A-Priori Goal-Cost Estimation** (cobusgreyling `goal-cost`: pattern-keyed pre-run token/budget forecast) [fills gap].
- `docs/14-human-in-the-loop.md` — **Where to Place a Checkpoint** (4 tests, ~80/20 split, override-rate calibration; MindStudio).
- `docs/24-harness-patterns.md` — quantified harness>model (LangChain: Terminal-Bench Top30→Top5, harness-only) + **harness conformance testing** (omnigent harness-bench).
- `docs/04-verification.md` — 70/30 human-LLM **blended grading** (Claire Vo) + **proof-of-work demo artifacts** (Simon Willison video-as-verification).
- `docs/06-skills.md` — **agent-legible tools** (`--help` as embedded SKILL.md; Simon Willison).

### Changed

- `docs/17-failure-patterns.md` — enriched Context-drift with `detect_task_switch` (mechanical mid-run goal-change detection).
- `LOOP_ENGINEERING.md` — updated summaries for docs 04, 06, 14, 24, 30, 33.
- `KB_GAPS.md` — closed credential-rotation and goal-cost gaps; re-scoped SECURITY_MATRIX to the loading mechanism.
- `SOURCES.md` — (ecc added earlier in 2.4.6).

Selective integration from [affaan-m/ecc](https://github.com/affaan-m/ecc) (224k★ multi-harness agent operator system), evaluated at 14/20 — verified against the actual skill files, not the marketing README.

### Added

- `docs/04-verification.md` — **Eval Metrics: pass@k vs. pass^k**: pass@k (≥1 success in k tries — capability; target pass@3 > 90%) vs. pass^k (all k succeed — unattended-safety; pass^3 = 100% for critical paths), and the three grader types (code-based / model-based / human, risk-tiered). Cross-referenced to the A/A baseline (code-based graders only for gates) and Loop Readiness Levels.
- `SOURCES.md` — added affaan-m/ecc as a github source to track.

### Changed

- `LOOP_ENGINEERING.md` — updated the docs/04 summary.

Not integrated (already covered / marginal): ecc's `verification-loop` (redundant with the self-verifying loop; lacks maker/checker) and `/loop-start` loop-type taxonomy (overlaps existing trigger + readiness taxonomies).

Loop news run 2026-06-29 04:02 UTC — 18 findings (a second GitHub-dominated wave of fresh Claude-Code loop harnesses converging again on verifier integrity + anti-self-grading).

### Added

- `SOURCES.md` — added krishddd/Strive_Engineering as a github source (provenance-bound SHA-citation verifier pattern).
- `docs/32-reading-list.md` — added Strive_Engineering to Reference Implementations (provenance-bound verification; group now at the 5-entry cap).

### Changed

- `docs/04-verification.md` — added a 4th **Verifier Integrity** pattern: **provenance-bound claims** — every assertion must cite a git SHA re-checked via `git cat-file`, plus a majority-vote monitor council to block self-grading (krishddd/Strive_Engineering, kok1eee/flywheel, grapheneaffiliate/Harness); added a closing synthesis tying all four patterns to the Verifier-Theater cure.
- `LOOP_ENGINEERING.md` — updated the docs/04 index summary to list provenance-bound claims + majority-vote council.

---

## [2.4.4] — 2026-06-28

### Changed

- `scripts/run-loop-news.sh` — Hardened the retry logic so it can't make things worse: (1) added `--max-budget-usd 8` so retries can't become an unbounded bill; (2) **safe-to-retry guard** — only retry when the failed attempt left no durable trace (tracked tree clean **and** `HEAD` unchanged); if it already committed or made partial edits, stop and notify rather than re-running (avoids duplicate commits / tag-release collisions); (3) **desktop notification** (`osascript`) on final give-up and on every no-retry abort, so a failed daily run is never silent. Verified against clean-retry, HEAD-moved-abort, dirty-tree-abort, and all-fail paths.
- `docs/09-headless-mode.md` — Documented "only retry when a retry is safe" (cost cap, traceless-failure check, notify-on-give-up) and noted that true safe-to-retry requires idempotency inside the loop itself.

### Changed

- `scripts/run-loop-news.sh` — Added retry-with-backoff (3 attempts, 30s→90s) so a transient API drop (`ECONNRESET`/`overloaded`) no longer loses the whole scheduled run. An attempt counts as failed if the exit code is non-zero **or** a connection-level error marker appears in its output — covering the macOS `script(1)` quirk where the child exit code is masked to 0. Each attempt is captured to its own typescript for error-scanning, then folded into the day log (live PTY tail preserved).
- `docs/09-headless-mode.md` — Documented the "exit code alone is not enough — scan the output too" hardening lesson (PTY masks exit code; transient drops print to output) with a retry snippet.

Loop news run 2026-06-28 16:25 UTC — 14 findings (GitHub-dominated: a wave of new Claude-Code loop harnesses converging on stop-condition rigor + verifier integrity).

### Added

- `docs/04-verification.md` — **Verifier Integrity: Keeping the Check Unfakeable**: external verifier (loop-kernel — the loop runs the real check, worker can't fake), mechanical gates vs. adjudicators (herdr-loop-lab), frozen content-hashed tests before implementation (claude-harness).
- `docs/07-subagents.md` — **"Strong Eyes, Cheap Hands"**: cost-asymmetric DOER/CHECKER model allocation (cheap models write, top model judges at gates; the cheaper the orchestrator, the more the deterministic rails must carry the judgment).
- `docs/17-failure-patterns.md` — **Verdict oscillation** failure pattern (checker flip-flops / contradictory jurors) + oscillation-guard mitigation (jje).
- `SOURCES.md` — added uppifyagency/loop-kernel and orobsonn/claude-harness as github sources.

### Changed

- `docs/27-loop-contract.md` — extended the canonical Stop Condition Taxonomy with the three-exit-code reference implementation (loop-kernel: 0=pass / 3=score-flat / 2=cap) and the "score the goal, not the activity" refinement to the no-progress stop.
- `docs/32-reading-list.md` — added loop-kernel to Reference Implementations.
- `LOOP_ENGINEERING.md` — updated summaries for docs 04, 07, 17, 27.
- `KB_GAPS.md` — annotated the SECURITY_MATRIX and goal-cost gaps with this run's partial advances and refreshed search keywords.

---

## [2.4.1] — 2026-06-26

Manual addition from Andrew Ng's "Loop Engineering for 0-to-1 Product Development" (The Batch).

### Added

- `docs/14-human-in-the-loop.md` — **The Three Feedback Loops** (Andrew Ng): agentic coding (minutes) / developer review (tens of min–hours) / user feedback (days), and the human "context advantage" that keeps the human loop necessary; cross-linked to the Inner/Outer Dual Loop.
- `SOURCES.md` — added The Batch (DeepLearning.AI) as an rss source.

### Changed

- `docs/17-failure-patterns.md` — enriched the Reward hacking row with the concrete GLM-5.2 case (agents fetched reference solutions from GitHub) and the rule-based-filter mitigation.
- `docs/25-long-running-agents.md` — reciprocal cross-ref distinguishing the Dual Loop axis (execution/strategy) from the three feedback loops (agent/developer/user).
- `docs/32-reading-list.md` — added Andrew Ng's article to the Getting Started group.
- `LOOP_ENGINEERING.md` — updated the docs/14 summary.

---

## [2.4.0] — 2026-06-26

Findings-driven structural review of the KB after the 2026-06-26 news run (38 findings),
plus codification of that review as a standing norm.

### Added

- `.claude/skills/fetch-loop-news/SKILL.md` — **Phase 4c — Findings-Driven Structural Review**: a mandatory post-run pass that reads the run's findings as a set and rethinks/restructures the KB (canonical-home designation, missing thesis, unrepresented primitive, centrality drift, merge/reorder). Establishes the loop-design spine (What / How / When / How much / How do you know it's done?) as the KB's central organizing principle, and instructs critically pressure-testing user direction rather than implementing it verbatim.
- `docs/27-loop-contract.md` — **Stop Condition Taxonomy** (canonical home): four categories — completion-check (only success stop) / budget / max-iterations / no-progress; rice-cooker problem; "verification is the completion check"; runtime-vs-design-time mapping. Reframed the contract intro around the five loop-design questions.
- `docs/02-agent-loop-cycle.md` — **Two Lenses on Loop Primitives**: functional (execution/verification/orchestration/observability) vs. mechanical (six building blocks); observability named as the prerequisite fourth primitive; runtime termination signals mapped to the stop-condition taxonomy.
- `docs/24-harness-patterns.md` — **The Harness as an Org-Level Artifact** (Karpathy): harness design decisions propagate to every loop the org runs.

### Changed

- `LOOP_ENGINEERING.md` — Intro reframed to make loop design the central act (five design questions); updated summaries for docs 02, 04, 24, 27.
- `docs/04-verification.md` — Framed verification as the completion-check stop; cross-ref to the canonical taxonomy.
- `docs/30-goal-engineering.md` — Goal stopping condition mapped to the completion-check category; cross-ref to the canonical taxonomy.

---

## [2.3.14] — 2026-06-26

### Changed

- `docs/24-harness-patterns.md` — Added: Harness vs. Environment Engineering section (in-process vs. out-of-process controls; Approval-First / Curated Allow-list / Sandboxed Full-Auto patterns); extended Harness-Agnostic Projection with .apm/ primitive manifest (6 subdirectory types); extended omnigent section with compaction persistence, --resume, and spec reconstruction on resolve-miss
- `docs/04-verification.md` — Added: Self-Coverage Gate (RFC-0051, every scope item must have a verification artifact) and Traceability-Lint (scope→task→artifact evidence chain gate)
- `docs/34-loop-patterns.md` — Added: concrete STATE.md multi-loop example (PR Babysitter + CI Sweeper coexisting with acting_on fields); Per-Agent Heartbeat Coordination pattern (harnery .harnery/active/ with claim/commit/TTL guards)
- `docs/01-paradigm-shift.md` — Added: >80% Anthropic engineers on self-improving loops; five canonical agent workflow patterns (prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer)
- `docs/32-reading-list.md` — Added "Building Effective Agents" (Anthropic, Dec 2024) to Harness Design group
- `SOURCES.md` — Added MindStudio Blog as html source
- `KB_GAPS.md` — Marked .apm/ spec format and multi-loop STATE.md coordination as filled; updated SECURITY_MATRIX search keywords
- `LOOP_ENGINEERING_NEWS.md` — 38 new findings (run 2026-06-26 09:04 UTC)

---

## [2.3.13] — 2026-06-26

### Changed

- `scripts/run-loop-news.sh` — Use `script -q -a` to allocate a PTY, forcing `claude -p` to flush output line-by-line; enables `tail -f logs/loop-news-YYYYMMDD.log` to show live progress

---

## [2.3.12] — 2026-06-26

### Changed

- `docs/09-headless-mode.md` — Added: macOS LaunchAgent scheduling pattern (plist template, `launchctl` commands, when to prefer over Routines)
- `docs/28-routines.md` — Updated comparison table: added LaunchAgent as a third column alongside headless and Routines; added rule-of-thumb for choosing between them

---

## [2.3.11] — 2026-06-26

### Added

- `scripts/com.luca.loop-news.plist` — macOS LaunchAgent that runs `run-loop-news.sh` daily at 05:00 local (= 04:00 UTC); registered via `launchctl load ~/Library/LaunchAgents/com.luca.loop-news.plist`

---

## [2.3.10] — 2026-06-25

### Changed

- `docs/04-verification.md` — Added: "Surface" as canonical stopping verb; verification mode discipline (TDD/goal-based/visual-manual); Oracle Problem (~6% test precision / oracle leakage); Structured Critic Finding Taxonomy (6 categories: product_bug, test_bug, harness_bug, evidence_mismatch, contention, scope_conflict)
- `docs/07-subagents.md` — Added: Adversarial Reviewer Checklists (spec-stage 9 checks + implementation-stage 9 checks); Rationalizations Reviewers Must Refuse table
- `docs/08-permissions.md` — Added: ASK verdict and soft warning thresholds (`ask_thresholds_usd`); session-fires-first evaluation order
- `docs/11-cost-control.md` — Added: Operational Kill/Pause/Slow-Down Thresholds with concrete numeric criteria
- `docs/16-memory-patterns.md` — Added: Three-Tier Document Lifecycle (.tenet/runs/ + .tenet/project/ + .tenet/knowledge/)
- `docs/17-failure-patterns.md` — Added: Fixing flakes with code; Over-Reach; Parallel Collision failure patterns
- `docs/24-harness-patterns.md` — Added: Agent YAML Definition Schema (Omnigent-style, 15+ harnesses); Organizational Learning Stage (4th loop stage); Harness Update File Safety Contract (.upstream companion files)
- `docs/27-loop-contract.md` — Added: Cross-Run Memory Persistence (.loopflow/memory/); Gate Feedback Injection (failure reason to all agent prompts)
- `docs/33-agent-security-hardening.md` — Added: credbroker credential resolution pattern (no model exposure)
- `docs/34-loop-patterns.md` — Added: Three-Loop Onboarding Sequence (Daily Triage → PR Babysitter → Post-Merge Cleanup → CI Sweeper); Debt Audit Loop pattern; Docs Sync Loop pattern
- `SOURCES.md` — Added: eugenelim/agent-ready-repo, JeiKeiLim/tenet, faisalishfaq2005/loopflow
- `LOOP_ENGINEERING.md` — Updated summaries for docs 4, 7, 8, 11, 16, 17, 24, 27, 33, 34

---

## [2.3.9] — 2026-06-25

### Changed

- All `docs/*.md` — Added markdown hyperlinks to every external citation; all `owner/repo` attribution footers, `repo:` lines, `@handles`, and inline tool names (LangSmith Fleet, Opik, Sakana Fugu, Graphiti) now link to their official pages
- `docs/16-memory-patterns.md` — Pattern F expanded with full Graphiti architecture (27.9k★, arXiv:2501.13956): Episodes/Entities/Facts/Custom Types model, temporal invalidation mechanism, hybrid retrieval (semantic + BM25 + graph), installation, loop integration pattern
- `docs/32-reading-list.md` — Fixed structure: single "Loops in Production" section (Claude Tag + New Stack verification article); "Reference Implementations" at the end

---

## [2.3.8] — 2026-06-25

### Changed

- `docs/16-memory-patterns.md` — Added Pattern F: Temporal Knowledge Graph (Graphiti/Zep — temporal entity state as complement to flat STATE.md)
- `docs/23-fleet-engineering.md` — Added Opik to Observability section (trace→regression test for fleet agents)
- `docs/08-permissions.md` — Added Reject+Replan Pattern (when a safety gate fires, agent replans rather than aborting)
- `docs/04-verification.md` — Added Production Trace to Regression Test section (Opik)
- `SOURCES.md` — Added @akshay_pachaar (x) and getzep/graphiti (github)
- `LOOP_ENGINEERING.md` — Updated summaries for rows 4, 8, 16
- `KB_GAPS.md` — Updated multi-loop STATE.md gap to note Graphiti as partial coverage; flat-file example still missing

---

## [2.3.7] — 2026-06-25

### Changed
- `docs/23-fleet-engineering.md` — Added: Fleet Four Pillars (Delegate/Improve/Approve/Connect), F0-F3 fleet maturity levels, Fleet Economics cost attribution, Claw vs. Assistant identity choice (Cobus Greyling, Jun 2026)
- `docs/30-goal-engineering.md` — Added: GOAL.md schema, six canonical goal patterns (Tests Green, Migrate Module, Fix Bug, Refactor, Docs Update, Security Scan), G0-G3 readiness scoring (cobusgreyling/goal-engineering, Jun 2026)
- `docs/04-verification.md` — Added: Type A vs. Type B work classification, loop verdict taxonomy (6 verdicts), cross-run patterns (clean-room review, held-out test layer, cross-task defect ledger), belief state machine + R0-R5 risk levels, A/A baseline for verifier calibration (Jun 2026)
- `docs/24-harness-patterns.md` — Added: harness-agnostic projection + security-at-specification-stage, 8-phase DAG execution model + steer message taxonomy, meta-harness 3-tier policy hierarchy + harness-swap (Jun 2026)
- `docs/27-loop-contract.md` — Added: YAML-declarative loop definition, VERDICT: PASS gate, 2-layer budget ceiling, self-discovery loop pattern (Schedule→Discover→Build→Verify→Repeat) (Jun 2026)
- `docs/08-permissions.md` — Added: agent trust ramp (4-stage: read-only → summarise → hard limits → loop cap)
- `docs/32-reading-list.md` — Added cobusgreyling/goal-engineering and cobusgreyling/fleet-engineering to Reference Implementations; removed duplicate "Loops in Production" section
- `KB_GAPS.md` — Marked filled: verifier calibration (thalys/agent-ab), loop correctness testing (void2610, JeremyW1990); added new gaps: agentskills.io format, F0-F3 indicators, goal-cost estimation
- `SOURCES.md` — Added: cobusgreyling/goal-engineering, cobusgreyling/fleet-engineering, omnigent-ai/omnigent (github type); added acting_on claude loop github-search for multi-loop STATE.md coordination gap
- `LOOP_ENGINEERING_NEWS.md` — 2026-06-25 run: 20 new findings across 6 sources

---

## [2.3.6] — 2026-06-24

### Changed
- `.claude/skills/fetch-loop-news/SKILL.md` — Reading list step 5b: explicitly cover GitHub repos with substantial documentation as eligible for the Reference Implementations group (was silently excluded by "full article" language)
- `KB_GAPS.md` — Added: SECURITY_MATRIX.md implementation mechanism gap (how does the agent load it at startup?)

---

## [2.3.5] — 2026-06-24

### Changed
- `.claude/skills/fetch-loop-news/SKILL.md` — Reading list curation: updated group list to include "Reference Implementations" (prevents duplicate group creation on next run); note that repos belong there, not in article groups
- `docs/24-harness-patterns.md` — Ledger Closure: added applicability note (relevant for custom API orchestrators that manage the message array directly; not applicable to Claude Code CLI)
- `KB_GAPS.md` — Clarified "Recently Filled" archive label

---

## [2.3.4] — 2026-06-24

### Changed
- `docs/07-subagents.md` — Confidence gate threshold (≥80%) reframed as a calibratable parameter, not a universal rule; note that 80% is the session-orchestrator reference implementation value

---

## [2.3.3] — 2026-06-24

### Changed
- `.claude/skills/fetch-loop-news/SKILL.md` — Renamed Phase 4b from "Doc coherence review" to "Devil's Advocate KB Review"; expanded from 5 structural questions to 9 questions across two categories: (1) adversarial content review (internal contradictions, missing cross-refs, unverifiable claims, better placement, redundancy) and (2) structural coherence (grouping, staleness, progression, fragmentation)

---

## [2.3.2] — 2026-06-24

### Changed
- `.claude/skills/fetch-loop-news/SKILL.md` — Phase 5c: add KB_GAPS.md to git add command (was being omitted from daily commits)
- `docs/08-permissions.md` — Added: cross-reference to docs/33 (Agent Security Hardening) as the OS-layer companion
- `docs/27-loop-contract.md` — Clarified: /evolve and /reconcile are Skills to implement (not built-in Claude Code commands); link to docs/06
- `docs/32-reading-list.md` — Updated intro: "articles" → "articles, essays, and reference implementations" (covers GitHub repos now in the list)

---

## [2.3.1] — 2026-06-24

### Added
- `KB_GAPS.md` — new file: iterative gap tracker; each daily run reads and updates this file to record thin KB areas and their targeted search keywords; drives convergent deepening across runs

### Changed
- `docs/17-failure-patterns.md` — Added: Infinite Fix Loop pattern (loop retries indefinitely without attempt cap; fix: hard cap of N attempts + escalation to human inbox)
- `docs/33-agent-security-hardening.md` — Added cross-reference to docs/08 (permissions/allowlists) as the software-layer companion to OS-level security
- `docs/34-loop-patterns.md` — Added note distinguishing loop readiness levels (per-loop operational trust) from developer maturity model (docs/20)
- `SOURCES.md` — Changed github-search URLs from HTML scrape to GitHub API JSON endpoints; updated type-reference description for github-search
- `.claude/skills/fetch-loop-news/SKILL.md` — Updated github-search handler to use JSON API; added step 6 KB gap tracking (create/update KB_GAPS.md each run; use gap keywords to drive targeted searches)

---

## [2.3.0] — 2026-06-24

### Added
- `docs/33-agent-security-hardening.md` — OS-user-per-agent kernel isolation, four credential disposition types (Broker/Sidecar/Remove/Egress Firewall), SECURITY_MATRIX.md design, fail-safe secret gate (clem — jahwag/clem, Jun 2026)
- `docs/34-loop-patterns.md` — Seven named loop patterns (Daily Triage, PR Babysitter, CI Sweeper, Dependency Sweeper, Post-Merge Cleanup, Changelog Drafter, Issue Triage); L1/L2/L3 operational readiness levels; token cost benchmarks; multi-loop coordination rules with priority ordering and collision detection; auto-merge allowlist and path denylist (cobusgreyling/loop-engineering, Jun 2026)

### Changed
- `docs/04-verification.md` — Added: simplification-before-testing (Wave 4 inversion — simplify AI code before writing tests); verification of memory (revalidate stale GOAL.md/STATE.md entries before acting)
- `docs/07-subagents.md` — Added: synthesis as the non-delegable bottleneck (task forwarding anti-pattern); confidence-scored quality gates (≥80% threshold, suppress low-confidence findings)
- `docs/08-permissions.md` — Added: risk-tiered authorization by consequence (read/write/irreversible tiers); safety path denylist globs for sensitive files
- `docs/10-fan-out.md` — Added: scope-verified parallelism via Pre-Edit hooks; multi-loop coordination with STATE.md acting_on claiming
- `docs/11-cost-control.md` — Added: token cost by loop pattern (noop 3-5K → action run 200-250K → CI Sweeper without early exit 5M/day); early exit rule as correctness requirement
- `docs/12-hooks.md` — Added: exit code safety contract — exit 1 is treated as non-blocking warning (continues); always use exit 2 for denial; safe bash pattern with ERR trap
- `docs/13-context-management.md` — Added: input governance pipeline (prefetch/snip/microcompact/collapse/autocompact); reactive compact with circuit breaker (20K reserved tokens, 13K early-warning, halt after 3 failures)
- `docs/16-memory-patterns.md` — Added: multi-backend task queue (Slack/Discord thread claiming, GitHub Issue label workflow); STATE.md wave recovery (resume from last completed wave on crash)
- `docs/17-failure-patterns.md` — Added: State Rot (acting on ghost state references), Verifier Theater (approval without evidence), Notification Fatigue (notifying on every run regardless of delta)
- `docs/20-loop-maturity-model.md` — Added: per-loop L1/L2/L3 operational readiness levels (distinct from developer maturity); default rule: all new loops start at L1
- `docs/24-harness-patterns.md` — Added: Unstable Components design axiom; Ledger Closure for interrupted tool calls; Five-Wave Execution Model with Wave 4 simplification pass; Runtime Republic vs. Constitutional Control Plane framing
- `docs/25-long-running-agents.md` — Added: session watchdog and 2-hour hard session limit implemented at OS level (systemd); distinct from turn caps and budget caps
- `docs/27-loop-contract.md` — Added: governed cross-session learning — /evolve (extract patterns after 5+ sessions) + /reconcile (convert to reviewable .claude/rules/ proposals); nothing auto-applies
- `docs/32-reading-list.md` — Added: harness-books.agentway.dev ("Harness Books") to Harness Design group; session-orchestrator (Kanevry) to new "Reference Implementations" group
- `SOURCES.md` — Added: harness-books.agentway.dev (html), GitHub search for "loop engineering claude" (github-search), GitHub search for "claude code harness" (github-search)
- `LOOP_ENGINEERING.md` — Updated summaries for rows 4, 7, 8, 10, 11, 12, 13, 16, 17, 20, 24, 25, 27, 32; added rows 33, 34

Sources: jahwag/clem (Jun 2026), cobusgreyling/loop-engineering (Jun 2026), wquguru/harness-books / AgentWay (Jun 2026), Kanevry/session-orchestrator (Jun 2026).

---

## [2.2.0] — 2026-06-24

### Added
- `docs/32-reading-list.md` — Curated best-articles collection; 14 articles across 5 groups (Why Loops / Getting Started / Harness Design / Goal Engineering / Production); dynamic — articles can be added/removed by future runs
- `docs/30-goal-engineering.md` — Goals vs. Loops decision framework; four Goal Primitives (Objective, Verifier, GOAL.md State, Budget); GOAL.md pattern for persistent goal state (Cobus Greyling, Jun 2026)
- `docs/31-claude-tag.md` — Claude Tag: ambient loops in Slack; channel-scoped identity; self-scheduling; org-wide context; third LLM paradigm framing (Anthropic + Karpathy, Jun 2026)

### Changed
- `docs/01-paradigm-shift.md` — Added: compound probability argument (0.9^10 = 35%); era framing 2022→2023→2024–2026; "performance ceiling set by loop, not model"
- `docs/04-verification.md` — Added: Firefox harness case study (LLM file prioritization, score→fix→verify, 423 fixes in one month, 50% harness attribution)
- `docs/17-failure-patterns.md` — Added: amplification effect (defensive complexity accumulation); cognitive dependency (AI-only-legible codebases) — both Armin Ronacher, Jun 2026
- `docs/27-loop-contract.md` — Added: job-description framing (Claire Vo); Event Modeling for task decomposition with Never Argue rule (Martin Dilger, Jun 2026)

Sources: Cobus Greyling (Substack), Anthropic / Boris Cherny, Andrej Karpathy, Armin Ronacher (lucumr.pocoo.org), @roanbrasil (Medium), Martin Dilger (LinkedIn), Claire Vo / Lenny's Newsletter, Brian Grinstead — all Jun 2026.

---

## [2.1.2] — 2026-06-23

### Changed
- `docs/13-context-management.md` — Added: Context resets vs. compaction comparison; context anxiety finding (Sonnet 4.5 vs. Opus 4.6)
- `docs/07-subagents.md` — Added: GAN framing for why external evaluation enables improvement; evaluator tuning anti-patterns
- `docs/04-verification.md` — Added: Making subjective goals gradable (4-dimension framework)
- `docs/11-cost-control.md` — Added: Real project cost benchmarks ($9 broken / $200 working; DAW $124.70)
- `docs/24-harness-patterns.md` — Added: Three-agent full-stack harness; sprint contract system; load-bearing vs. optional components / re-baseline per model release

Source: Prithvi Rajasekaran, Anthropic Engineering, "Harness Design for Long-Running Application Development", Mar 2026.

---

## [2.1.1] — 2026-06-23

### Changed
- `docs/17-failure-patterns.md` — Added: Reward hacking, Context pollution + Context reset pattern, Context drift
- `docs/24-harness-patterns.md` — Added: Harness vs. Loop two-layer distinction, "Verification closure → reliability → scalability", Event-Driven Architecture (EDA) loops, Serverless loops
- `docs/27-loop-contract.md` — Added: Two Quality Gates (evidence completeness, stopping condition clarity), Experience Encoding as post-iteration learning step

---

## [2.1.0] — 2026-06-23

### Added
- `docs/28-routines.md` — Routines: cloud-hosted loop execution with Schedule/API/GitHub triggers
- `docs/29-background-agents.md` — Background agents: `--bg`, agent view, fan-out, worktree isolation

### Changed
- `docs/12-hooks.md` — Full rewrite: 5 hook types, complete lifecycle events, JSON output API, asyncRewake circuit breaker, conditional `if` field, env vars, scope hierarchy
- `docs/09-headless-mode.md` — Full rewrite: session continuation, background sessions, prompt overrides, CI flags, prompt cache optimisation
- `docs/07-subagents.md` — Added built-in types table (fork/Explore/Plan), custom agent frontmatter, nesting depth, permission control
- `docs/08-permissions.md` — Added deny/ask lists, Tool(param:value) pattern syntax, PermissionRequest hook, settings precedence
- `docs/05-claude-md.md` — Added load hierarchy, path-scoped rules (`.claude/rules/`), HTML comment stripping, import syntax, `claudeMdExcludes`
- `docs/03-building-blocks.md` — Added Routines as cloud automation layer alongside local Automations
- `docs/25-long-running-agents.md` — Added "Detaching from the terminal" section with `--bg` and Routines pointers
- `LOOP_ENGINEERING.md` — Added rows 28 and 29; updated summaries for rows 3, 5, 7, 8, 9, 12

---

## [2.0.2] — 2026-06-23

### Changed
- `docs/07-subagents.md` — added DOER/CHECKER pattern: never let the AI grade its own output
- `docs/01-paradigm-shift.md` — added AI Leverage Formula: AI Leverage = Clarity × Skill (Sabrina Ramonov, Jun 2026)
- `docs/25-long-running-agents.md` — added Inner/Outer Dual Loop pattern; @samwillis real-world /goal example (1k commits, 10 days)
- `docs/27-loop-contract.md` — added stopping condition aphorism: "if you can't say what done looks like, you don't have a loop"
- `docs/11-cost-control.md` — added token consumption benchmarks (~4× single agent, ~15× multi-agent vs standard chat)
- `LOOP_ENGINEERING.md` — updated index summaries for rows 7, 11, 25

---

## [2.0.1] — 2026-06-22

### Changed
- `docs/17-failure-patterns.md` — updated cognitive surrender with empirical data (<40% vs 65%+ comprehension, Osmani May 2026); added "Dark factory" and "Missing circuit breaker" failure patterns
- `docs/21-context-vs-loop-engineering.md` — added "The four disciplines" section: Loop/Context/Harness/Fleet Engineering as four named disciplines (Cobus Greyling, Jun 2026)
- `LOOP_ENGINEERING.md` — updated index summaries for rows 17 and 21 to reflect new content

---

## [2.0.0] — 2026-06-22

### Changed
- `LOOP_ENGINEERING.md` — restructured flat 27-row table into 7 logical sections (Foundations, Designing a Loop, Components, State & Long-Running Loops, Quality & Safety, Scaling, Reference); rows reordered within sections but numbers preserved
- `docs/16-memory-patterns.md` — added cross-reference to `25-long-running-agents.md`
- `docs/01-paradigm-shift.md` — added cross-reference to `26-factory-model.md`
- `.claude/skills/fetch-loop-news/SKILL.md` — added Phase 4b doc coherence review; release criteria MAJOR condition now explicitly covers index restructuring

---

## [1.2.0] — 2026-06-22

### Added
- `docs/20-loop-maturity-model.md` — 14-step progression from manual prompter to loop engineer (Boris Cherny's 3-stage model + community roadmap, Jun 21 2026)
- `docs/21-context-vs-loop-engineering.md` — emerging community debate on whether context engineering supersedes loop engineering (@techtasium, Jun 21 2026)
- `docs/22-learned-orchestration.md` — new concept: training the orchestrator (Sakana Fugu, TRINITY/Conductor, Thinker/Worker/Verifier roles) vs. coding it by hand (Jun 22 2026)
- `docs/23-fleet-engineering.md` — new concept: managing fleets of AI agents at enterprise scale (Cobus Greyling, LangSmith Fleet, Jun 22 2026)
- `docs/24-harness-patterns.md` — new doc: two-part Anthropic harness (initializer + coding agent); four-type loop taxonomy (heartbeat/cron/hook/goal) (Jun 22 2026)
- `docs/25-long-running-agents.md` — new doc: Ralph loop, planner-worker-judge, cross-context-window state management and git-based recovery (Jun 22 2026)
- `docs/26-factory-model.md` — new doc: AI software factory framing — spec quality and verification replace coding speed as the bottleneck (Jun 22 2026)
- `docs/27-loop-contract.md` — new doc: TRIGGER/SCOPE/ACTION/BUDGET/STOP/REPORT; Anchor File Pattern; Uber annual-budget-in-4-months data (Jun 22 2026)
- `SOURCES.md` — added @Sabrina_Ramonov X handle (active loop engineering presence confirmed Jun 22 2026)
- `SOURCES.md` — added Lenny's Newsletter (Claire Vo) html source (Jun 22 2026)

### Changed
- `docs/17-failure-patterns.md` — added "Loop as wrong unit" anti-pattern (@batjko_labs, Jun 21 2026)
- `docs/17-failure-patterns.md` — added "Cost runaway", "Provider lock-in", "Cognitive surrender", "Orchestration tax", and "Intent debt" failure patterns (Jun 22 2026)
- `docs/02-agent-loop-cycle.md` — added Universal Agent Thesis ("Perceive, reason, act, learn") framing with "Learn" step explained (Jun 22 2026)
- `docs/06-skills.md` — added "Skills as SDLC Scaffolding" section: non-skippable engineering phase enforcement (Jun 22 2026)
- `docs/01-paradigm-shift.md` — added "New Software Lifecycle" table: implementation speed no longer the bottleneck (Jun 22 2026)
- `LOOP_ENGINEERING.md` — added rows 22–27 (learned-orchestration, fleet-engineering, harness-patterns, long-running-agents, factory-model, loop-contract)

---

## [1.1.0] — 2026-06-21

### Added
- `docs/19-mcp-security.md` — AgentJacking attack pattern, indirect prompt injection via MCP tool results, mitigations (sourced from The New Stack, Jun 21 2026)
- Four-tier keyword taxonomy in `SOURCES.md` — Tier 1 (Boris Cherny's exact language), Tier 2 (named discipline), Tier 3 (named concepts/failure modes), Tier 4 (tool/feature names)
- New sources: Sabrina Ramonov (`sabrina.dev`), Cobus Greyling (Substack), Peter Steinberger (`@steipete`)

### Changed
- `docs/17-failure-patterns.md` — added "Polling loop" anti-pattern: using cron when an event-driven trigger would be more token-efficient (sourced from @CKGrafico, X.com, Jun 21 2026)
- `SOURCES.md` — corrected Anthropic RSS to `/rss.xml`, OpenAI changed to `html` type (RSS 403), swyx.io path corrected to `/writing`, Addy Osmani RSS corrected to `/rss.xml`
- `.claude/skills/fetch-loop-news/SKILL.md` — strategy corrected: per-source phase searches within source for keywords; general search added as bonus pass (Phase 3); tiered scoring in result JSON and digest

---

## [1.0.0] — 2026-06-21

### Added
- `LOOP_ENGINEERING.md` as a slim index table — one row per topic with summary and link
- `docs/01-paradigm-shift.md`
- `docs/02-agent-loop-cycle.md`
- `docs/03-building-blocks.md` — covers Automations, Worktrees, Skills, Chrome connector, Sub-agents, Memory
- `docs/04-verification.md`
- `docs/05-claude-md.md`
- `docs/06-skills.md`
- `docs/07-subagents.md`
- `docs/08-permissions.md`
- `docs/09-headless-mode.md`
- `docs/10-fan-out.md`
- `docs/11-cost-control.md`
- `docs/12-hooks.md`
- `docs/13-context-management.md`
- `docs/14-human-in-the-loop.md`
- `docs/15-explore-plan-implement.md`
- `docs/16-memory-patterns.md`
- `docs/17-failure-patterns.md`
- `docs/18-quick-reference.md`
- `SOURCES.md` — dynamic source list for the daily news tracker
- `LOOP_ENGINEERING_NEWS.md` — append-only daily digest log
- `.claude/skills/fetch-loop-news/SKILL.md` — 3-phase daily news skill
- `scripts/run-loop-news.sh` — headless runner script
