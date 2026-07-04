# Claude-Loops — Agent Instructions

Claude-Loops is a living knowledge base and automated daily tracker for **loop engineering** — designing systems that prompt Claude for you. Read `LOOP_ENGINEERING.md` (the index) and `README.md` before working. The KB grows automatically via a two-skill pipeline: `fetch-loop-news` (search) hands off to `integrate-loop-news` (integrate + restructure + publish).

## Repository map

| Path | What it is |
|---|---|
| `LOOP_ENGINEERING.md` | Slim index of all topics (one row per `docs/<topic>.md`) |
| `docs/` | One in-depth doc per topic |
| `LOOP_ENGINEERING_NEWS.md` | Append-only daily digest of findings |
| `SOURCES.md` | Monitored news sources |
| `.claude/skills/fetch-loop-news/SKILL.md` | Search half — finds news, writes `.loop-news/findings.json` |
| `.claude/skills/integrate-loop-news/SKILL.md` | KB half — consumes the artifact, integrates + restructures + commits + pushes |
| `scripts/run-loop-news.sh` | Headless wrapper — runs both skills as two sessions in one worktree |
| `scripts/SCHEDULING.md` | Change cadence / enable-disable the launchd job — see this before editing the plist |
| `CHANGELOG.md` · `plans/` · `KB_GAPS.md` | History, plans, gap log |

## Git workflow

- **Always work in a git worktree — never in the primary checkout.** Keep the primary checkout on a clean `main`; do feature/plan work in a separate worktree on its branch (`git worktree add <path> <branch>`), and commit/push from there. This keeps the primary clean and isolated, matching the daily loop's own worktree isolation.
- **Plans and features → own branch + PR.** Never commit feature work directly to `main`. Name branches meaningfully (`feature/...`, `plan/...`).
- **Exception — automated content goes direct to `main`.** The daily pipeline commits its own output (`LOOP_ENGINEERING_NEWS.md`, `docs/`, `LOOP_ENGINEERING.md`, `SOURCES.md`, `mkdocs.yml`, `CHANGELOG.md`, `KB_GAPS.md`) directly to `main` — `integrate-loop-news`'s Phase 5 commits and `push origin HEAD:main`. This is generated content, not a code feature.
- **Always pull before changing anything.**
- When iterating/refining (devil's-advocate or review rounds), **commit AND push at each iteration** — treat each round as a shippable increment; never batch rounds into one commit.

## Releases

After every batch of commits that produces a new CHANGELOG version: create an annotated git tag (`git tag vX.Y.Z -m "..."`), push it (`git push origin --tags`), and create a GitHub release (`gh release create`). Do it in the same turn as the commit — never defer. Mark the newest stable release `--latest`. See the global SemVer rule for bump levels.

## Knowledge-base rules

- **Citations must link.** Every external reference in `docs/*.md` (repo, tool, product, @handle) must be a markdown hyperlink to the official page — never a bare name. Post-edit check: `grep -rn 'repo: github\.com' docs/ | grep -v '\[github'`.
- **Review new resources before moving on.** When a new repo/article/tool is discovered, fetch it (README + any `docs/`) and score it on unique contribution / precision / durability (0–5). Avg ≥ 3.0 → deep-read and extract; otherwise note in `KB_GAPS.md` or skip. Never add to the KB from a README skim alone.
- **Keep docs current in the same session.** Any infra/process/pattern change updates the relevant `docs/*.md` (e.g. headless → `docs/09`, routines → `docs/28`, loop patterns → `docs/34`) and `SOURCES.md` before committing — don't wait to be asked.
- **Timestamps: skills use UTC, humans use local.** The `fetch-loop-news`/`integrate-loop-news` skills stamp digest/run times in **UTC** (`TZ=UTC date`). For hand-authored changelog/release timestamps use local system time: `date '+%Y-%m-%d %H:%M %Z'` with no `TZ` override; never hardcode a timezone.

## Structural review (norm after every news run)

After every tracker run, do a critical, findings-driven structural review of the whole KB (codified as Phase 4c in `integrate-loop-news`) — read the findings as a *set* and ask whether the KB should be restructured (missing canonical home, missing thesis, centrality drift, docs to merge/reorder). The organizing spine is the five loop-design questions: **What / How / When / How much / How do you know it's done?** (Loop Contract: SCOPE / ACTION / TRIGGER / BUDGET / STOP + verifier). Prefer consolidation over new docs. Index restructures = MAJOR; new canonical sections + cross-refs = MINOR/PATCH.

## Interaction defaults

Cross-project working defaults — think critically about proposals (don't just implement), give honest pros/cons when asking the user to choose, let the user have the last word, and inspect git state (`git status` / `git reflog`) before any corrective `git reset` — live in the global `~/.claude/CLAUDE.md`.
