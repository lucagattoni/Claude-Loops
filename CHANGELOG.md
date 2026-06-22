# Changelog — Loop Engineering

All notable changes to `LOOP_ENGINEERING.md` and the `docs/` knowledge base are recorded here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/):
- **MAJOR** — significant restructure or removal of existing content
- **MINOR** — new topic added (new `docs/<topic>.md` + row in index)
- **PATCH** — update or correction to an existing topic doc

---

## [Unreleased]

### Added
- `docs/loop-maturity-model.md` — 14-step progression from manual prompter to loop engineer (Boris Cherny's 3-stage model + community roadmap, Jun 21 2026)
- `docs/context-vs-loop-engineering.md` — emerging community debate on whether context engineering supersedes loop engineering (@techtasium, Jun 21 2026)
- `docs/learned-orchestration.md` — new concept: training the orchestrator (Sakana Fugu, TRINITY/Conductor, Thinker/Worker/Verifier roles) vs. coding it by hand (Jun 22 2026)
- `docs/fleet-engineering.md` — new concept: managing fleets of AI agents at enterprise scale (Cobus Greyling, LangSmith Fleet, Jun 22 2026)
- `docs/harness-patterns.md` — new doc: two-part Anthropic harness (initializer + coding agent); four-type loop taxonomy (heartbeat/cron/hook/goal) (Jun 22 2026)
- `docs/long-running-agents.md` — new doc: Ralph loop, planner-worker-judge, cross-context-window state management and git-based recovery (Jun 22 2026)
- `docs/factory-model.md` — new doc: AI software factory framing — spec quality and verification replace coding speed as the bottleneck (Jun 22 2026)
- `docs/loop-contract.md` — new doc: TRIGGER/SCOPE/ACTION/BUDGET/STOP/REPORT; Anchor File Pattern; Uber annual-budget-in-4-months data (Jun 22 2026)
- `SOURCES.md` — added @Sabrina_Ramonov X handle (active loop engineering presence confirmed Jun 22 2026)
- `SOURCES.md` — added Lenny's Newsletter (Claire Vo) html source (Jun 22 2026)

### Changed
- `docs/failure-patterns.md` — added "Loop as wrong unit" anti-pattern (@batjko_labs, Jun 21 2026)
- `docs/failure-patterns.md` — added "Cost runaway", "Provider lock-in", "Cognitive surrender", "Orchestration tax", and "Intent debt" failure patterns (Jun 22 2026)
- `docs/agent-loop-cycle.md` — added Universal Agent Thesis ("Perceive, reason, act, learn") framing with "Learn" step explained (Jun 22 2026)
- `docs/skills.md` — added "Skills as SDLC Scaffolding" section: non-skippable engineering phase enforcement (Jun 22 2026)
- `docs/paradigm-shift.md` — added "New Software Lifecycle" table: implementation speed no longer the bottleneck (Jun 22 2026)
- `LOOP_ENGINEERING.md` — added rows 22–27 (learned-orchestration, fleet-engineering, harness-patterns, long-running-agents, factory-model, loop-contract)

---

## [1.1.0] — 2026-06-21 IST

### Added
- `docs/mcp-security.md` — AgentJacking attack pattern, indirect prompt injection via MCP tool results, mitigations (sourced from The New Stack, Jun 21 2026)
- Four-tier keyword taxonomy in `SOURCES.md` — Tier 1 (Boris Cherny's exact language), Tier 2 (named discipline), Tier 3 (named concepts/failure modes), Tier 4 (tool/feature names)
- New sources: Sabrina Ramonov (`sabrina.dev`), Cobus Greyling (Substack), Peter Steinberger (`@steipete`)

### Changed
- `docs/failure-patterns.md` — added "Polling loop" anti-pattern: using cron when an event-driven trigger would be more token-efficient (sourced from @CKGrafico, X.com, Jun 21 2026)
- `SOURCES.md` — corrected Anthropic RSS to `/rss.xml`, OpenAI changed to `html` type (RSS 403), swyx.io path corrected to `/writing`, Addy Osmani RSS corrected to `/rss.xml`
- `.claude/skills/fetch-loop-news/SKILL.md` — strategy corrected: per-source phase searches within source for keywords; general search added as bonus pass (Phase 3); tiered scoring in result JSON and digest

---

## [1.0.0] — 2026-06-21 09:07 IST

### Added
- `LOOP_ENGINEERING.md` as a slim index table — one row per topic with summary and link
- `docs/paradigm-shift.md`
- `docs/agent-loop-cycle.md`
- `docs/building-blocks.md` — covers Automations, Worktrees, Skills, Chrome connector, Sub-agents, Memory
- `docs/verification.md`
- `docs/claude-md.md`
- `docs/skills.md`
- `docs/subagents.md`
- `docs/permissions.md`
- `docs/headless-mode.md`
- `docs/fan-out.md`
- `docs/cost-control.md`
- `docs/hooks.md`
- `docs/context-management.md`
- `docs/human-in-the-loop.md`
- `docs/explore-plan-implement.md`
- `docs/memory-patterns.md`
- `docs/failure-patterns.md`
- `docs/quick-reference.md`
- `SOURCES.md` — dynamic source list for the daily news tracker
- `LOOP_ENGINEERING_NEWS.md` — append-only daily digest log
- `.claude/skills/fetch-loop-news/SKILL.md` — 3-phase daily news skill
- `scripts/run-loop-news.sh` — headless runner script
