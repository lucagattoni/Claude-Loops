# Claude-Loops — Agent Instructions

Claude-Loops is a living knowledge base and automated daily tracker for **loop engineering** — designing systems that prompt Claude for you. Read `LOOP_ENGINEERING.md` (the index) and `README.md` before working. The KB grows automatically via a two-skill pipeline: `fetch-loop-news` (search) hands off to `integrate-loop-news` (integrate + restructure + publish).

> **Open work — read this first.** Read `plans/20260904_2053-open-work-backlog.md` — the full ranked
> backlog. **The automation tier (§3) is closed**: the eight-week outage is fixed and the pipeline
> now gates its own pushes, watches itself from off-machine, and resumes either stage from an
> arbitrary point (`v3.1.0`, A1–A12). What remains is **content** (§4–§5).
> Start with **C6** and **C13** — their research is already done and sits in
> `plans/20260905_1349-c6-c13-evidence.md`, ready to write up. The largest remaining risk is **C1**:
> 14 of 39 docs have never been fact-checked, ~20 more only partially, method in
> `plans/20260904_2002-v3-fact-check-gaps.md`. Do not re-derive any of it from scratch.
> **Delete this note once the backlog's §4 and §5 are empty.**

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
- **Close a backlog item in the SAME PR as the work — never in a later pass.** A shipped item left
  open, or an entry point still asserting a state the work just falsified, is a defect on the same
  footing as a broken link. Observed twice on 20260905: `CLAUDE.md` still said "the tracker has not
  fired since 8 July" hours after it had fired and shipped `v3.0.1`, and six items sat listed as
  open after shipping. Deferring the close is what causes it, every time — the next agent reads the
  stale claim and re-derives work that is already done, or trusts a claim that is no longer true.
  So the PR that ships the fix also strikes the item, records what verified it, and corrects any
  pointer the change falsified. **This includes correcting the backlog when the work proves the
  backlog itself wrong** — record the correction in place rather than quietly deleting it.

## Pipeline (the unattended tracker)

- **A default that means success is a fabricated result, not a fallback.** This repo's defining
  defect class, and the reason it went eight weeks publishing nothing while every signal looked
  clean. Instances found and fixed: an unresolved slash command exits **0**, so a missing skill made
  Stage B log `Run complete` having published nothing; a `findings: []` artifact read as "search
  failed" when a quiet day is a finished run; a dead RSS feed and a clean feed both returned no
  items; `notify()` reported only to a desktop popup and a gitignored log. So: **when a check cannot
  tell, it must fail, never pass.** Never write `|| echo 0` on a count, an empty default on a work
  list, or a catch that swallows and continues. And assert on the **artifact** — a commit, a
  deployed page, a fresh digest header — never on a run's exit status; "the workflow succeeded" has
  been true here while nothing shipped.
- **Every expensive stage must be resumable from any point, because it can die at any point.**
  Standing requirement, set 20260905. A session limit, a killed process or a closed laptop can end a
  stage mid-execution, so anything costing real minutes or money checkpoints its progress somewhere
  the *wrapper* can see: Stage A per source in its artifact, Stage B as commits on a per-day branch.
  Prefer a mechanism the wrapper can verify (git) over one the agent maintains (a progress file) —
  progress inside a Claude session is invisible from outside, so an agent-kept ledger is advisory
  prose, the same weakness as a gate written as instructions in a `SKILL.md`.

## Sessions and handoff

- **Check at every natural boundary whether to clear the session** — after a release, after a plan
  lands, before starting work of a different shape. Long context degrades judgement and costs
  tokens on every turn; a fresh session on a clean entry point is usually better than continuing.
- **Never clear until the handoff is complete, and verify it rather than assuming.** Everything the
  next session needs must be **on disk and reachable from what it will actually read** —
  `CLAUDE.md` → the backlog plan → the file that plan points at. Research held only in a workflow
  transcript, a task list, or the conversation is lost. Before proposing a clear, walk that chain
  and confirm each hop resolves.
- **Expensive research goes into `plans/` as an evidence pack, not into a reply.** If re-deriving it
  would cost real minutes or money, it is an artifact: write it down, state its provenance and its
  caveats, and link it from the backlog item it serves. Say what the evidence could **not** settle —
  a pack that reads as complete when it is not is worse than no pack.
- **A session's own work is what most often falsifies the entry points.** Re-read `CLAUDE.md` and
  the backlog against reality before handing over; the claims most likely to be stale are the ones
  this session just made false.

## Knowledge-base rules

- **Citations must link.** Every external reference in `docs/*.md` (repo, tool, product, @handle) must be a markdown hyperlink to the official page — never a bare name. Post-edit check: `grep -rn 'repo: github\.com' docs/ | grep -v '\[github'`.
- **Review new resources before moving on.** When a new repo/article/tool is discovered, fetch it (README + any `docs/`) and score it on unique contribution / precision / durability (0–5). Avg ≥ 3.0 → deep-read and extract; otherwise note in `KB_GAPS.md` or skip. Never add to the KB from a README skim alone.
- **Never write a version number, flag, limit or model ID without the fetched source in front of
  you** — this KB is public and gets copied. Two failure modes, opposite directions, both shipped in
  `v3.0.0`: a **fabricated** table row for an env var that does not exist, and an **over-correction**
  that stripped a *true* claim after checking only two of the four sources that carried it. Before
  removing a claim as unsourced, check every source that could plausibly carry it — absent from one
  page is not "does not exist". Prefer `curl` + strip-tags over WebFetch for anything quoted
  verbatim; WebFetch's summariser has silently truncated quotes here. And **never edit quoted
  third-party material to make it look current** — correct the KB's own text around it instead.
- **Keep docs current in the same session.** Any infra/process/pattern change updates the relevant `docs/*.md` (e.g. headless → `docs/09`, routines → `docs/28`, loop patterns → `docs/34`) and `SOURCES.md` before committing — don't wait to be asked.
- **Every timestamp is UTC, `YYYYMMDD HH:MM`.** Skills and humans alike: read the clock with `date -u '+%Y%m%d %H:%M'`, never compose or convert one. Applies to digest headers, changelog and release entries, plan filenames and branch names. **Never rewrite an existing timestamp** — entries recorded in local time (everything before `[3.0.0]`) stay exactly as written, because restamping them invents precision nobody measured. Decided 20260905; supersedes the previous skills-UTC/humans-local split, which had produced three formats inside one `CHANGELOG.md`.

## Structural review (norm after every news run)

After every tracker run, do a critical, findings-driven structural review of the whole KB (codified as Phase 4c in `integrate-loop-news`) — read the findings as a *set* and ask whether the KB should be restructured (missing canonical home, missing thesis, centrality drift, docs to merge/reorder). The organizing spine is the five loop-design questions: **What / How / When / How much / How do you know it's done?** (Loop Contract: SCOPE / ACTION / TRIGGER / BUDGET / STOP + verifier). Prefer consolidation over new docs. Index restructures = MAJOR; new canonical sections + cross-refs = MINOR/PATCH.
