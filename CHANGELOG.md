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

### Changed
- `docs/failure-patterns.md` — added "Loop as wrong unit" anti-pattern (@batjko_labs, Jun 21 2026)

---

## [1.1.0] — 2026-06-20 IST

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
