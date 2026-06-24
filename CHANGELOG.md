# Changelog — Loop Engineering

All notable changes to `LOOP_ENGINEERING.md` and the `docs/` knowledge base are recorded here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/):
- **MAJOR** — existing doc removed/renamed, or `LOOP_ENGINEERING.md` index restructured
- **MINOR** — ≥1 new `docs/*.md` file created (new concept documented)
- **PATCH** — existing docs updated or new findings added to digest with no new doc files
- **None** — zero findings and zero doc changes (no commit made)

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
