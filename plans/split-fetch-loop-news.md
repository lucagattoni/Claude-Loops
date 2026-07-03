# Plan: Split `fetch-loop-news` into Search + Integrate skills, with worktree isolation

_Created: 2026-07-03 · v1_
_Updated: 2026-07-03 · v2 — refine-plan pass 1: fixed per-attempt worktree lifecycle, corrected success signal (exit-code, not "main advanced"), fixed BASE_SHA timing + mktemp path + primary-alignment guard, clarified that the auto classifier (not `--allowedTools`) is the real permission gate, corrected the turn-headroom claim, added B stale-artifact date guard._
_Updated: 2026-07-03 · v3 — refine-plan pass 2: removed A-dedupes/B-dedupes contradiction; made `LOG_FILE` absolute (relative path was lost inside the disposable worktree); wrapper now copies the findings artifact out to `logs/` before teardown (it was destroyed, falsifying the "inspectable/re-runnable" claim); specified B's `git add` list to **include `mkdocs.yml`** (Phase 4 edits nav but current stage list omits it — latent bug) and drop the daily self-add of SKILL.md._
_Updated: 2026-07-03 · v4 — refine-plan pass 3: **HIGH** — restored the publish-safety retry guard I had wrongly dropped. Worktree isolation makes the filesystem disposable but B's `git push origin HEAD:main` is durable; if an attempt pushes then fails late, a blind retry double-commits the day's digest. Guard adapted from "primary HEAD moved" to "origin/main advanced past BASE_SHA": on failure, refuse to retry once main has advanced._
_Updated: 2026-07-03 · v5 — critical decomposition review (no assumptions): separated "split" from "worktree isolation" as independent changes with the concrete worktree justification (daily run must not depend on the primary checkout's current branch/state); surfaced the core tension that **context isolation and a literal "A calls B" are mutually exclusive**, laid out Options 1/2/3 with a pros/cons matrix; retracted two over-confident claims (model right-sizing is quality-sensitive, not free; conditional-4c would override a documented every-run norm → made both user decisions); added granular B-only retry as a real two-session-only win._
_Updated: 2026-07-03 · v6 — user settled the decisions: **Option 2 (two wrapper-sequenced sessions) + every-run 4c**. Reconciled the whole plan to that shape — architecture diagram, handoff, worktree-ownership, and the wrapper sketch rewritten for two sessions in one worktree with reset-between-attempts and granular (B-only) retry; A now writes the artifact and stops (no in-skill call to B); per-stage `--allowedTools`/`--max-turns`; model-per-stage deferred as a future tuning lever; corrected the "shared context" handoff note; risks/steps/decisions updated._

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

- **Context isolation is a real but SMALLER win than first stated.** Phase 2's per-source
  scraping **already runs in subagents** (each returns only a compact JSON array), so the
  bulky raw pages/threads/HTML **never accumulate in the main session** in the first place.
  The only search context B would inherit in a single session is **Phase 3** (the
  general-search bonus pass, which runs in the main session) plus the accumulated findings
  JSON — real, but tens of *thousands* of tokens, not the "all scraped pages" I implied.
  So isolation helps Options 2/3, but it is **not** the decisive factor I made it.
- **The stronger reason for a boundary is turn-budget + compaction.** A+B in one
  `--max-turns` session is the most likely thing to hit the cap or compact mid-restructure;
  B's doc-reading/editing is turn-heavy on its own.
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

### Decision (settled by the user, 2026-07-03)

- **2 skills**, cut at retrieval | KB-reasoning. ✔
- **Option 2 — two wrapper-sequenced sessions** (A then B, handoff via `findings.json`).
  Chosen for context isolation + **granular retry** (the flaky search half and the
  deterministic reasoning half retry independently), accepting that the *wrapper*
  mechanizes the A→B handoff rather than a literal in-skill call — which still honors the
  intent "B runs after A, consuming its output." The rest of this plan is written to this
  shape.
- **4c cadence: every run** (the documented norm kept; not relaxed).

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

**Two wrapper-sequenced sessions in one shared worktree.** The wrapper owns the worktree
and runs A and B as **separate `claude -p` invocations**; `findings.json` is the handoff.

```
run-loop-news.sh (wrapper)
  ├─ git worktree add <wt> <temp-branch>     ← branch off freshly-fetched origin/main (ONE per run)
  │
  ├─ attempt loop (≤ MAX_ATTEMPTS), each attempt in <wt>:
  │    ├─ reset <wt> hard to latest origin/main   (discards a failed attempt's partial edits;
  │    │                                            gitignored .loop-news/ survives)
  │    │
  │    ├─ SESSION A  (only if no valid findings.json yet — so a B-only retry SKIPS search)
  │    │    claude -p "/fetch-loop-news"   ← Skill A: Search
  │    │      Phase 1 load context · Phase 2 per-source search (subagents) ·
  │    │      Phase 3 general search + dynamic source expansion
  │    │      → writes .loop-news/findings.json (findings + run metadata), then STOPS
  │    │    (A failed → attempt fails, skip B)
  │    │
  │    └─ SESSION B  (fresh context — inherits none of A's search context)
  │         claude -p "/integrate-loop-news"   ← Skill B: Integrate & Restructure
  │           Phase 0 read findings.json (abort if missing/stale) ·
  │           Phase 4 digest + per-finding doc integration ·
  │           Phase 4b devil's-advocate review · Phase 4c structural review (EVERY run) ·
  │           Phase 5 release tier + changelog + commit + push origin HEAD:main
  │
  │    on failure, before retrying: if origin/main advanced past BASE_SHA → a prior
  │      attempt already published → STOP + notify (never double-commit)
  │
  ├─ (any exit) copy <wt>/.loop-news/findings.json → logs/ ; worktree remove ; branch -D
  └─ (on success, if origin/main advanced & primary is on main) primary: pull --ff-only
```

The worktree is created **once per run** (not per attempt) so `findings.json` persists
across attempts — that is what lets a B-only retry reuse A's search. Isolation between
attempts is provided by the hard reset to `origin/main` at the top of each attempt, which
discards any partial tracked edits while leaving the gitignored artifact intact.

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

The artifact is the **sole** handoff. Because A and B are **separate sessions**, B does
**not** inherit A's findings in context — it reads them from `findings.json`. This is the
point of the two-session design: B starts clean, and B can be re-run independently against
the copied-out `logs/findings-<date>.json` without re-scraping. The schema must therefore
be self-sufficient (everything B needs, including run metadata, lives in the file).

### How A hands off to B (two sessions)

A does **not** call B in-process. A's final Phase writes `.loop-news/findings.json` and
**stops**; the wrapper then launches B as a separate `claude -p "/integrate-loop-news"`
in the same worktree. B's Phase 0 reads the artifact. Both skills run in the same
worktree (satisfying "the two skills work in the same worktree"); the session boundary is
what gives B a clean context and independent retry.

This means **each skill is independently invocable and testable**: you can run
`/integrate-loop-news` by hand against a saved `findings.json` without re-scraping. A's
SKILL header states "hands off to `integrate-loop-news` via `.loop-news/findings.json`";
B's header states "consumes `.loop-news/findings.json` produced by `fetch-loop-news`" —
the artifact schema is the only contract between them.

### Worktree ownership — the wrapper owns the lifecycle

The **wrapper** (`run-loop-news.sh`), not the model, creates and tears down the worktree
and sequences the two sessions. **Skill B** does the semantic `git commit` (it owns the
release tier + message format) and the `git push origin HEAD:main`; the wrapper owns
worktree create/reset/teardown, the A→B sequencing, retry, and primary-checkout alignment.

Why wrapper-owned (vs. model-driven `EnterWorktree`/`git worktree` inside a skill):

- **Deterministic cleanup.** A crashed model can't orphan a worktree the shell created —
  the wrapper removes it in every exit path (`trap`).
- **It's the natural sequencer.** Two sessions must be launched by *something* outside
  both; the wrapper already owns run orchestration.
- **Isolation between attempts without losing the artifact.** The worktree is created
  **once per run**; at the top of each attempt the wrapper hard-resets the tree to the
  latest `origin/main` (discarding a failed attempt's partial tracked edits) while the
  gitignored `.loop-news/findings.json` survives — so a B-only retry reuses A's search.
- **The publish guard stays (adapted).** B's `git push origin HEAD:main` is a **durable
  external side effect** that outlives any tree reset. So:
  - **Success** = claude exit 0 **and** no transient-error marker → done, no retry.
    (A zero-finding day cuts tier = None and makes **no** commit, so `main` correctly does
    not advance yet the run succeeded — success is judged by exit code, not "did `main`
    advance.")
  - **Before retrying a failed attempt**, `git fetch origin main` and compare to
    `BASE_SHA`. If `origin/main` **advanced**, a prior attempt already published →
    **stop and notify, do not retry** (mirrors today's "failed AFTER committing — not
    retrying"). If it did **not** advance, nothing durable happened → reset the tree and
    retry (search is skipped if `findings.json` is still valid).
  - The same `BASE_SHA` compare, on the success path, decides whether the primary checkout
    needs a fast-forward.
- **Model logic stays about content**, not git plumbing.

Trade-off (unchanged): an **interactive** `/fetch-loop-news` typed by a human gets no
worktree and no B sequencing — they'd run A then B by hand. The daily automated path is
the one that matters for isolation; the skill headers note "for an isolated end-to-end run,
use `scripts/run-loop-news.sh`."

---

## Wrapper changes (`scripts/run-loop-news.sh`)

The wrapper creates **one worktree per run**, then runs **two claude sessions** (A then
B) inside it, resetting the tree between attempts. Sketch (integrates with the current
`set -uo pipefail`, `MAX_ATTEMPTS`, backoff, transient-error scan, `notify`; `run_claude`
generalises today's `run_attempt` to take a prompt and run it in `$WT_DIR` via a PTY, and
returns success = exit 0 **and** no transient-error marker):

**Path fix the worktree makes mandatory:** the current script sets
`LOG_FILE="logs/loop-news-….log"` (relative). Runs happen in the worktree, so a relative
`logs/` path would resolve *inside the disposable worktree* and be lost. Make `LOG_FILE`
an **absolute** path under `$REPO_ROOT/logs/`, and have the wrapper copy the artifact out
before teardown.

```bash
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$REPO_ROOT/logs"
LOG_FILE="$REPO_ROOT/logs/loop-news-$(date +%Y%m%d).log"   # ABSOLUTE — survives teardown

git -C "$REPO_ROOT" worktree prune                          # clear any orphan from a crash
git -C "$REPO_ROOT" fetch origin main
BASE_SHA="$(git -C "$REPO_ROOT" rev-parse origin/main)"     # captured ONCE, before any attempt

# --- ONE worktree for the whole run (so findings.json survives across attempts) ---
WT_PARENT="$(mktemp -d -t loop-news-wt.XXXXXX)"; WT_DIR="$WT_PARENT/wt"  # add needs a non-existent leaf
TEMP_BRANCH="loop-news-run-$(date -u +%Y%m%d-%H%M%S)"
cleanup() {
  [[ -f "$WT_DIR/.loop-news/findings.json" ]] && \
    cp "$WT_DIR/.loop-news/findings.json" "$REPO_ROOT/logs/findings-$(date +%Y%m%d).json" 2>/dev/null || true
  git -C "$REPO_ROOT" worktree remove --force "$WT_DIR" 2>/dev/null || rm -rf "$WT_PARENT"
  git -C "$REPO_ROOT" branch -D "$TEMP_BRANCH" 2>/dev/null || true
}
trap cleanup EXIT
git -C "$REPO_ROOT" worktree add -b "$TEMP_BRANCH" "$WT_DIR" origin/main

findings_valid() {   # exists AND its "today" matches the current UTC date
  local f="$WT_DIR/.loop-news/findings.json"
  # python3 (already relied on elsewhere) avoids a hard jq dependency:
  [[ -f "$f" ]] && [[ "$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1])).get("today",""))' "$f" 2>/dev/null)" == "$(date -u +%Y-%m-%d)" ]]
}

attempt=1
while (( attempt <= MAX_ATTEMPTS )); do
  # Isolate this attempt: discard a failed attempt's partial TRACKED edits; the gitignored
  # .loop-news/ (findings.json) is untracked+ignored, so reset/clean leave it intact.
  git -C "$WT_DIR" fetch origin main
  git -C "$WT_DIR" reset --hard origin/main
  git -C "$WT_DIR" clean -fd            # NOT -x → keeps ignored .loop-news/

  ok=1
  # STAGE A — search; skipped entirely if a valid artifact already exists (B-only retry)
  if ! findings_valid; then
    run_claude "$attempt-A" "/fetch-loop-news" || ok=0
    findings_valid || ok=0             # A must have produced a usable artifact
  fi
  # STAGE B — integrate + restructure + commit + push (only if A stage is good)
  if (( ok )); then
    run_claude "$attempt-B" "/integrate-loop-news" && break || ok=0
  fi

  # --- failure path: publish-safety guard before any retry ---
  git -C "$REPO_ROOT" fetch origin main
  if [[ "$(git -C "$REPO_ROOT" rev-parse origin/main)" != "$BASE_SHA" ]]; then
    notify "Attempt ${attempt} failed AFTER publishing (origin/main advanced) — not retrying."
    exit 1                              # B already pushed → never retry (would double-commit)
  fi
  (( attempt < MAX_ATTEMPTS )) && sleep "${BACKOFF_SECONDS[$((attempt-1))]}"
  (( attempt++ ))
done

# --- success path: align the primary checkout if B published and it's on main ---
git -C "$REPO_ROOT" fetch origin main
if [[ "$(git -C "$REPO_ROOT" rev-parse origin/main)" != "$BASE_SHA" ]] && \
   [[ "$(git -C "$REPO_ROOT" symbolic-ref --quiet --short HEAD)" == "main" ]]; then
  git -C "$REPO_ROOT" pull --ff-only origin main
fi
```

Notes on the two `claude` invocations (both run in `$WT_DIR`):
- **`--allowedTools`** — A needs `Read,Edit,Write,WebFetch,mcp__claude-in-chrome__*`
  (Write for the artifact; A no longer needs git or Skill). B needs
  `Read,Edit,Write,WebFetch,Bash(git *)` (commit+push; no Chrome). Note: under
  `--permission-mode auto` the **auto classifier**, not `--allowedTools`, is the real gate
  — today's skill already runs `git add/commit/push` with no `Bash`/`git` in its allowlist
  — so these lists are a defensive fast-path, confirmed in Step 8, not a hard requirement.
- **`--max-turns`** — now measured **per stage**, not for a combined run. Search and
  integrate each get the full budget; start both at 40 and adjust from Step 8 measurements.
- **Optional `--model` per stage** — the two-session split *enables* running Search on a
  cheaper/faster model, but only after validating it doesn't degrade finding quality
  (relevance tiering / link curation are judgment calls). **Not in the initial build** —
  both stages stay on the default model; model-per-stage is a later tuning lever.
- **Retry guard** is adapted, not removed: the dirty-tree half becomes the per-attempt
  `reset --hard` + `clean`; the already-published half becomes the `origin/main`-advanced
  check (B's push is durable and survives the reset, so retrying after a push would
  double-commit).

`.gitignore`: add `.loop-news/` so the artifact is never committed. (`logs/` is already
ignored.)

---

## Files

| File | Action |
|---|---|
| `.claude/skills/fetch-loop-news/SKILL.md` | **Rewrite** → Search only (Phases 1–3); final phase writes `.loop-news/findings.json` and **stops** (no in-skill call to B). Update `description:` frontmatter. |
| `.claude/skills/integrate-loop-news/SKILL.md` | **Create** → Integrate & Restructure (Phases 4/4b/4c/5); Phase 0 reads the artifact. |
| `scripts/run-loop-news.sh` | **Edit** → one worktree/run + reset-between-attempts, sequence two sessions (A then B), per-stage `--allowedTools`, granular retry + publish guard. |
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
      (schema above) and **stop** — A does not call B (the wrapper launches B next). Update
      `description:` to "search only," and add a header line: "hands off to
      `integrate-loop-news` via `.loop-news/findings.json`." Move the JSON-array per-subagent
      return spec into A; keep the keyword-tier rubric in A.
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
- [ ] **Step 3 — Wrapper.** Make `LOG_FILE` absolute; create **one worktree per run**
      (trap-cleanup copies the artifact out to `logs/` then removes the worktree + temp
      branch); generalise `run_attempt`→`run_claude <label> <prompt>` (PTY + transient scan);
      loop attempts with a `reset --hard origin/main` + `clean -fd` at the top of each;
      **Stage A** runs `/fetch-loop-news` only when `findings_valid` is false (granular retry
      skips search), **Stage B** runs `/integrate-loop-news`; per-stage `--allowedTools`;
      publish guard on failure (refuse to retry once `origin/main` advanced past `BASE_SHA`);
      fast-forward the primary checkout on success only if `origin/main` advanced and the
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
      Verify: worktree created off `origin/main`; **Session A** wrote a valid `findings.json`
      and exited; **Session B** (fresh context) consumed it, integrated, committed, pushed to
      `main`; artifact copied to `logs/`; worktree + temp branch removed; primary checkout
      fast-forwarded. Measure per-stage turns/cost (adjust each `--max-turns` if near cap).
- [ ] **Step 9 — Failure-path checks.** (a) Kill during **A** → worktree intact for next
      attempt, `main` untouched, attempt 2 re-runs A. (b) Make **B** fail before pushing →
      attempt 2 resets the tree, `findings_valid` is true so **search is skipped** and only B
      re-runs (granular retry). (c) Simulate B failing *after* pushing (advance `origin/main`)
      → wrapper refuses to retry and notifies (no double-commit).
- [ ] **Step 10 — PR.** Open `feature/split-loop-news-skill` → `main`; after merge, tag
      + GitHub release; re-align local checkout.

---

## Risks & mitigations

| Risk | Mitigation |
|---|---|
| A stage exceeds `--max-turns` (search is broad) | Per-stage budget now — A gets its own 40; measure in Step 8; `--max-budget-usd` still bounds cost |
| B stage exceeds `--max-turns` (integrate + full 4c every run) | Per-stage budget — B gets its own 40; if the every-run 4c pushes B near the cap, raise B's cap specifically |
| `reset --hard` / `clean -fd` between attempts destroys `findings.json` | It won't: `.loop-news/` is gitignored and untracked, so `reset --hard` (tracked only) and `clean -fd` (no `-x` → skips ignored) both leave it intact — verified in Step 9(b) |
| `git push origin HEAD:main` rejected because `main` advanced during the run | Single daily machine; wrapper fetches `origin/main` before the run. If rejected, B fails loudly; the publish guard then sees `origin/main` advanced only if a *prior attempt* pushed, else the reset+retry re-bases on the new tip |
| Worktree left orphaned on crash | `trap cleanup EXIT` removes it in every path; `git worktree prune` at start |
| Zero-finding day misread as failure → retry loop | Success is the exit-code + transient-scan signal; a zero-finding day makes no commit and that is a success, not a failure |
| B pushes to `main`, then fails late → retry double-commits the day's digest | Publish guard: on failure, `git fetch origin main`; if `origin/main` advanced past `BASE_SHA`, stop + notify, never retry (Step 9c) |
| Findings artifact accidentally committed | `.loop-news/` gitignored; B stages only the explicit KB file list (incl. `mkdocs.yml`), never `git add -A` |
| Interactive `/fetch-loop-news` runs without isolation | Documented: for an isolated end-to-end run use the wrapper; interactive A then B is a manual dev path |
| B runs with an empty/stale artifact (A failed silently) | Two guards: the wrapper's `findings_valid` gate won't launch B unless the artifact exists with today's date; B's Phase 0 re-checks and aborts with a clear error otherwise |
| `python3`/`jq` unavailable for `findings_valid` | Sketch uses `python3` (already relied on for other repo tasks); if absent, B's own Phase-0 validation is the backstop |
| Two SKILL.md files drift out of sync (shared conventions) | Keep the artifact schema as the single contract; cross-link the two SKILL headers ("A produces / B consumes `.loop-news/findings.json`") |

---

## Decisions log (settled) & remaining open items

**Settled by the user (2026-07-03):**

1. **Worktree ownership → wrapper-owned.** ✅ Deterministic cleanup; the wrapper is the
   natural sequencer of the two sessions.
2. **A→B mechanism → Option 2 (two wrapper-sequenced sessions).** ✅ Chosen for context
   isolation + granular B-only retry, accepting that the wrapper (not an in-skill call)
   mechanizes the handoff. The whole plan is now written to this shape.
5. **Phase 4c cadence → every run.** ✅ The documented norm kept; not relaxed.

**Still open (low-stakes; safe to settle at implementation time):**

3. **Skill B name.** *Recommended: `integrate-loop-news`* (captures merge + restructure).
   Alternatives: `restructure-kb`, `merge-loop-news`.
4. **Keep A named `fetch-loop-news`?** *Recommended: yes* — it's the entry point the
   wrapper, plist, and docs reference; renaming ripples through all of them for no
   functional gain. "fetch" still fairly describes the search half.

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
  Also corrected an overstated context-isolation claim: Phase 2 scraping already runs in
  subagents, so the main session never accumulates raw pages — the boundary's real value is
  turn-budget + granular retry, not raw-context savings.
- **v6 (2026-07-03, user decisions settled)** — User chose **Option 2 (two sessions) +
  every-run 4c**. Reconciled the entire plan to that shape: two wrapper-sequenced `claude -p`
  sessions (A → B) in **one worktree per run** with `reset --hard`+`clean` between attempts
  (findings.json survives as it's gitignored); **granular retry** skips search when a valid
  artifact exists; A writes the artifact and stops (no in-skill call); per-stage
  `--allowedTools`/`--max-turns`; model-per-stage deferred; publish-safety guard retained.
  Architecture diagram, handoff, worktree-ownership, wrapper sketch, risks, steps, and the
  decisions log all updated; the single-session Skill-tool references are gone.
