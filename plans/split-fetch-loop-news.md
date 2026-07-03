# Plan: Split `fetch-loop-news` into Search + Integrate skills, with worktree isolation

_Created: 2026-07-03 · v1_
_Updated: 2026-07-03 · v2 — refine-plan pass 1: fixed per-attempt worktree lifecycle, corrected success signal (exit-code, not "main advanced"), fixed BASE_SHA timing + mktemp path + primary-alignment guard, clarified that the auto classifier (not `--allowedTools`) is the real permission gate, corrected the turn-headroom claim, added B stale-artifact date guard._
_Updated: 2026-07-03 · v3 — refine-plan pass 2: removed A-dedupes/B-dedupes contradiction; made `LOG_FILE` absolute (relative path was lost inside the disposable worktree); wrapper now copies the findings artifact out to `logs/` before teardown (it was destroyed, falsifying the "inspectable/re-runnable" claim); specified B's `git add` list to **include `mkdocs.yml`** (Phase 4 edits nav but current stage list omits it — latent bug) and drop the daily self-add of SKILL.md._
_Updated: 2026-07-03 · v4 — refine-plan pass 3: **HIGH** — restored the publish-safety retry guard I had wrongly dropped. Worktree isolation makes the filesystem disposable but B's `git push origin HEAD:main` is durable; if an attempt pushes then fails late, a blind retry double-commits the day's digest. Guard adapted from "primary HEAD moved" to "origin/main advanced past BASE_SHA": on failure, refuse to retry once main has advanced._
_Updated: 2026-07-03 · v5 — critical decomposition review (no assumptions): separated "split" from "worktree isolation" as independent changes with the concrete worktree justification (daily run must not depend on the primary checkout's current branch/state); surfaced the core tension that **context isolation and a literal "A calls B" are mutually exclusive**, laid out Options 1/2/3 with a pros/cons matrix; retracted two over-confident claims (model right-sizing is quality-sensitive, not free; conditional-4c would override a documented every-run norm → made both user decisions); added granular B-only retry as a real two-session-only win._

## Goal

The `fetch-loop-news` skill currently does too much in one 25 KB procedure: it
searches sources, writes the digest, reasons about how each finding maps into the KB,
runs two structural-review passes, cuts a release, and commits. Split it into two
focused skills:

1. **`fetch-loop-news` (Search)** — searches the tracked sources + general web for
   relevant news, scores candidates, and produces a structured **findings artifact**.
   No dedup (that needs the news file — B's domain), no KB reasoning, no doc edits, no
   commit.
2. **`integrate-loop-news` (Integrate & Restructure)** — consumes the findings
   artifact, reasons about how to merge each finding into the KB, restructures the KB
   for coherence (the two review passes), determines the release tier, updates the
   changelog, commits, and publishes to `main`.

Skill 1 **calls** skill 2 as its final step. Both run in **the same isolated git
worktree** so the daily run never touches the primary checkout's working tree or
`main` mid-flight; the net result (the commits) lands on `main` only when the whole
pipeline completes successfully.

### Why split

- **Single responsibility / testability.** The search half and the reasoning half fail
  for different reasons (network/scraping vs. KB-consistency logic). Splitting lets each
  be re-run and debugged independently, and lets `integrate-loop-news` be exercised
  against a fixed findings file without re-scraping X/RSS.
- **Focused, followable procedures.** Each SKILL.md shrinks to one concern, which the
  model follows more reliably than one 25 KB monolith. (Note: in the recommended
  *single-session* design — A calls B in the same `claude -p` run — the **combined** turn
  count is roughly the monolith's plus a little artifact I/O; per-phase turn *headroom*
  only materialises in the two-separate-sessions variant under Open decision 2. The split
  is justified by clarity/testability/isolation, not by cutting turns.)
- **Isolation.** Today the loop edits and commits directly in the primary checkout on
  `main`. A crash mid-run can leave the working tree dirty (the wrapper already has a
  guard that refuses to retry when that happens). A worktree makes every attempt fully
  disposable: a failed attempt is discarded wholesale and retried from a clean base,
  which *simplifies* the wrapper's retry-safety logic.

---

## Decomposition analysis — is two the right cut, and how should the halves run?

The two-way split was proposed; this section pressure-tests it — and the assumptions
around it — against **single responsibility** and **efficiency**, taking nothing for
granted.

### First: "split" and "worktree isolation" are two independent changes

The request bundled them, but they are orthogonal and should be justified separately:

- **Worktree isolation** benefits the *monolith* just as much as a split — it could be
  added today without splitting anything. Its concrete justification is **not** vague
  "conflict with main": on a single daily machine the real hazard is that the primary
  checkout may be on **any branch / dirty state** when the 05:00 cron fires. (Right now,
  for instance, the checkout is on `feature/split-loop-news-skill`.) The current
  monolith would then commit the daily digest onto **whatever branch is checked out** —
  a genuine mess. A worktree makes the daily run **always operate on a fresh `origin/main`
  base regardless of the primary checkout's state.** That is the real, concrete win, and
  it stands independently of the split.
- **The split** is justified by single-responsibility + (conditionally) efficiency, below.

Because they're independent, they could even ship as two PRs. Keeping them together is a
convenience, not a necessity — noted so the worktree work isn't held hostage to the split.

### The split's single-responsibility case is sound

### What are the real responsibilities?

| # | Work | Nature | Failure mode | Context it needs |
|---|---|---|---|---|
| 1–3 | Search (load context, per-source scrape, general search) | **Retrieval** — external I/O, breadth, noisy, parallelisable, no KB writes | network / scraping / login walls | SOURCES.md, keywords, dates; accumulates **large** raw page/thread/HTML context |
| 4–5 | Integrate (digest + per-finding doc writes, reading list, KB gaps) | **Additive writing** — merge *this run's* findings into docs | consistency of new edits | findings artifact + the docs it touches |
| 6–7 | Restructure (4b consistency, 4c findings-driven structural review) | **Holistic reasoning** — whole-KB coherence; can force a MAJOR change | mis-structuring / over-merging | findings artifact + the just-integrated KB state |
| 8 | Release + commit + push | **Mechanical** | git / publish | staged file list |

The **cleanest single-responsibility boundary is between retrieval (1–3) and
everything that reasons about/writes the KB (4–8)** — they fail for unrelated reasons,
need disjoint context, and one is parallel-I/O while the other is sequential-reasoning.
So the proposed 2-way cut is sound. The two sub-questions are **(a) 2 vs 3 skills** and
**(b) how the two halves run**, and efficiency turns almost entirely on (b).

### The core tension: context isolation ⟺ NOT a literal "A calls B"

This is the crux the request's two goals collide on, and it must be decided consciously —
I earlier assumed it away. **The only way to stop Search's bulky retrieval context (raw
pages, expanded threads, HTML, READMEs — tens of thousands of tokens B does not need) from
sitting in the window while B reasons is a *session/context boundary*.** But a context
boundary means A does **not** call B in-process — something else (the wrapper, or a
fresh-context subagent) starts B. So:

> **Literal "skill A calls skill B" (one shared context) and context isolation are
> mutually exclusive.** You can have at most one directly; the request asks for both.

Three ways to resolve it — genuinely different, none strictly dominant:

| Option | How A→B happens | Context isolation? | Model right-sizing? | Granular retry (B-only)? | Honors literal "A calls B"? | Cost |
|---|---|---|---|---|---|---|
| **1 — Single session** | A invokes B via the Skill tool, one `claude -p` | **No** — B inherits all of Search's context | No | No — a retry re-runs search too | **Yes** | Simplest; works interactively unchanged; but long session → `--max-turns`/compaction risk, higher tokens |
| **2 — Two sessions** | Wrapper runs `claude -p` for A, then a second for B, handing off `findings.json` | **Yes** — B starts clean | Yes (different `--model` per call) | Yes — B re-runs from the saved artifact without re-scraping | **No** — the *wrapper* calls B | Extra cold start + B re-reads KB (largely unavoidable anyway); interactive use needs both run manually or a conditional |
| **3 — Subagent** | A, as its final step, spawns B as a **fresh-context subagent** (Task tool) that follows `integrate-loop-news` | **Yes** — subagent has its own window | Yes (per-subagent model) | No (one session) | **Yes** (A literally invokes B) | Subagent doing commits/push to `main` + propagating failure/exit code back to A is unusual and needs validation; "main event as a sub-task of search" is architecturally inverted |

**Reassessing the efficiency claims I made too confidently:**

- **Context isolation is a real, robust win** for Options 2 and 3 — this holds.
- **Model right-sizing is NOT free and I overstated it.** Search is not purely mechanical:
  relevance **tiering**, thread **judgment**, and "the 3 most innovative links" **curation**
  are quality-sensitive calls. Downgrading Search to a cheaper model risks worse findings →
  garbage into B. So model-per-stage is *possible* but must be **quality-validated**, not
  assumed as a saving.
- **Granular retry** (re-run only B against the saved artifact, skipping the expensive
  search) is a genuine, previously-unstated efficiency win — but **only Option 2 gets it.**

### Why not 3 skills (search / integrate / restructure)?

Splitting Integrate from Restructure sharpens SR on paper, but 4b/4c are explicitly
*findings-driven* and operate on the **just-integrated state**; a third boundary would
reload the KB *and* reconstruct "what changed this run," duplicating context and weakening
the "did this run's edits stay consistent" check. The coupling cost outweighs the SR gain
→ **keep Integrate+Restructure in one skill.**

**A tempting 3-way efficiency argument — and why I'm NOT baking it in.** One could make
the expensive whole-KB 4c run at a *lower cadence* (only on days with structural change).
But `CLAUDE.md` and the project's memory explicitly mandate **"structural review is the
norm after *every* run" (Phase 4c)**. Making it conditional would silently override a
deliberate, documented user convention. That is a **user decision, not an optimisation I
should assume** — flagged in Open decisions, not baked in.

### Recommendation (with the tension surfaced, not hidden)

- **2 skills**, cut at retrieval | KB-reasoning — this part is unambiguous. ✔
- **The A→B mechanism is a genuine user decision** (Options 1/2/3 above), because it trades
  the user's own literal "A calls B" against the user's own "efficiency" goal. My lean:
  **Option 2 (two sessions)** — it delivers the isolation *and* granular retry that best
  serve "efficiency," and the only thing it gives up is the *literal* phrasing of "A calls
  B" (the pipeline still runs A→B, just wrapper-sequenced). If honoring the literal call
  matters more, **Option 3** preserves it with isolation at the price of validating a
  commit-and-push-from-subagent flow. **Option 1** only if simplicity/interactive-parity
  outweighs efficiency. → surfaced in Open decision 2 for the user to settle.
- **4c cadence stays every-run** unless the user chooses to relax it (Open decision 5).

---

## Current state (what we're refactoring)

| Piece | Today |
|---|---|
| `.claude/skills/fetch-loop-news/SKILL.md` | Monolith: Phase 1 (load context) → 2 (per-source search) → 3 (general search) → 4 (write digest) → 4b (devil's-advocate review) → 4c (structural review) → 5 (release + commit) |
| `scripts/run-loop-news.sh` | Headless wrapper: runs `claude -p "/fetch-loop-news"` in the **primary checkout** on `main`, with retry/backoff, `--max-budget-usd 8`, transient-error scan, and a guard that refuses to retry if `HEAD` moved or the tree is dirty |
| `~/Library/LaunchAgents/com.luca.loop-news.plist` | launchd trigger, daily 05:00 local, runs the wrapper |
| Referenced in | `README.md`, `CLAUDE.md`, `docs/09-headless-mode.md`, `docs/34-loop-patterns.md`, `SOURCES.md`, `CHANGELOG.md`, `LOOP_ENGINEERING_NEWS.md`, `KB_GAPS.md` |

---

## Proposed architecture

```
run-loop-news.sh (wrapper)
  │  per attempt:
  ├─ git worktree add <wt> <temp-branch>   ← branch off freshly-fetched origin/main
  ├─ cd <wt>
  ├─ claude -p "/fetch-loop-news"          ← ONE session, inside the worktree
  │     │
  │     ├─ Skill A: fetch-loop-news (Search)
  │     │     Phase 1  load context (SOURCES.md, last_run_date, today, run_time)
  │     │     Phase 2  per-source search (subagents)
  │     │     Phase 3  general search + dynamic source expansion
  │     │     → writes .loop-news/findings.json (findings + run metadata)
  │     │     → invokes Skill B via the Skill tool
  │     │
  │     └─ Skill B: integrate-loop-news (Integrate & Restructure)
  │           Phase 4   read findings.json → write digest + per-finding doc integration
  │           Phase 4b  devil's-advocate KB review
  │           Phase 4c  findings-driven structural review
  │           Phase 5   release tier + changelog + commit + push origin HEAD:main
  │
  ├─ (on success) remove worktree, delete temp branch, fast-forward primary checkout
  └─ (on failure) remove worktree + temp branch, recreate fresh, retry
```

### The split line

| Phase (today) | Goes to |
|---|---|
| 1 — Load context | **A** (and A serialises `today`, `run_time`, `last_run_date` into the artifact for B) |
| 2 — Per-source search (all `type:` strategies + scoring rubric) | **A** |
| 3 — General search + dynamic source expansion | **A** |
| 4 — Write digest + per-finding doc integration + reading-list + KB-gap tracking | **B** |
| 4b — Devil's-advocate KB review | **B** |
| 4c — Findings-driven structural review | **B** |
| 5 — Release determination + changelog + commit + push | **B** |

Rationale: the cut falls exactly at the artifact boundary. Everything **A** does is
"find and score candidates"; everything **B** does is "reason about the KB and change
it." The keyword-tier scoring rubric stays with A (it gates what's a candidate); the KB
design spine (What/How/When/How much/How-do-you-know) stays with B (it governs
restructuring).

### Handoff contract — `.loop-news/findings.json`

A writes, B reads — both at `./.loop-news/findings.json` relative to the shared worktree
cwd. `.loop-news/` is **gitignored** so it never gets committed. Because the worktree is
torn down after the run, the wrapper **copies the artifact out to the primary checkout's
`logs/findings-<date>.json`** before teardown (in every exit path), so it survives for
post-mortem inspection and for re-running B against a fixed file.

```json
{
  "schema": 1,
  "today": "2026-07-03",
  "run_time": "2026-07-03 04:12 UTC",
  "last_run_date": "2026-07-02",
  "findings": [
    { "source": "@handle", "title": "...", "url": "https://...",
      "date": "2026-07-03", "tier": 1, "summary": "..." }
  ],
  "sources_to_consider": [
    { "actor": "...", "type": "x", "handle_or_url": "...", "why": "..." }
  ]
}
```

- `findings` is the merged, scored, **pre-dedup** list from Phases 2+3. B does the
  dedup against `LOOP_ENGINEERING_NEWS.md` (dedup needs the news file, which is B's
  domain).
- `sources_to_consider` carries A's dynamic-source-expansion suggestions so B can add
  rows to `SOURCES.md` and record them in the digest.
- Run metadata (`today`, `run_time`, `last_run_date`) travels in the artifact so B
  never re-derives time and both halves agree on the digest header.

The artifact is the **primary** handoff. Because A and B share one model session, the
findings are also already in context — the artifact is belt-and-suspenders that (a) lets
B be re-run independently against the copied-out `logs/findings-<date>.json` and (b)
survives context compaction on a long run.

### How A calls B

At the end of A's Phase 3, A invokes **`Skill(skill: integrate-loop-news)`**. This
keeps everything in one session and one worktree (satisfying "the two skills work in
the same worktree"). Requires `Skill` in the wrapper's `--allowedTools`.

**Fallback if Skill-tool chaining is unreliable in headless `-p`:** A's final
instruction is to `Read` `.claude/skills/integrate-loop-news/SKILL.md` and follow it
inline. Same session, same context, no dependency on the Skill tool. The plan validates
the primary path in Step 8 and falls back only if it fails.

### Worktree ownership — the wrapper owns the lifecycle (recommended)

The **wrapper** (`run-loop-news.sh`), not the model, creates and tears down the
worktree. **Skill B** does the semantic `git commit` (it owns the release tier + message
format) and the `git push origin HEAD:main`; the wrapper owns worktree create, teardown,
retry, and primary-checkout alignment.

Why wrapper-owned (vs. model-driven `EnterWorktree`/`git worktree` inside the skill):

- **Deterministic cleanup.** A crashed model can't orphan a worktree the shell created —
  the wrapper removes it in every exit path (`trap`).
- **Cleaner retries — but the publish guard must stay.** Full isolation means a failed
  attempt's *filesystem* is discarded wholesale (its worktree is thrown away), and each
  retry branches a **fresh** worktree off the latest `origin/main`. This removes the
  *dirty-tree* half of today's guard. It does **not** remove the *already-published* half:
  B's `git push origin HEAD:main` is a **durable external side effect** that outlives the
  worktree. If an attempt pushes and then claude still exits non-zero (or a transient-error
  marker appears in the output *after* the push), a blind retry would **double-commit the
  day's digest**. So today's guard is **adapted, not deleted**:
  - **Success** = claude exit 0 **and** no transient-error marker → done, no retry.
    (A zero-finding day cuts tier = None and makes **no** commit, so `main` correctly does
    not advance yet the run succeeded — which is why success is judged by exit code, not by
    "did `main` advance.")
  - **Before retrying a failed attempt**, `git fetch origin main` and compare to
    `BASE_SHA`. If `origin/main` **advanced**, a prior attempt already published →
    **stop and notify, do not retry** (mirrors today's "failed AFTER committing — not
    retrying"). If it did **not** advance, nothing durable happened → safe to retry with a
    fresh worktree.
  - The same `BASE_SHA` compare, on the success path, also decides whether the primary
    checkout needs a fast-forward.
- **The wrapper already owns isolation concerns** (retry, budget, transient-error scan,
  notify-on-give-up). Worktree lifecycle is the same class of concern.
- **Model logic stays about content**, not git plumbing.

Trade-off: an **interactive** `/fetch-loop-news` (a human typing it in the primary
checkout, no wrapper) would not get a worktree. Mitigation: the daily automated path is
the one that matters for isolation; the skill header documents "for isolated runs, invoke
via `scripts/run-loop-news.sh`." (Alternative designs are logged under *Open decisions*.)

---

## Wrapper changes (`scripts/run-loop-news.sh`)

Wrap **each attempt** in its own fresh worktree (so a discarded attempt leaves nothing
behind and the next retry starts from the latest `origin/main`). Sketch (integrates with
current `set -uo pipefail`, `MAX_ATTEMPTS`, backoff, transient-error scan, `notify`):

**Two path fixes the cd-into-worktree makes mandatory:** the current script sets
`LOG_FILE="logs/loop-news-….log"` (relative) and `cd`s to `$REPO_ROOT`. Once claude runs
in the worktree, any relative `logs/` path resolves *inside the disposable worktree* and
is destroyed on teardown. So (a) make `LOG_FILE` an **absolute** path under
`$REPO_ROOT/logs/` before any `cd`, and (b) have the wrapper copy the findings artifact
out of the worktree before removing it.

```bash
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$REPO_ROOT/logs"
LOG_FILE="$REPO_ROOT/logs/loop-news-$(date +%Y%m%d).log"   # ABSOLUTE — survives teardown
git -C "$REPO_ROOT" worktree prune            # clear any orphan from a prior crash

# Capture the base ONCE, before any attempt, so the post-run "did main advance?"
# comparison is meaningful.
git -C "$REPO_ROOT" fetch origin main
BASE_SHA="$(git -C "$REPO_ROOT" rev-parse origin/main)"

WT_DIR=""; TEMP_BRANCH=""
cleanup_worktree() {                          # tears down THIS attempt's worktree
  # Preserve the artifact for post-mortem before the worktree vanishes.
  [[ -n "$WT_DIR" && -f "$WT_DIR/.loop-news/findings.json" ]] && \
    cp "$WT_DIR/.loop-news/findings.json" "$REPO_ROOT/logs/findings-$(date +%Y%m%d).json" 2>/dev/null || true
  [[ -n "$WT_DIR" ]] && { git -C "$REPO_ROOT" worktree remove --force "$WT_DIR" 2>/dev/null || rm -rf "$WT_DIR"; }
  [[ -n "$TEMP_BRANCH" ]] && git -C "$REPO_ROOT" branch -D "$TEMP_BRANCH" 2>/dev/null || true
  WT_DIR=""; TEMP_BRANCH=""
}
trap cleanup_worktree EXIT                     # backstop if the script dies mid-attempt

# --- inside the attempt loop, per attempt: ---
cleanup_worktree                               # discard a failed previous attempt
git -C "$REPO_ROOT" fetch origin main          # each retry branches off the latest tip
WT_PARENT="$(mktemp -d -t loop-news-wt.XXXXXX)"   # git worktree add needs a NON-existent
WT_DIR="$WT_PARENT/wt"                             # leaf path, so nest under the temp dir
TEMP_BRANCH="loop-news-run-$(date -u +%Y%m%d-%H%M%S)-a${attempt}"
git -C "$REPO_ROOT" worktree add -b "$TEMP_BRANCH" "$WT_DIR" origin/main
( cd "$WT_DIR" && run_attempt "$attempt" )     # claude runs with cwd = the worktree
# run_attempt success = exit 0 AND no transient-error marker (UNCHANGED from today).
# On success: break. On FAILURE, before looping, guard against double-publishing:
git -C "$REPO_ROOT" fetch origin main
if [[ "$(git -C "$REPO_ROOT" rev-parse origin/main)" != "$BASE_SHA" ]]; then
  notify "Attempt ${attempt} failed AFTER publishing (origin/main advanced) — not retrying; check repo state."
  exit 1                                        # a prior attempt already pushed → never retry
fi
# else: nothing durable happened → backoff and retry with a fresh worktree.

# --- after the loop, if the run succeeded: ---
git -C "$REPO_ROOT" fetch origin main
if [[ "$(git -C "$REPO_ROOT" rev-parse origin/main)" != "$BASE_SHA" ]]; then
  # B pushed a commit → align the primary checkout, but only if it's actually on main
  if [[ "$(git -C "$REPO_ROOT" symbolic-ref --quiet --short HEAD)" == "main" ]]; then
    git -C "$REPO_ROOT" pull --ff-only origin main
  fi
fi
```

Changes to the `claude` invocation:
- Runs with cwd = the worktree.
- **Success signal is unchanged:** `run_attempt` still returns success on exit 0 with no
  transient-error marker (a zero-finding day legitimately makes no commit, so success is
  judged by exit code, not by "did `main` advance"). The `BASE_SHA` compare serves two
  guard roles: (1) on **failure**, refuse to retry if `origin/main` already advanced
  (a prior attempt published — retrying would double-commit); (2) on **success**, decide
  whether to fast-forward the primary checkout.
- `--allowedTools` **defensively** adds `Write` (findings artifact), `Skill` (A→B call),
  and `Bash(git *)` (B commits + pushes), keeping `Read,Edit,WebFetch,mcp__claude-in-chrome__*`.
  Note: under `--permission-mode auto` the **auto classifier**, not `--allowedTools`, is
  the real gate — the current skill already runs `git add/commit/push` with none of
  `Bash`/`git` in its allowlist. Extending the allowlist is a fast-path, not a hard
  requirement; Step 8 confirms the classifier approves `Write`, `Skill`, and the
  `git worktree`/`git push` calls in practice.
- `--max-turns` may need raising (search + integrate in one session ≈ today's monolith +
  artifact I/O). Start at current 40; if runs hit the cap, bump to ~60. (Measured in
  Step 8, not guessed.)
- The old retry guard is **adapted, not removed.** Its dirty-tree half is dropped (the
  worktree is disposable), but its already-published half is retargeted from "primary
  checkout `HEAD` moved" to "`origin/main` advanced past `BASE_SHA`" — because B's push is
  a durable side effect that survives worktree teardown, and a blind retry after a push
  would double-commit the day's digest.

`.gitignore`: add `.loop-news/` so the findings artifact is never committed. (Confirm
`logs/` is already ignored — it is.)

---

## Files

| File | Action |
|---|---|
| `.claude/skills/fetch-loop-news/SKILL.md` | **Rewrite** → Search only (Phases 1–3), writes `.loop-news/findings.json`, invokes Skill B. Update `description:` frontmatter. |
| `.claude/skills/integrate-loop-news/SKILL.md` | **Create** → Integrate & Restructure (Phases 4/4b/4c/5), reads the artifact. |
| `scripts/run-loop-news.sh` | **Edit** → worktree lifecycle, `--allowedTools`, simplified retry guard. |
| `.gitignore` | **Edit** → add `.loop-news/`. |
| `README.md` | **Edit** → repo map: two skills, note the pipeline + worktree isolation. |
| `CLAUDE.md` | **Edit** → repository map + "Git workflow" (automated content now runs in a worktree and publishes to `main` on completion); "Structural review" note points at `integrate-loop-news` as Phase 4c's home. |
| `docs/09-headless-mode.md` | **Edit** → document the two-skill pipeline + worktree-isolated headless run + simplified retry-on-clean-base logic. |
| `docs/34-loop-patterns.md` | **Edit** → update the loop-news pattern entry: two-stage (search→integrate) pipeline, worktree isolation (anchor near the existing Docs-Sync worktree pattern). |
| `docs/28-routines.md` | **Edit only if** it names the single-skill flow (verify during impl). |
| `SOURCES.md` | **Edit** → any header note that references the skill by the old single-skill responsibility. |
| `CHANGELOG.md` | **Edit** → new version entry (see Releases). |
| `plans/split-fetch-loop-news.md` | this file. |

---

## KB / docs rules to honour (from CLAUDE.md)

- **Keep docs current in the same session** — the infra/process change (one skill → two,
  plus worktree isolation) updates `docs/09`, `docs/34`, and `README`/`CLAUDE.md` in the
  same PR, not later.
- **This split is itself a loop-engineering pattern** (pipeline decomposition +
  worktree isolation for a self-writing KB). Capture it in `docs/34` (loop patterns) so
  the KB documents its own architecture — the meta-consistency the repo values.
- **Citations must link** — no new external citations expected here; if any are added,
  hyperlink them.
- **Release/versioning** — this is a feature (new skill + capability) → **MINOR** bump;
  tag + GitHub release in the same turn as the commit (repo rule).

---

## Git workflow for this change

Per `CLAUDE.md`: **this refactor is code/feature work, not automated content — it goes on
its own branch + PR**, not direct to `main`. (The direct-to-`main` exception is only for
the skill's *generated output*.) Branch: `feature/split-loop-news-skill`.

---

## Implementation steps

- [ ] **Step 1 — Extract Skill A.** Rewrite `fetch-loop-news/SKILL.md` down to Phases
      1–3. Add a final "Phase 4 — Hand off" section: write `.loop-news/findings.json`
      (schema above), then invoke `Skill(skill: integrate-loop-news)`. Update
      `description:` to "search only." Move the JSON-array per-subagent return spec into
      A; keep the keyword-tier rubric in A.
- [ ] **Step 2 — Create Skill B.** New `integrate-loop-news/SKILL.md`. Phase 0: read
      `.loop-news/findings.json` — abort with a clear error if it is absent, malformed,
      or its `today` field does not match the current UTC date (guards against consuming
      a stale artifact from a prior attempt). Then port Phases 4, 4b, 4c, 5 verbatim,
      retargeting "the findings" to the artifact and using `run_time`/`today` from it.
      Phase 5c: `git add` the explicit KB file list (never `git add -A`), commit with the
      existing message format, then `git push origin HEAD:main`. Phase 5a's tier = None
      case still makes **no** commit (a zero-finding day is a legitimate no-op).

      **Correct the stage list while porting.** The current Phase 5c stages
      `LOOP_ENGINEERING_NEWS.md LOOP_ENGINEERING.md SOURCES.md CHANGELOG.md KB_GAPS.md docs/`
      plus its own `SKILL.md`, but **omits `mkdocs.yml`** — even though Phase 4 edits the
      `nav:` there, so today those nav additions are silently left uncommitted (a latent
      bug). B's list must be:
      `LOOP_ENGINEERING_NEWS.md LOOP_ENGINEERING.md SOURCES.md CHANGELOG.md KB_GAPS.md mkdocs.yml docs/`
      — **add `mkdocs.yml`**, and **drop the daily self-add of `.claude/skills/.../SKILL.md`**
      (skills are now feature-managed via PR, not edited by the daily content run).
- [ ] **Step 3 — Wrapper.** Make `LOG_FILE` absolute; add per-attempt worktree
      create/teardown (`trap` + `cleanup_worktree` at the top of each attempt, which also
      copies the artifact out to `logs/`), run `claude` with cwd = the worktree,
      defensively extend `--allowedTools`, keep the existing exit-code + transient-scan
      success signal, **adapt** the retry guard (drop the dirty-tree check; on failure
      refuse to retry if `origin/main` advanced past `BASE_SHA`), and fast-forward the
      primary checkout after a successful run **only if** `origin/main` advanced and the
      primary is on `main`.
- [ ] **Step 4 — `.gitignore`.** Add `.loop-news/`.
- [ ] **Step 5 — Docs.** Update `docs/09`, `docs/34`, `README.md`, `CLAUDE.md`, and
      `SOURCES.md`/`docs/28` if they reference the old single-skill flow.
- [ ] **Step 6 — Changelog + release.** MINOR bump; add entry; plan tag + GitHub release
      after merge.
- [ ] **Step 7 — Static check.** `bash -n scripts/run-loop-news.sh`; re-read both
      SKILL.md files end-to-end for a clean A→artifact→B contract (no dangling references
      to phases that moved).
- [ ] **Step 8 — End-to-end dry run.** Run `scripts/run-loop-news.sh` once by hand.
      Verify: worktree created off `origin/main`; A wrote `findings.json`; B consumed it,
      integrated, committed, pushed to `main`; worktree + temp branch removed; primary
      checkout fast-forwarded. Measure turns used (adjust `--max-turns` if near cap) and
      confirm the Skill-tool A→B call worked (else switch to the Read-the-SKILL fallback).
- [ ] **Step 9 — Failure-path check.** Force a mid-run failure (e.g. kill during A) and
      confirm: worktree removed, `main` untouched, next attempt starts from a clean base.
- [ ] **Step 10 — PR.** Open `feature/split-loop-news-skill` → `main`; after merge, tag
      + GitHub release; re-align local checkout.

---

## Risks & mitigations

| Risk | Mitigation |
|---|---|
| Skill-tool `Skill(...)` chaining doesn't fire in headless `-p` | Validated in Step 8; documented fallback is A `Read`s + follows B's SKILL.md inline (same session/context) |
| One session (search + integrate) exceeds `--max-turns 40` | Measure in Step 8; raise cap to ~60; the budget guard (`--max-budget-usd 8`) still bounds cost |
| `git push origin HEAD:main` rejected because `main` advanced during the run | On a single daily machine this shouldn't happen; wrapper fetches `origin/main` right before creating the worktree. If push is rejected, B fails loudly, the attempt is discarded, and the retry branches off the new tip |
| Worktree left orphaned on crash | Wrapper `trap cleanup_worktree EXIT` removes it in every path; also run `git worktree prune` at start |
| Zero-finding day misread as failure → retry loop | Success stays the exit-code + transient-scan signal; a zero-finding day makes no commit and that is a success, not a failure |
| Attempt pushes to `main`, then fails late → retry double-commits the day's digest | Retry guard: on failure, `git fetch origin main`; if `origin/main` advanced past `BASE_SHA`, a prior attempt already published → stop + notify, never retry |
| Findings artifact accidentally committed | `.loop-news/` gitignored; B stages only the explicit KB file list, never `git add -A` |
| Interactive `/fetch-loop-news` runs without isolation | Documented: isolated runs go through the wrapper. (See Open decisions for a skill-owned alternative.) |
| B runs with an empty/missing artifact (A failed silently) | B Phase 0 aborts with a clear error if `findings.json` is absent or malformed; the wrapper's transient-error scan + exit-code check catches it |
| Two SKILL.md files drift out of sync (shared conventions) | Keep the artifact schema as the single contract; cross-link the two SKILL headers ("A produces / B consumes `.loop-news/findings.json`") |

---

## Open decisions (surface to user; recommendation marked)

1. **Worktree ownership — wrapper vs. skill.** *Recommended: wrapper-owned* (above:
   deterministic cleanup, simpler retries, model stays about content). *Alternative:
   skill-owned* via `EnterWorktree`/`git worktree` inside Skill A — self-contained and
   also isolates interactive runs, but model-driven git plumbing in headless is more
   fragile (orphan worktrees on crash) and complicates the retry guard. Pick before Step 3.
2. **A→B mechanism — the core tension (see Decomposition analysis).** Context isolation
   and a literal "skill A calls skill B" are mutually exclusive. *Recommended: Option 2
   (two wrapper-sequenced sessions)* for isolation + granular B-only retry; *Option 3
   (fresh-context subagent)* preserves the literal call with isolation but needs a
   commit/push-from-subagent flow validated; *Option 1 (single session, Skill tool)* is
   simplest and interactive-parity but forgoes the efficiency wins. **This is a genuine
   user decision** — it pits the request's "A calls B" against its "efficiency." The
   architecture diagram, "How A calls B," and wrapper sections below currently describe
   the single-session shape and must be reconciled to whichever option is chosen.
3. **Skill B name.** *Recommended: `integrate-loop-news`* (captures merge + restructure).
   Alternatives: `restructure-kb`, `merge-loop-news`.
4. **Keep A named `fetch-loop-news`?** *Recommended: yes* — it's the entry point the
   wrapper, plist, and docs reference; renaming ripples through all of them for no
   functional gain. "fetch" still fairly describes the search half.
5. **Phase 4c structural-review cadence — every run vs. conditional.** Today `CLAUDE.md`
   + project memory mandate the deep whole-KB structural review after **every** run.
   *Pros of every-run:* consistency norm the project deliberately chose; catches drift
   early. *Cons:* the deep pass is expensive and often low-yield on 0-new-doc days.
   *Conditional alternative* (run deep 4c only when the day produced structural change;
   always run light 4b): cheaper, but silently weakens a documented convention.
   *Recommended: keep every-run* unless you explicitly choose to relax it — this is your
   convention to change, not mine to optimise away.

---

## Verification / done criteria

- Both SKILL.md files read cleanly end-to-end; every phase reference resolves; the
  artifact schema is the only cross-skill contract.
- Dry run (Step 8): worktree isolation confirmed, A→B handoff confirmed, commit landed on
  `main`, worktree/branch cleaned up, primary checkout aligned.
- Failure path (Step 9): `main` untouched, no orphan worktree, clean retry.
- Docs (`09`, `34`, `README`, `CLAUDE.md`) reflect the two-skill + worktree architecture.
- CHANGELOG MINOR entry present; tag + release planned post-merge.

---

## Iteration log

- **v1 (2026-07-03)** — Initial draft: split into `fetch-loop-news` (search) +
  `integrate-loop-news` (integrate/restructure), wrapper-owned worktree isolation,
  `.loop-news/findings.json` handoff, A→B via Skill tool.
- **v2 (2026-07-03, refine pass 1)** — 2 HIGH, 5 MEDIUM, 2 LOW resolved. Worktree is now
  created/torn down **per attempt** (was once, contradicting the retry prose). Success
  signal corrected to the existing exit-code + transient-scan (the "origin/main advanced"
  check falsely fails zero-finding days). Wrapper sketch fixes: `BASE_SHA` captured before
  the run; `mktemp` leaf-path so `worktree add` doesn't hit an existing dir; primary
  fast-forward guarded on the checkout actually being `main`. Clarified the auto-mode
  classifier — not `--allowedTools` — is the real permission gate. Corrected the
  turn-headroom motivation (doesn't hold for single-session). Added B Phase-0 stale-artifact
  date guard.
- **v3 (2026-07-03, refine pass 2)** — 4 MEDIUM resolved. Removed the A-dedupes vs
  B-dedupes contradiction (dedup is B's; it needs the news file). Made `LOG_FILE` absolute
  — a relative `logs/` path resolves inside the disposable worktree after the `cd` and is
  lost on teardown. Wrapper now copies `.loop-news/findings.json` out to
  `logs/findings-<date>.json` before teardown (it was being destroyed, contradicting the
  "inspectable / independently re-runnable" motivation). Specified B's explicit `git add`
  list to **add `mkdocs.yml`** (Phase 4 edits its `nav:` but the current stage list omits
  it, so nav additions are silently uncommitted today) and to drop the daily self-add of
  the skill's own `SKILL.md`.
- **v4 (2026-07-03, refine pass 3)** — 1 HIGH resolved. Restored the publish-safety retry
  guard that pass-1 wrongly dropped: worktree isolation makes the *filesystem* disposable,
  but B's `git push origin HEAD:main` is a durable external side effect, so an attempt that
  publishes and then fails late must not be blindly retried (double-commit). Guard retargeted
  from "primary checkout HEAD moved" to "`origin/main` advanced past `BASE_SHA`." Also
  confirmed repo is PUBLIC — plan contains no secrets/PII (PRIMARY CHECK).
- **v5 (2026-07-03, critical decomposition review)** — Took nothing for granted per user
  request. (1) Separated *split* from *worktree isolation* — independent changes; gave the
  concrete worktree justification (the daily cron must not inherit the primary checkout's
  current branch/dirty state). (2) Surfaced the **core tension**: context isolation and a
  literal "A calls B" are mutually exclusive → Options 1 (single session), 2 (two sessions),
  3 (subagent) with a pros/cons matrix; A→B mechanism is now an explicit user decision.
  (3) Retracted over-confident claims: model right-sizing is quality-sensitive (not a free
  saving); conditional-4c would override the documented every-run norm (now a user decision,
  Open decision 5). (4) Added granular B-only retry as a two-session-only efficiency win.
