# Two-Pillar Restructure — Loop Engineering + Developing with Claude Code

**Written** 20260904 16:58 UTC · branch `20260904_1658-two-pillar-restructure` · base `43e86f6`
**Target release** `v3.0.0` (MAJOR — `LOOP_ENGINEERING.md` index restructured)

---

## 1. Why

Three independent sources converge on a claim the KB does not currently make:
**for software development specifically, the dominant productive mode is human-guided
iteration, not autonomous long-horizon loops.**

| Source | Tier | What it says |
|---|---|---|
| Andrew Ng, ["…Using Coding Agents"](https://www.deeplearning.ai/the-batch/the-ai-engineering-skills-map-in-detail-using-coding-agents/), 2026-09-04 | practitioner (high) | Effective coding-agent use is *"a complex, highly iterative process"*; most utility comes from human intervention with *"high-skill judgement"*, not autonomous long-horizon tasks |
| Anthropic, ["When to use multi-agent systems"](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them), 2026-01-23 | official | Role-split agents (*"planning, execution, review"*) is a named anti-pattern; *"telephone game"*; multi-agent uses *"3-10x more tokens"* |
| Anthropic, ["multi-agent research system"](https://www.anthropic.com/engineering/multi-agent-research-system) | official | *"Most coding tasks involve fewer truly parallelizable tasks than research"* |

The KB's front page currently reads *"Stop writing prompts. Start designing loops"* and
*"autonomously, while you sleep."* That is **correct for a class of work** (triage, sweeps,
digests, dependency bumps, docs sync — this repo's own tracker is a good example) and
**wrong as a universal default for building software**. The KB has 34 docs on the autonomous
mode and effectively no routing layer telling a reader which mode their task belongs to.

The fix is not to delete anything. It is to **name the second mode, give it a spine, and put a
router in front of both.**

---

## 2. What changes

### 2.1 Three new docs

| File | Title | Content |
|---|---|---|
| `docs/35-choosing-your-mode.md` | Interactive or Autonomous? Choosing Your Mode | **The router.** Decision table: task properties → mode. When a loop pays for itself vs. when it is overhead. The compound-probability argument (docs/01) re-scoped: it argues for *a correction loop*, not necessarily an *unattended* one. Cost per unit of work (Ng, tokenmaxxing). |
| `docs/36-development-workflow.md` | The Development Workflow | **Pillar I spine.** Ng's three phases (Plan → Execute → Deploy/Monitor) × five skills (directing the workflow · enabling agent autonomy · reviewing the work · customizing the agent and its environment · coding agent foundations), each mapped to the concrete Claude Code primitive that implements it, with links into the existing component docs. |
| `docs/37-session-architecture.md` | Session Architecture: One Session or Many | **The Pinakes question.** Context-centric vs role-centric decomposition. The three situations that justify multiple agents (context protection / parallelisation / specialisation) and the one that does not (a different role in the same pipeline). Substrate decision table: session · subagent · agent team · workflow · hook · skill. **Named Pinakes case study** (§ 2.3). |

### 2.2 Index and nav restructure

Row numbers stay stable (per `CLAUDE.md`) — files are re-grouped, never renumbered.

```
1. Start Here            35 (new) · 01 · 21
2. Developing with       36 (new) · 37 (new) · 15 · → 04 · → 05/06/12      ← PILLAR I
   Claude Code
3. Loop Engineering      02 · 27 · 30 · 24 · 34 · 03 · 28 · 31 · 26 · 20   ← PILLAR II
4. Components (shared)   05 · 06 · 07 · 12 · 08 · 09 · 13 · 16
5. Quality & Safety      04 · 17 · 14 · 11 · 19 · 33
6. Scaling               10 · 23 · 22 · 25 · 29
7. Reference             18 · 32
8. Project               news · sources · changelog
```

Touches: `LOOP_ENGINEERING.md` (index + thesis paragraph), `mkdocs.yml` (nav, `site_name`,
`site_description`), `README.md` (opening framing), `docs/index.md`.

**Open question for review:** `site_name` is currently `Loop Engineering`. Options —
(a) keep it, (b) `Claude Loops`, (c) `Claude Code: Loops & Development Practice`.
Repo name `Claude-Loops` and all published URLs stay unchanged either way.

### 2.3 The Pinakes case study — publication rules

Decision taken 20260904: **named case study, absolute dollar figures dropped.**

| Publish | Do not publish |
|---|---|
| Project name "Pinakes"; the architecture question and its verdict | `$3.38k` / `$699.99` / `$1.72k` absolute spend |
| Ratios and percentages (36.8% of delegated spend on review; ~95.8% file re-derivation across passes; median fragment lifetime 2.1 h) | Anything resembling PII, credentials, private endpoints |
| Named failure modes: value-biased fan-out truncation; `.filter(Boolean)` erasing dead agents; VACUOUS/PARTIAL/CLEAN coverage reporting | |
| Python file/tool names already generic (`sync.py`, `review_ledger.py`) | |
| The refuted-claims table — publishing what did **not** survive checking is the most valuable part | |

Every figure carries its population and instrument, as in the source document.
**A re-read of the drafted section against this table is a required step before commit.**

### 2.4 Docs revised, not rewritten

| Doc | Change |
|---|---|
| `01-paradigm-shift` | Scope the thesis. "Stop writing prompts, start designing loops" becomes a claim about a *class* of work, with a pointer to docs/35. The compound-probability argument is kept but re-read as an argument for a correction loop. |
| `21-context-vs-loop-engineering` | Add the fourth position: for coding, decomposition boundary (context vs role) is the live debate, not loop-vs-context. |
| `11-cost-control` | Add Ng's post-tokenmaxxing framing: instrument **cost per unit of work**, not token volume. |
| `04-verification` | Add the coverage-reporting pattern (a fan-out that reports clean without anyone having looked). |
| `07-subagents` | Add "specialise by framing, not by role" + the reuse-one-definition-as-subagent-or-teammate property. |
| `32-reading-list` | Add Ng's AI Engineering Skills Map series. |
| `SOURCES.md` | Add The Batch letters as a tracked source; prune sources the sweep found dead. |

---

## 3. The news backfill

Last digest **2026-07-08**; last run attempt **2026-07-20** (failed 3/3 on
`Credit balance is too low`). An eight-week hole.

A 9-angle + 2-critic sweep of 2026-07-01 → 2026-09-04 is running. Its output becomes one
dated catch-up entry in `LOOP_ENGINEERING_NEWS.md`, with findings integrated into the docs
above under the KB's existing ≥3.0 scoring gate.

*(Section filled in once the sweep returns — findings, scores, and per-doc integration targets.)*

---

## 4. Tracker re-arm

**Root cause of the 2026-07-20 failure, established this session:** the run's log shows
`ANTHROPIC_API_KEY or another auth source is set and takes precedence over your claude.ai
login`, then `Credit balance is too low`. A pay-as-you-go key with no credit was shadowing
the subscription login.

**That key is gone now** — verified: no `ANTHROPIC_API_KEY` in any shell profile, no
`scripts/run-loop-news.env`, not set in the current environment. So a re-arm should run on
the claude.ai login rather than reproduce the failure.

Sequence (deliberately **last**, so a scheduled run cannot race this branch):
1. Land this branch on `main`.
2. `cp scripts/com.luca.loop-news.plist ~/Library/LaunchAgents/` (keep the two copies in sync
   per `scripts/SCHEDULING.md`).
3. `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.luca.loop-news.plist`
4. Verify with `launchctl print gui/$(id -u)/com.luca.loop-news`.
5. **Validate rather than assume:** the schedule firing is not evidence it worked. Check
   `logs/loop-news-<date>.log` after the next run, or `launchctl kickstart` it once
   deliberately and watch — *after* this branch has landed.

---

## 5. Order of work

| # | Step | Gate |
|---|---|---|
| 1 | Sweep completes; score findings against the ≥3.0 gate | Coverage is FINDINGS, not VACUOUS/PARTIAL |
| 2 | Write `docs/35`, `36`, `37` | Every external reference is a markdown hyperlink (`CLAUDE.md` citation rule) |
| 3 | Pinakes section re-read against the § 2.3 publication table | **Blocking.** Public repo. |
| 4 | Restructure index + `mkdocs.yml` + `README.md` + `docs/index.md` | `mkdocs build --strict` passes |
| 5 | Revise docs per § 2.4 | Links resolve |
| 6 | Append the catch-up digest to `LOOP_ENGINEERING_NEWS.md`; update `SOURCES.md` | |
| 7 | `CHANGELOG.md` → `[3.0.0]`; commit; PR; merge | Adversarial review pass before merge |
| 8 | Tag `v3.0.0`, push tags, `gh release create --latest` | |
| 9 | Re-arm launchd; validate | Not before step 7 lands |

**Verification gate throughout:** `mkdocs build --strict` (CI runs it) and the citation-link
check `grep -rn 'repo: github\.com' docs/ | grep -v '\[github'`.

---

## 6. What would change this plan

| Observable | Revised approach |
|---|---|
| The sweep finds Anthropic has published *newer* guidance reversing the multi-agent-for-coding position | § 1's premise weakens; docs/37 becomes a both-sides doc rather than a recommendation |
| The sweep finds Claude Code shipped primitives that make role-split sessions work (e.g. agent teams leaving experimental with reliable handoff) | docs/37 gains a "what changed" section; the anti-pattern becomes version-scoped |
| The sweep's coverage returns VACUOUS or PARTIAL | Do not publish a catch-up digest claiming eight weeks of coverage — say what was swept and what was not |
| Ng's fourth letter ("Shaping the Build", ~2026-09-11) lands before this ships | Hold docs/36 open for it, or ship and add it in a PATCH |
