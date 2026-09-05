# Claude-Loops — Agent Instructions

Claude-Loops is a living knowledge base and automated daily tracker for **loop engineering** — designing systems that prompt Claude for you. Read `LOOP_ENGINEERING.md` (the index) and `README.md` before working. The KB grows automatically via a two-skill pipeline: `fetch-loop-news` (search) hands off to `integrate-loop-news` (integrate + restructure + publish).

> **Open work — read this first.** Read `plans/20260904_2053-open-work-backlog.md` — the full
> verified backlog after `v3.0.0`, ranked, with three decisions still open. The highest-priority
> items are **automation, not content**: the daily tracker has not fired since 8 July. The
> fact-check method lives in `plans/20260904_2002-v3-fact-check-gaps.md` (14 of 39 docs untouched,
> ~20 more only partially verified). Do not re-derive either from scratch. **Delete this note once
> the backlog's §3 and §4 are empty.**

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
| `docs/index.md` | The published site's home page — a **second** index, separate from `LOOP_ENGINEERING.md`; update both when adding a doc |

## Git workflow

- **Always work in a git worktree — never in the primary checkout.** Keep the primary checkout on a clean `main`; do feature/plan work in a separate worktree on its branch (`git worktree add <path> <branch>`), and commit/push from there. This keeps the primary clean and isolated, matching the daily loop's own worktree isolation.
- **Remove every worktree once its work is finished** — as soon as its branch is merged (or the work is abandoned), `git worktree remove <path>` and delete the branch (local + `git push origin --delete <branch>`). Don't leave finished worktrees lying around "just in case."
- **Plans and features → own branch + PR.** Never commit feature work directly to `main`. Name branches meaningfully (`feature/...`, `plan/...`).
- **Exception — automated content goes direct to `main`.** The daily pipeline commits its own output (`LOOP_ENGINEERING_NEWS.md`, `docs/`, `LOOP_ENGINEERING.md`, `SOURCES.md`, `mkdocs.yml`, `CHANGELOG.md`, `KB_GAPS.md`) directly to `main` — `integrate-loop-news`'s Phase 5 commits and `push origin HEAD:main`. This is generated content, not a code feature.
- When iterating/refining (devil's-advocate or review rounds), **commit AND push at each iteration** — treat each round as a shippable increment; never batch rounds into one commit.

## Releases

**Hand-authored versions:** create an annotated git tag (`git tag vX.Y.Z -m "..."`), push it (`git push origin --tags`), and create a GitHub release (`gh release create`) in the same turn as the commit — never defer. Mark the newest stable release `--latest`. See the global SemVer rule for bump levels.

**Pipeline-cut versions are released by a human follow-up, not by the pipeline.** `integrate-loop-news` bumps `CHANGELOG.md` and pushes, but deliberately does not tag or release: `gh` is not in its allowlist, and granting an unattended agent `gh release` rights on a public repo is a wider permission than the convenience is worth. Decided 20260905. The cost is visible and accepted — 53 tags against 38 releases today. When you next touch this repo by hand, backfill any tagged version that has no release.

## Plans

- **Retire a plan in place, never by moving it.** Once every step is verified shipped, add a
  `**Shipped as vX.Y.Z** — <date UTC>` line under the title and leave the file where it is.
  Moving it to an archive directory breaks inbound links (`CLAUDE.md` and other plans reference
  plans by path) and costs more than it saves — `ls plans/` already reads chronologically from the
  timestamp prefix, and git history already records what changed. Decided 20260905.
- **Verify before stamping.** "Looks merged" is not shipped: confirm each step's artifact exists in
  the tree, not just that a PR closed.

## Knowledge-base rules

- **Citations must link.** Every external reference in `docs/*.md` (repo, tool, product, @handle) must be a markdown hyperlink to the official page — never a bare name. Post-edit check: `grep -rn 'repo: github\.com' docs/ | grep -v '\[github'`.
- **Review new resources before moving on.** When a new repo/article/tool is discovered, fetch it (README + any `docs/`) and score it on unique contribution / precision / durability (0–5). Avg ≥ 3.0 → deep-read and extract; otherwise note in `KB_GAPS.md` or skip. Never add to the KB from a README skim alone.
- **Keep docs current in the same session.** Any infra/process/pattern change updates the relevant `docs/*.md` (e.g. headless → `docs/09`, routines → `docs/28`, loop patterns → `docs/34`) and `SOURCES.md` before committing — don't wait to be asked.
- **Every timestamp is UTC, `YYYYMMDD HH:MM`.** Skills and humans alike: read the clock with `date -u '+%Y%m%d %H:%M'`, never compose or convert one. Applies to digest headers, changelog and release entries, plan filenames and branch names. **Never rewrite an existing timestamp** — entries recorded in local time (everything before `[3.0.0]`) stay exactly as written, because restamping them invents precision nobody measured. Decided 20260905; supersedes the previous skills-UTC/humans-local split, which had produced three formats inside one `CHANGELOG.md`.

## Structural review (norm after every news run)

After every tracker run, do a critical, findings-driven structural review of the whole KB (codified as Phase 4c in `integrate-loop-news`) — read the findings as a *set* and ask whether the KB should be restructured (missing canonical home, missing thesis, centrality drift, docs to merge/reorder). The organizing spine is the five loop-design questions: **What / How / When / How much / How do you know it's done?** (Loop Contract: SCOPE / ACTION / TRIGGER / BUDGET / STOP + verifier). Prefer consolidation over new docs. Index restructures = MAJOR; new canonical sections + cross-refs = MINOR/PATCH.
