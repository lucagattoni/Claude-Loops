# Open-Work Backlog — everything still to do after v3.0.0

**Written** 20260904 20:53 UTC · base `4ed29ff` (clean, synced, CI green)
**Supersedes as the entry point:** [`20260904_2002-v3-fact-check-gaps.md`](20260904_2002-v3-fact-check-gaps.md)
— that file is still the *method* reference for the fact-check work (item **C1**); this file is the
full backlog and the order to work it in.

**One line:** the repo is clean, released and green — but the tracker it exists to run has not
fired since **8 July**, and two live handover documents state it was "re-armed" when it never ran.

Every item below was verified against the tree at `4ed29ff`. Where a handover document and the tree
disagree, **the tree won** — see §6 for the list of claims those documents get wrong.

---

## 1. How to use this file

- Items are `A#` (automation), `C#` (content), `H#` (hygiene). The prefix is stable; the order
  inside a tier is not.
- **§2 first** — three decisions are yours and two of them block items.
- Work top-down within a tier. §8 is the recommended order across tiers.
- Every commit passes the standing gates in §9.
- Tick items here as they land, and **delete this file's pointer from `CLAUDE.md` when §3 and §4
  are empty.** Add a "Shipped in vX.Y.Z" note rather than silently deleting a row.

---

## 2. Decisions — RESOLVED 20260905

All three were taken by the user on 20260905 and are implemented in the same commit as this note.
Kept here because the *reasoning* is what a later agent needs, not just the outcome.

| # | Decision | Where it now lives |
|---|---|---|
| **D1** | **UTC everywhere**, `YYYYMMDD HH:MM`, read from the clock. Existing local-time entries stay as written. | `CLAUDE.md` "Every timestamp is UTC"; `integrate-loop-news/SKILL.md:300` |
| **D2** | **Pipeline-cut versions are released by a human follow-up.** `gh release` rights are not granted to the unattended agent on a public repo. The 53-tags-vs-38-releases gap is visible and accepted; backfill by hand. | `CLAUDE.md` "Releases" |
| **D3** | **Retire plans in place** with a `Shipped as vX.Y.Z` header. No archive directory — moving files breaks inbound links, and the filename prefix already sorts chronologically. | `CLAUDE.md` "Plans"; applied to both delivered plans |

**H10 and H13 are now unblocked** (they were waiting on D2 and D3 respectively). **C4**'s changelog
half is done; its zero-finding-commit contradiction is still open.

### The original framing, for reference

## 2b. Decisions as originally posed

| # | Decision | Options | Blocks |
|---|---|---|---|
| **D1** | **Changelog timestamp format.** Project `CLAUDE.md:41` says hand-authored stamps use *local* time. Global `~/.claude/CLAUDE.md` says **every** timestamp is UTC (adopted 20260804). `integrate-loop-news/SKILL.md:300` emits `<date> <TZ>`. `CHANGELOG.md` now holds three formats at once — `20260904 19:12` (`:21`) directly above `2026-07-09 08:19 IST` (`:124`). | (a) UTC everywhere — rewrite `CLAUDE.md:41` and `SKILL.md:300`, leave existing entries as written; (b) keep local for hand-authored, fix only the skill to be internally consistent | **C4** |
| **D2** | **Who cuts releases for pipeline versions.** `CLAUDE.md:34` demands tag + GitHub release "in the same turn — never defer", but the pipeline structurally cannot: `gh` is not in its allowlist. 53 tags vs 38 releases. | (a) add a Phase 5d to the skill (tag, push tags, `gh release create`) plus `Bash(gh release *)` in `B_ARGS`; (b) amend `CLAUDE.md:34` to say pipeline-cut versions are released by a named human follow-up. Backfill the 15 missing releases either way | **H10** |
| **D3** | **Plan retirement policy.** `plans/` has no lifecycle rule, which already produced a live document reporting 0/10 steps on work shipped in July. | (a) `plans/archive/` + move on verified completion; (b) a "Shipped as vX.Y.Z" header stamp in place | **H13** |

---

## 3. Tier 1 — automation that fails silently

This tier is why the KB has an eight-week hole. Do it before any content work.

### A1 — ~~No `mkdocs build --strict` gate before the pipeline pushes to `main`~~ · **SHIPPED v3.0.1**

**Done 20260905, PR #21.** Phase 5c added; 5-lens adversarial review + Opus judge before merge.
On its first-ever execution it caught and fixed **3 broken anchor links** before they reached a
commit — the exact defect class that failed CI on 07-06 and 07-07. Residual risk, unchanged: the
gate is prose an agent can skip, and `--strict` is structural only (it passes malformed digest
tables and dead external citations). Original analysis below.

The pipeline commits straight to `main` with no build gate, and has **already broken the published
site twice**.

- **Evidence:** pipeline pushes `198c302` (2026-07-06) and `9069f28` (2026-07-07) both failed CI on
  the `mkdocs build --strict` step. `deploy` needs `build` (`.github/workflows/docs.yml:40-41`), so
  neither day deployed — `main` moved, the site did not. `grep -rn "strict" .claude/skills/` returns
  nothing. `integrate-loop-news/SKILL.md:308-314` goes `git add` → `git commit` → `git push origin HEAD:main`.
- **Do:** add a pre-commit step to Phase 5 running
  `uv run --with-requirements requirements-docs.txt mkdocs build --strict`
  **bare** — exit status read directly, never piped into `tail` (see §9) — aborting the push on
  non-zero. Add `Bash(uv *)` to `B_ARGS` (`scripts/run-loop-news.sh:192`).
- **Also:** both incidents were a `../KB_GAPS.md`-style link the pipeline itself wrote. Add a rule
  to the skill: links from `docs/` to a repo-root file use the absolute URL, never `../`.
- **Gate:** deliberately introduce a broken link, confirm the new step aborts, revert.

### A2 — ~~The tracker has never been validated by a real run~~ · **SHIPPED v3.0.1**

**Done 20260905.** Attended run: commit `904c127`, 101 findings, build **and** deploy jobs green,
live site serving the new digest. Verified by artifact, not exit status. One earlier attempt died
when Stage B hit the account session limit — worth knowing that an *attended* run competes with the
attending session for one quota. Original analysis below.

- **Evidence:** `launchctl print gui/501/com.luca.loop-news` → `runs = 0`,
  `last exit code = (never exited)`, job enabled. Newest run log is `logs/loop-news-20260720.log`.
  `scripts/com.luca.loop-news.plist` has exactly one commit ever (`570ce26`, 2026-06-26) and the
  installed copy is byte-identical, so the re-copy the plan prescribes never ran.
  This is Step 10 of `20260904_1658-two-pillar-restructure.md:185`.
- **Do (after A1 lands):** `launchctl kickstart -k gui/$(id -u)/com.luca.loop-news`, then confirm
  **three** things:
  1. a commit lands on `main`,
  2. `logs/loop-news-<today>.log` exists,
  3. **`logs/launchd.log` gains a new entry** — this is the one that settles U2.
- **Open question it resolves:** see **U2** in §7.

### A3 — ~~Failure signalling is desktop-only; no off-machine staleness watchdog~~ · **SHIPPED v3.1.0**

**Done 20260905, PR #27.** `scripts/check-digest-freshness.sh` + a daily Actions job, 48h threshold. Six mutants killed on exit status; fired live in CI. Original analysis below.

This is the mechanism that turned one bad day into eight silent weeks.

- **Evidence:** `notify()` (`scripts/run-loop-news.sh:124-130`) is `osascript` plus a `tee` into
  `logs/`, which `.gitignore:1` ignores. No `curl`/`webhook`/`slack`/`mail`/`http` anywhere in the
  script. `.github/workflows/docs.yml` is the only workflow and has no `schedule:` trigger. The
  per-source freshness rule only runs when the pipeline runs — it cannot detect that the pipeline
  stopped.
- **Do:** add a scheduled GitHub Action that fails (or opens an issue) when the newest
  `## YYYY-MM-DD` header in `LOOP_ENGINEERING_NEWS.md` is more than 48h old. A same-machine
  watchdog shares the failure domain with the outage it would detect, so this one must be remote.
  Separately, add a durable channel to `notify()` alongside `osascript`.

### A4 — ~~CI path filter cannot see the root files the site publishes~~ · **SHIPPED v3.1.0**

**Done 20260905, PR #26.** Not yet observed firing on a root-file-only push — that happens on the next findings-only day. Original analysis below.

- **Evidence:** `docs/news.md`, `docs/sources.md`, `docs/changelog.md` are **symlinks** to the root
  files and are nav entries. Editing the root file leaves the symlink blob unchanged, so a
  findings-only day matches none of the trigger paths in `.github/workflows/docs.yml:8-12, 14-18`.
  `integrate-loop-news/SKILL.md:292` classifies findings-only days as PATCH and `:311` always stages
  exactly those root files. Unrealised so far only because every pipeline push also happened to
  touch `docs/`.
- **Do:** add `LOOP_ENGINEERING_NEWS.md`, `SOURCES.md`, `CHANGELOG.md` to both `paths:` lists.

### A5 — ~~`integrate-loop-news` never updates `docs/index.md`~~ · **SHIPPED v3.1.0**

**Done 20260905, PR #26.** Both indexes now named at the doc-creation step and in the Phase 4b review. Original analysis below.

- **Evidence:** `grep -rn "index.md" .claude/skills/ scripts/` → no matches. `mkdocs.yml:103` sets
  `Home: index.md`; `mkdocs.yml:14` says `LOOP_ENGINEERING.md` is deliberately not published. Both
  indexes currently agree on all 39 docs, so the drift begins with the next new doc — and
  `--strict` cannot catch a missing row.
- **Do:** name `docs/index.md` beside `LOOP_ENGINEERING.md` at `SKILL.md:75-79`, `:203-207`,
  `:257-259`; add a `docs/index.md` row to the repository map in `CLAUDE.md`.

### A6 — ~~Two deterministic failure modes still get generic retry treatment~~ · **SHIPPED v3.1.0**

**Done 20260905, PR #26.** Credit-balance now exit 5 on attempt 1 (was: 3 attempts, 2 backoffs, ~2 min); `ANTHROPIC_API_KEY` preflight warns rather than unsetting. Original analysis below.

- **Evidence:** `ERROR_REGEX` (`scripts/run-loop-news.sh:107`) omits `Credit balance is too low`
  even though it was hit in production and is unretryable — it burns ~2h of backoff, then emits a
  generic "re-run manually". `BUDGET_EXCEEDED_REGEX` (`:113`) and `SESSION_LIMIT_REGEX` (`:121`)
  each got a dedicated no-retry branch after being hit; this one did not.
  `grep -i ANTHROPIC_API_KEY` across `scripts/` and both skills → **zero matches**: the shadowing
  key that caused 2026-07-20 was diagnosed in prose (`20260904_1658-two-pillar-restructure.md:198`)
  and never guarded in code.
- **Do:** add a `CREDIT_BALANCE_REGEX` no-retry branch with its own `notify()` text; add
  `unset ANTHROPIC_API_KEY` (or detect-and-warn) near the top of the script, before `A_ARGS`/`B_ARGS`.

### A7 — ~~`CLAUDE_BIN` points at a path that does not exist~~ · **SHIPPED v3.0.1**

**Done 20260905, PR #22.** Resolver + fatal preflight (exit 3), verified by a five-case behaviour
matrix under `env -i`. This was the whole outage. Original analysis below.

**The tracker cannot succeed today even if launchd fires.** Found 20260904 by applying a peer
report from the ClaudeWarp session as a hypothesis about this repo rather than reading it as a
war story.

- **Evidence:** `scripts/run-loop-news.sh:54` is
  `CLAUDE_BIN="${CLAUDE_BIN:-/opt/homebrew/bin/claude}"` — a hardcoded absolute path.
  `ls /opt/homebrew/bin/claude` → **No such file or directory**. The binary is at
  `/Users/luca/.local/bin/claude` (native installer; symlink → `~/.local/share/claude/versions/2.1.261`).
  There is no `scripts/run-loop-news.env`, so the default applies, and
  `run-loop-news.env.example` never mentions `CLAUDE_BIN` — so nothing tells an operator to set it.
- **What happens:** `run_claude()` (`:171`) invokes the missing binary → exit **127**. 127 does not
  match `ERROR_REGEX`, so it is classed non-transient; the script still burns all three attempts
  with backoff, then `notify()`s to a desktop notification and a gitignored log. Silent failure,
  the same shape as **A3**.
- **Do:** replace the hardcoded default with a resolver — honour `CLAUDE_BIN`, else `command -v
  claude`, else a short list of known locations (`~/.local/bin`, `/opt/homebrew/bin`) — and
  **preflight it**: if it does not resolve to an executable, abort with a named FATAL before the
  attempt loop, rather than discovering it three attempts later.
- **Gate:** run under `env -i` with the launchd PATH and confirm the preflight fires; then confirm
  a resolved binary passes.

**This partially answers U2.** The script writes its "Starting loop-news run" line (`:194`) *before*
the first `claude` call, so a fired-but-broken run would still leave a dated log in `logs/`. There
is none after 2026-07-20. So launchd genuinely is not firing **and** the binary path is broken —
**two independent faults**, either of which alone produces the same eight weeks of silence. Fixing
one and declaring victory is the trap here.

**Class note for `docs/17` and H5:** this is the same defect class the peer hit twice
(`claude` not on the scheduler's PATH; `timeout` absent on stock macOS, wrapping every call). Ours
is one level worse — not a PATH assumption but a hardcoded absolute path that silently became
wrong when the binary moved. Checked and **not applicable** here: `grep -n timeout
scripts/run-loop-news.sh` returns nothing, so the `timeout`/`gtimeout` defect does not affect us
(neither binary exists on this machine, confirmed).

### A8, A9 — ~~two more failures the wrapper reported as success~~ · **SHIPPED v3.0.1**

**Found and done 20260905, PR #24**, after the backlog was written. Both are the same class as A3:
a check whose default outcome means success.

- **A9** — `claude -p "/no-such-skill"` prints `Unknown command` and **exits 0** (verified on
  v2.1.261). Stage A was already protected by `findings_valid()`'s artifact check; **Stage B was
  not** — reproduced pre-fix as `Run complete (succeeded on attempt 1)`, exit 0, nothing published.
  Now a no-retry branch, exit 4.
- **A8** — `grep -q "loop news run"` on commit subjects also matched `Revert "feat: loop news
  run …"` and any human commit mentioning the phrase, which would abandon a retriable failure. Now
  anchored on `^feat: loop news run `.

Both proven with pre-fix controls. Noted because the first A9 test was itself broken — no TTY, so
`script -q` died and the stub never ran; it passed for the wrong reason.

### A10, A11, A12 — ~~neither stage could resume from where it died~~ · **SHIPPED v3.1.0**

**Found and done 20260905** at the user's direction, after A2's first attempt lost Stage B to the
account session limit and the re-run paid for the 23-minute search a second time. PRs #29, #30, #31.

- **A10** — a *completed* Stage A is reused instead of re-run. The artifact was already saved to
  `logs/` on every run and never read back.
- **A11** — an *interrupted* Stage A resumes per source (`complete` flag + `sources_done[]`). This
  also fixed a regression A10 itself shipped: validation required a non-empty findings array, so a
  legitimately quiet day would have re-run the whole search three times.
- **A12** — Stage B checkpoints as commits on a stable per-day branch. Git is the ledger
  deliberately: an agent-maintained progress file would be advisory prose, the same weakness the A1
  review found in the build gate.

**Standing requirement set by the user 20260905:** *each stage must be resumable at any point,
because it can die at any point.* Applies to anything expensive added to this pipeline later.

---

## 4. Tier 2 — content correctness

### C1 — Fact-check the 14 never-touched docs · **PARTIALLY SHIPPED 20260905, PR #37** · large

**What landed.** 341 checkable claims examined across all 14 docs; **49 fixes applied**, one commit
per doc, plus four cross-doc extensions the per-doc agents could not see. Method: one Sonnet finder
per doc → two independent Sonnet refuters per finding (over-correction lens and source-fidelity
lens) → one Opus adjudication over the collected set → one Opus completeness critic. 134 agents,
8.6M tokens. Of 59 raw findings: 29 survived both lenses, 24 contested, 6 refuted. The adjudicator
merged conflicting fixes, **rejected 10** — including framings inside findings that had survived
both lenses — and **rescued one** from the refuted pile.

**This item is NOT closed.** The completeness critic's verdict, verbatim:

> *"INCOMPLETE — the pass cannot be treated as having covered its 14 docs."*

Three structural defects in the pass itself, all real:

1. **Two finders read pre-commit copies of their file.** `c6e5a66` landed +119 lines into `docs/03`
   and +149 into `docs/29` while the run was in flight, so **268 lines of the KB's newest and most
   version-sensitive content were never examined** — while being reported as covered.
2. **78 of the 98 unique URLs cited across the 14 docs were never opened**, concentrated in the two
   docs the handover plan named highest-priority.
3. **Claim density ran inverted against priority**: `docs/27` got 0.052 claims/line and `docs/04`
   0.082, against 0.31 for `docs/31` and 0.32 for `docs/22`.

**The dominant risk in what did land**, from the adjudicator's own risk note: *a failed or partial
fetch reported as an absence*. An unauthenticated GitHub code search returned 401 and was read as
"0 hits"; an SSR-truncated X thread was read as "phrase not found". Every fix whose evidence is
absence could be wrong the same way. The two fixes that actually **remove** content were therefore
re-verified by hand before landing, both with authenticated calls:

- `docs/04`'s `~6%` figure — the source retracted it as fabricated (`e6ecf262`,
  *"drop fabricated critic stat"*, 2026-07-04; the removal diff is in `c37b246`). **Correction to
  the adjudicator:** it attributed `e6ecf262`'s commit message to `c37b246`. Substance confirmed,
  provenance was wrong.
- `docs/10`'s session-orchestrator paragraph — `acting_on` and `check-file-lock.sh` both return
  zero via authenticated search, and the two replacement paths
  (`scripts/lib/session-lock.mjs`, `scripts/lib/locks/state-md-lock.mjs`) were confirmed to exist
  before being written in.

**Settled by running rather than logged** — both were live-verified and fixed in this PR:
`--max-turns` is **silently inert on `--bg`** (falsifying a claim `v3.1.1` shipped hours earlier),
and `claude mcp add` has no interactive form. Six residual uncertainties are in `KB_GAPS.md`
§ *Claims Awaiting Verification* as **V7–V12**.

### C1b — Close the coverage the C1 pass did not reach · **P0s SHIPPED 20260906, PR #40** · large

**The three P0s are closed.** A section-scoped second round over `docs/03`, `04`, `27`, `29`:
**476 claims checked, 424 correct, 49 findings, 46 fixes applied, and 90 of 90 cited URLs opened.**
Four docs yielded more checked claims than all fourteen did in round 1 — the inverted claim density
is fixed (round 1 managed 0.052–0.082 claims/line on `04`/`27`).

- **P0-1 (268 unexamined lines)** — closed. `docs/03`/`docs/29` re-checked at HEAD, scoped to the
  `c6e5a66` + `b1f7ed7` diffs the earlier finders never saw.
- **P0-2 (78 unopened URLs)** — closed. The critic had already swept all 98 itself (2 known 404s);
  this round opened 90 more inside the four docs, with **authenticated** `gh api` and a
  `default_branch` lookup before any raw fetch, which is what makes "not found" mean something.
- **P0-3 (inverted claim density)** — closed for `04` and `27` by splitting them into section groups.

**What the round caught, and what it says about round 1.** A second fabricated blockquote in
`docs/04` (authenticated code search: **zero** hits for its key word); fabricated implementation
detail (`SCOPE.md`, a "test/check index") absent from the cited repo; an unattributed verbatim
quote the KB cites correctly in two *other* files; and — in this project's own week-old work —
`claude --bg --worktree "<task>"`, which **cannot run**: `--worktree [name]` eats the task string
as the worktree name. Reproduced: `state: failed`, *"Invalid worktree name"*.

**The risk note's date-check was run and came back clean.** Three high-severity `docs/04` rewrites
rested on one agent reading `eugenelim/agent-ready-repo` on one day. Pulled that repo as of the
KB's own 2026-06-26 capture: RFC-0051 existed then and has since grown 389→612 lines, **but
`SCOPE.md`, `Stop hook`, `test` and `verification artifact` have zero hits in *both* versions**,
and `pre-commit` has zero hits in both copies of the traceability-lint spec. The claims were never
supported. Contrast `V13`: a zeroshot quote the KB got *right* in July, which the source later
deleted — a finder called it fabricated and a refuter cleared it by pulling the capture-date commit.
**"Contradicted by the source" must mean contradicted as of the capture date.**

**Still open — the critic's P1 and P2 items**, unchanged and listed below: `docs/23`'s falsified
claim-of-absence, the `docs/04`/`docs/23` implementer-reviewer ratio, `docs/27`'s uncited Uber
figures, the repo-wide blockquote audit (344 lines + 66 inline spans), and `docs/11`'s model IDs
and pricing — **the KB's most volatile class, still never swept anywhere**.

### C1b — the remaining P1/P2 gaps · **SHIPPED 20260906 as `v3.1.8`**

Produced by the C1 completeness critic (Opus), which had the whole fan-out's output in front of it.
Ordered by its own priority.

**All P1 and P2 items are now closed.** What each one turned out to be:

| Gap | Outcome |
|---|---|
| `docs/11` model IDs + pricing (P2, the largest untouched risk) | **Swept, ~60 claims.** All 30 pricing figures, 4 model IDs, context windows, cutoffs and positioning quotes matched the live pages exactly. 4 precision fixes, no fabrications |
| `docs/23` falsified claim-of-absence (P1) | **Confirmed and rewritten.** Bun publishes the figure: 5.9B / 690M / 72B tokens, ~$165,000. Scope stated (whole port, not one 64-instance wave). Model attribution added and arithmetic-corroborated |
| `docs/04`/`docs/23` implementer-reviewer ratio (P1) | **Confirmed and fixed** to 1:2+, with role separation, matching `docs/23:237` |
| `docs/27` uncited Uber figures (P1) | **Source found; the fix was bigger than a link.** The cap is *per person* per tool, covers two tools, and the source itself sources it to "reporting in the discourse". Heading renamed, provenance stated, `V17` logged |
| Repo-wide blockquote audit (P1) | **Done — 414 lines / 113 blocks, plus 224 inline spans.** 2 defects: a mid-sentence truncation in `docs/24`, an em-dash splice of two sentences in `docs/07` |
| H1 version stamps, `docs/03`/`docs/29` (P1) | **Re-answered from HEAD.** `docs/29` correctly needs none (per-claim inline markers already). `docs/03` gained 4 earned stamps at 2.1.263 |
| `docs/04` 93.4% paragraph (P2) | **Re-read whole and reworded** to "largely non-overlapping". `V16` settled — the ~85–90% figure is verbatim in its source |
| `main`-vs-`master` method rule (P2) | **Written into `CLAUDE.md`**, with three counterexamples this pass actually hit |
| Four verified-clean classes (P2) | Already recorded below; not re-spent |

**Two corrections to this backlog, from doing the work:**

1. The blockquote item said `docs/04:257-260` rests on a dead source. Those lines cite
   [firegnu/herdr-loop-lab](https://github.com/firegnu/herdr-loop-lab), which is **live** and
   carries its quoted strings (22 code-search hits). The line reference had drifted; the real
   dead-source quotes are `docs/04:281` and `docs/07:73`/`:76`.
2. The `docs/11` item predicted the KB's most volatile class would be its most defective. It was
   its *cleanest* — every price and ID was right. The defects were one surface-conflation
   (Claude Code's effort default vs. the API's), one miscited figure, and two omissions.

**Method findings worth carrying forward** (both now in `CLAUDE.md`):

- **`v2.1.243` has a git tag and a `CHANGELOG.md` entry but no GitHub Release** (releases jump
  241 → 245). Its `/releases/tag/` URL still serves 200. Checking Claude Code quotes via the
  releases API would have manufactured four false "fabricated quote" findings — the `V13` shape.
- **A README-only fetch is not a search.** `harness-books`' quoted sentence lives in a chapter
  file with zero README hits; authenticated `gh api search/code` found it in one call.

| Pri | Gap | Next action |
|---|---|---|
| **P0** | Two finders read PRE-COMMIT copies of their file. Commit c6e5a66 ("Content: close C6, C13 and C14", 2026-09-05 18:03) landed +119 lines into docs/03 and +149 into docs/29 mid-pass. `git show c6e5a66~1` proves docs/03 was 151 lines / 0 version markers and docs/29 was 145 lines / 0 markers at read time; they are now 270/5 and 286/6. This explains every anomaly in the report at once: the docs/29 find | Re-run docs/03 and docs/29 against current HEAD, scoped to the c6e5a66 diff (`git show c6e5a66 -- docs/03-building-blocks.md docs/29-background-agents.md`), independently of plans/20260905_1349-c6-c13-evidence.md so it is a check and not a re-read. Re-answer H1 for both from the current file. Before |
| **P0** | 78 of the 98 unique URLs cited across the 14 docs were never opened (33 third-party GitHub repos, 34 articles/blogs/X posts, 11 arXiv — I have now cleared the arXiv ones myself). The gap is concentrated in the two top-priority docs. docs/04's largest section, "Verifier Integrity: Keeping the Check Unfakeable" (lines 226-398, 172 lines), rests on 8 repos of which ZERO were opened: uppifyagency/loop | Run a second fan-out keyed to SOURCES, not to docs: one Sonnet agent per unopened repo/article, tasked with verifying every KB sentence attributed to it (grep the repo name across docs/ first, since most are cited in 2+ files). Start with the 16 repos anchoring docs/04:226-398 and docs/27:387-458. R |
| **P0** | Claim density ran inverted against the handover plan's own priority ranking. The plan named docs/04 ("the KB's own non-negotiable foundation, highest-value doc in Part I") and docs/27 ("the KB's stated design spine") as the top tier. They received the LOWEST coverage of the 14: docs/27 = 24 claims / 463 lines = 0.052 per line; docs/04 = 52 / 636 = 0.082. Against that, docs/31 got 0.31 (20/65) and  | Re-scope docs/04 and docs/27 as multi-agent targets rather than one-agent-per-doc: split docs/04 by its 23 H2 sections and docs/27 by its 18, and require a minimum claim count proportional to section length. Treat any future finder reporting fewer than ~0.15 claims/line on a claim-dense doc as a fai |
| **P1** | A falsified claim-of-absence — the repo's own defining defect class — sits in docs/23:272-273, reached directly from a docs/04 cross-reference and built on the same source the pass had open. The KB says: "Token cost at this concurrency is unmeasured for the Bun port itself... Neither Bun's post nor Anthropic's names a token or dollar figure for the 64-instance run." I fetched bun.com/blog/bun-in-r | Rewrite docs/23:272-280 around the real figures ($165,000 at API pricing; 5.9B uncached input / 690M output / 72B cached-read tokens) and keep the HN datapoint only as a note on per-seat plan economics, not as evidence of an unmeasured cost. Add docs/23 and docs/26 to the fact-check set — both carry |
| **P1** | Same claim in two docs, only one checked — and the pass checked the wrong one. docs/04:388-390 (reviewed) says "one Claude Code instance implemented while a separate instance — with no visibility into the implementer's reasoning — was charged with a single mandate." The Bun post says "1 implementer, 2 or more adversarial reviewers per implementer" and "Every line of code was reviewed by two separa | Fix docs/04:388-390 to the 1-implementer/2-reviewer ratio, matching docs/23:237. Then add a generic step to the fact-check method: for every finding, grep the source name across all of docs/ and reconcile every doc that cites it, rather than fixing only the file the agent was assigned. |
| **P1** | An uncited, named-company financial claim survives in the KB's spine doc. docs/27:48-50: "Uber engineers burned their entire annual AI budget in 4 months before a $1,500/month per-tool cap was imposed" — under an H2 literally titled "Real Cost Data", with no link of any kind. This violates the repo's own committed rule ("Citations must link. Every external reference in docs/*.md must be a markdown | Fetch the explainx.ai article named at docs/news.md:1422, confirm the Uber figures verbatim, and either cite it inline at docs/27:48 or cut the paragraph. Then run `grep -rnE '\*\*[^*]*(budget|\\$[0-9]|[0-9]+%)[^*]*\*\*' docs/*.md` and check every bolded statistic for an adjacent citation — this is  |
| **P1** | Quoted third-party material was the pass's highest-yield class and was barely sampled. It found 3 defects (Karpathy composite splice at docs/31:40, miltonheyan sentence truncated at an altered clause boundary at docs/02:48, Van Horn line rendered as a Cherny quote at docs/20:54) and every one was confirmed. Unsampled: 344 blockquote lines KB-wide, plus 66 inline quoted spans of 25+ characters insi | Run the repo-wide blockquote audit the pass recommended but sized at 344 lines + 66 inline spans, one Sonnet agent per source. Prioritise the six named quotes above. For docs/04:257-260 specifically, decide now whether verbatim quotes may stand on a dead source at all — that is a policy question the |
| **P1** | The H1 version-stamp question was answered per doc, but two of the fourteen answers are factually false about the doc's own contents, and both are false for the same reason as gap 1. docs/03's verdict says "Zero v2.1.x (or any) version markers anywhere in this doc" — it now has 5 (v2.1.233 at line 60, v2.1.212 at 144, v2.1.211 at 146, v2.1.206 at 147) plus an explicit verification stamp at line 15 | Re-answer H1 for docs/03 and docs/29 from current HEAD. Extend docs/03's existing line-156 stamp convention to the Routines, MCP and Chrome sections rather than dropping stamps from them, and reinstate the v2.1.261 marker on the Routines fix. Add a mechanical precondition to the H1 lens: the agent m |
| **P2** | Model IDs and pricing — the KB's most volatile class — were never swept anywhere. docs/11-cost-control.md carries by far the densest concentration (Fable 5.1 x10, Sonnet 5 x7, Opus 5 x7, Opus 4.7 x4, Fable 5 x4, Haiku 4.5 x3, Opus 4.8 x2, plus literal ids `claude-sonnet-5` and `claude-fable-5-1`) and sits in the plan's 'touched, only new content verified' tier, so no agent has ever checked it. Rel | Add docs/11-cost-control.md to the next fact-check round as a dedicated target, verified against the live model/pricing pages rather than memory (the claude-api skill is the right entry point). Separately, add the Claude Fable 5 / Mythos-class attribution to the Bun passages in docs/04 and docs/23. |
| **P2** | The `main`-vs-`master` assumption will manufacture false absences in the next round, which is the exact failure the pass's own risk_note flags as dominant. The fix list's method used `raw.githubusercontent.com/<owner>/<repo>/main/README.md` throughout (clem, graphiti, goal-engineering, opik). I hit the counterexample immediately: houshuang/compound-review serves its README only from `master` — the | Mandate `curl -s https://api.github.com/repos/<owner>/<repo> | jq -r .default_branch` (or a git ls-remote) before any raw fetch, and make every 404/401/403 a hard stop that reports UNVERIFIABLE rather than absence. Re-run the two content-removing checks under that rule before landing them, as the ri |
| **P2** | The 93.4% fix was not re-read against the sentence that follows it. docs/04:346-350 currently reads "93.4% were caught by exactly one tool — no pair of tools ever flagged the same line. This corroborates the ~85-90% figure above...". The fix rewrites the first sentence to admit that 37 lines drew exactly two reviewers and 4 drew three, but leaves the following sentence untouched. I verified the ~8 | Re-read docs/04:331-352 as a whole after applying the 93.4% fix and reword the corroboration sentence to 'largely non-overlapping' rather than absolute. Add the 'past ~3 rounds introduces bugs' rationale at docs/04:340. Generally: require the fix applier to re-read the full paragraph around every ed |
| **P2** | Four classes are now VERIFIED CLEAN by me and must not consume next-round budget; two cross_doc recommendations are overstated as a result. (1) All 70 cross-doc anchored links resolve — I validated with python-markdown's real slugify (strip punctuation, then collapse runs of [-\s]); a naive slugifier reports 68 false breaks, so anyone re-running this must use the correct collapse rule. (2) All 98  | Record these as closed in the backlog so the next round does not re-derive them, and downgrade cross_doc items 9 and 8's link-rot framing. Do still add the URL sweep to the pipeline as a regression guard (it is cheap and the KB is public), but as prevention, not remediation — there is nothing curren |

**Verified clean by the critic — do NOT re-spend budget here:** all 70 cross-doc anchored links,
all 98 cited URLs bar the 2 known 404s, all 10 arXiv IDs and titles, and the Bun and
compound-review numbers. The critic also **downgrades its own fan-out's "link rot is systemic"
claim** — only 2 renames exist KB-wide and both are already fixed.

<details>
<summary>Original C1 analysis, for reference</summary>

### C1 — Fact-check the 14 never-touched docs · large

`02 03 04 05 06 10 16 19 20 22 27 29 30 31` — including `docs/04` (the KB's stated foundation) and
`docs/27` (its stated design spine).

- **Evidence:** `git log --oneline 43e86f6..HEAD` returns nothing for those 14 paths;
  `git log --oneline f0104a9..HEAD -- docs/` is empty — zero docs commits since the handover.
- **Sample of what needs checking:** `docs/05:53` (managed-policy path), `docs/05:92`
  ("Maximum 4 import hops"), `docs/27:120` (`/goal` limits of 25/30/40 turns, absent from `docs/30`).
- **Do:** follow `20260904_2002-v3-fact-check-gaps.md` §3–§4 verbatim, in a worktree, in priority
  order `04, 27, 05, 06, 16, 29`, then the remaining eight. One commit per doc. Fold **H1**
  (version stamps) into the same pass.

</details>

### C2 — ~~Superseded model IDs in copyable examples~~ · **SHIPPED v3.1.0**

**Done 20260905, PR #28.** Six sites; `docs/24:828` deliberately left, being quoted third-party material. **Correction to this item as written:** `claude-opus-4-8` is superseded, not invalid — still served, same price as Opus 5. Original analysis below.

A defect v3.0.0 **already diagnosed and fixed once** — commit `f5b3f79` fixed `docs/07:229` and left
three copy-pasteable instances behind.

- `docs/03-building-blocks.md:131` · `docs/09-headless-mode.md:45` · `docs/29-background-agents.md:24`
- `docs/09` was touched twice by v3.0.0 and neither diff hunk goes near line 45 — direct proof that
  "touched" ≠ "re-checked", which is the whole premise of **C7**.

### C3 — ~~The handover documents miscount the backlog~~ · **SHIPPED**

**Done 20260905, PR #20.** Original analysis below.

- **Done in this plan's own commit:** `20260904_2002-v3-fact-check-gaps.md:51` said "(16 docs)" and
  then listed **20** filenames (14 + 20 + 5 = 39); `CLAUDE.md:5` inherited the same "~16 more".
  Both corrected.
- The `disable-model-invocation` example is attributed to the doc-06 row (`:44`); it actually lives
  at `docs/03-building-blocks.md:50`.

### C4 — Zero-finding runs write a digest section the pipeline then throws away · small · needs **D1**-adjacent judgement

- **Evidence:** `integrate-loop-news/SKILL.md:69-70` mandates writing the section ("Never skip the
  section"); `:293` and `:304` skip the commit entirely for `N=0,M=0,U=0`. `fetch-loop-news/SKILL.md:23-25`
  derives `last_run_date` from the newest **committed** dated header, so it freezes.
- **Consequence:** the committed record cannot distinguish "swept, found nothing" from "did not run"
  — exactly the signal that would have made the outage visible.
- **Do:** pick a winner — drop the mandate, or add an `N=0` → commit row to the Phase 5a table.
- **Same file, same pass (D1):** `SKILL.md:300` emits `## [X.Y.Z] — <today's date> <TZ>`, which will
  stamp the next release `2026-09-05 05:12 BST`, one entry after v3.0.0 established `20260904 19:12`.

### C5 — ~~`docs/16-memory-patterns.md` has zero auto-memory coverage~~ · **SHIPPED 20260906**

**Done.** `docs/16` opens with *"First: the harness has its own memory now — and it is not this"*:
what auto memory is, a sourced reference table, the five properties that disqualify it as loop
state, three issue-tracker failure modes, and the in-the-repo test. Every version claim
(v2.1.32/.33/.59/.63/.74/.210/.214/.234) re-verified bullet-by-bullet against the raw official
changelog, and all three GitHub issues opened via `gh api` for title/state/labels — two are closed
**as `stale`, not fixed**, which the doc says. **Also closes H1's `docs/16` item**: zero `v2.1.x`
markers → eight.

**Correction to this item as written:** it called this "medium" and framed it as one missing topic.
The load-bearing content turned out to be the *distinction* — four different things are called
"memory" (auto memory, CLAUDE.md-as-memory-file, the API memory tool, third-party memory products)
and two of the four evidence agents conflated the first two, dating the feature to v2.1.59 (when it
was *named*) rather than v2.1.32 (when it shipped). Anything reworking this section must keep that
separation. Original analysis below.

- `grep -in "auto.mem\|native memory\|built-in memory\|memory tool\|/memory" docs/16` → nothing.
  Only KB-wide hit is a passing flag mention at `docs/09:83`.
- Needs **new content**, not a correction: scope, defaults, opt-out, and how it differs from the
  loop-external patterns the doc already covers.

### C6 — ~~`claude --worktree` standalone semantics~~ · **SHIPPED**

**Done 20260905, PR #36.** Written into `docs/03` as `### The built-in flag: claude --worktree`,
from the evidence pack, with every CLI-surface claim re-corroborated against `claude 2.1.261`
(`-w, --worktree [name]`, `--tmux` requiring `--worktree`, `--tmux=classic`, `claude rm <id>`).
`KB_GAPS.md`'s worktree entry moved to Recently Filled. `cleanupPeriodDays` was deliberately
left without a day count and logged as V5-adjacent (V4). Original analysis below.

**Do not re-research.** Ready-to-insert doc text is in [`20260905_1349-c6-c13-evidence.md`](20260905_1349-c6-c13-evidence.md),
Deliverable 1, verified against `claude 2.1.261`. Correction to this item as written below: the
gap note's "four isolation checks" is **right**, but the fourth is named **"Command shape"** (not
"unverifiable shell constructs"), the *"You can't turn this check off"* sentence belongs to that
check **alone**, and the git-redirect list also includes `GIT_WORK_TREE` and a plain `cd`.

Fully cited in `KB_GAPS.md:9-21` (source: `code.claude.com/docs/en/worktrees`, verified 2026-09-04),
never written up. `docs/03:31-36` and `docs/29:20-67` cover only the building-block mention and
`--bg --worktree`. Missing: default branch/path naming, `claude --worktree "#1234"`,
`.worktreeinclude`, and the four hard-enforced isolation checks — which are mechanically enforced
where this repo's own worktree rule is advisory prose. No new research needed.

### C7 — Sweep the 20 partially-verified docs · large

`01 07 08 09 11 12 13 14 15 17 18 21 23 24 25 26 28 32 33 34`. Only the *new* content was verified;
treat every pre-`20260904` sentence as unverified. Do after **C1**. `docs/09` (**C2**) is the proof
this is not hypothetical.

### C8 — ~~`SOURCES.md` post-outage revalidation~~ · **SHIPPED 20260906, PR #38** · was *medium*, was actually *small*

**Done 20260906 00:26 UTC.** Every one of the **47 checkable URLs** was fetched. **45 returned
200.** One was dead, one stored an `http://` URL that 301-redirects, and the remaining 7 rows carry
handles or search queries rather than URLs.

- **AI Breakfast was the one dead row** — `rss` against a feed that has 404'd since at least
  2026-07-08. `/feed`, `/feed.xml`, `/rss` and `rss.beehiiv.com/feeds/aibreakfast.xml` all 404, and
  the homepage carries no `<link rel=alternate>` and no beehiiv feed id, so **no discoverable feed
  exists**. Switched `rss` → `html` against the index page (9 `/p/<slug>` posts, 200) — the same
  defect and the same fix as The Batch. Its own note said *"try `/rss` next run"* and sat
  unactioned for two months, which is the actual lesson: a row that records its own breakage is
  not a fixed row.
- arXiv row normalised `http://` → `https://`.

**Correction to this item as written.** "52 carry no confirmation newer than Jul 2026" was true and
misleading: *undated* is not *dead*. Measured, **only 1 of 47 was broken**, so this was a ~20-minute
task rather than the medium-sized sweep implied. The row counts were also slightly stale — 54 rows
today, not 53; `github` is 23, not 22.

**What is still not validated, and was never in scope here:** whether a live URL actually *yields*
anything. A 200 proves reachable, not useful. The `SOURCES.md` rule — *a source yielding nothing
for more than ~3 consecutive runs must be re-fetched by hand* — remains the only check for that,
and nothing automates it.

### C9 — ~~KB_GAPS gaps 2–5 have had no targeted search in 8+ weeks~~ · **SHIPPED 20260906**

**Done. Three of four closed; the fourth closed as *still open* with a recommendation to stop.**

| Gap | Outcome | Landed in |
|---|---|---|
| F0–F3 fleet maturity indicators | **FILLED** | `docs/23` |
| Effort-vs-tooling budget boundary | **FILLED** | `docs/11` |
| Underspecified-input mitigation | **FILLED** | `docs/30` |
| Cross-model reviewer pairing | **still open after a 4th retry** — two real advances written up anyway | `docs/04` |

**Three corrections to this item as written.**

1. **The numbering was stale.** "Gaps 2–5" was numbered against `4ed29ff`, where gap 2 was
   `claude --worktree` — filled on 20260905. The set actually run was gaps **1, 3, 4, 5**.
   Gap 1 (F0–F3) was outside the item's stated range and had also gone unsearched since 07-08.
2. **"Small to schedule" was right about scheduling and wrong about value.** Three long-open gaps
   closed in one pass, two of them by material that changes doc-level advice.
3. **The F0–F3 answer was never a search problem.** It was inside
   `cobusgreyling/fleet-engineering` — a repo `docs/23` already cited **three times** — in two files
   nobody had opened. Three prior retries each looked for a *new* source. **Process rule now in
   `docs/23`: exhaust the repos already in `SOURCES.md` before searching outward; a citation is not
   a read.**

Original analysis below.

All four confirmed still open. v3.0.0 was a fact-check/restructure pass that never ran their
keywords, so incidental discovery is the only thing that has been tried. Gap 3
(effort-vs-tooling boundary) has **zero** retry annotations ever — start there.

### C10 — Changelog `0.2.21`–`v2.1.199` unswept; all "Fixed" bullets dropped · large

187 of 2,076 bullets reviewed, across 385 versions. Re-fetch the raw file
(`raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md` — the rendered site only
covers v2.1.235+), run the Added/Changed/Removed filter over the unswept range, then a second pass
over `Fixed` bullets for behaviour-changing language ("now", "previously", "no longer").
No changelog-category logic exists in either skill, so this filter was one-off, not recurring.

### C11 — ~~X never fetched directly; LinkedIn person-search never run~~ · **SHIPPED 20260906**

**Done. Both sweeps run and measured; evidence pack:
[`20260906_1259-c11-x-linkedin-baseline.md`](20260906_1259-c11-x-linkedin-baseline.md).**

**X.** Head-to-head on @bcherny, both methods minutes apart: profile read **4** posts, keyword
search **7**, union **9**, **overlap 2**. Neither finds two-thirds of the union, and the blindness
is structural in each direction. `SKILL.md` and `SOURCES.md` now mandate **both** passes, with the
profile pass explicitly **unfiltered**. Two on-topic `@bcherny` posts the KB never had were found
and integrated (`docs/28`, `docs/03`), including **388 PRs opened / 180 merged** from a named daily
routine fleet.

**LinkedIn — this item was measured and its recommendation reversed.** The person-search row was
**not** added. Person-search is network-biased rather than topic-ranked, matches résumé keywords
rather than published work (2 on-topic posts in 120 for the strongest candidate), and surfaced
**none** of the three authors the existing content row finds. The existing content row's keywords
were broadened instead, and the ruled-out strategy is recorded in `SOURCES.md` so it is not
re-proposed.

**Two corrections to this item as written.**

1. **"X never fetched directly" is wrong about the skill, right about the runs.**
   `fetch-loop-news/SKILL.md:95-97` *did* instruct a profile visit. The real defect was subtler and
   worse: it **keyword-gated that pass too**, so untracked vocabulary was invisible on *both* paths
   — while the line's own parenthetical claimed it caught exactly that. `git log -S` also shows the
   direct read was the **original** strategy, demoted to a trailing clause in `4fc6fca`.
2. **"Seven `x` rows" is now nine** — Hanako and Kirill were added by the 2026-09-06 run.

Original analysis below.

Seven `x` rows are the plan on paper, but `SOURCES.md:136` still describes the strategy as keyword
search, and keyword search cannot quantify what it missed. The only LinkedIn row is a content
search. Have `x` rows read profile timelines directly; add a `linkedin` person-search row and run a
baseline.

### C12 — ~~Plan §4b/§4c commitments never delivered~~ · **SHIPPED 20260906 (3 of 4 delivered, 1 refused with cause)**

**Done**, and the pass falsified the plan's own headline framing.

| Commitment | Outcome |
|---|---|
| ClaudeWarp as a named case study (G0–G3, R0–R5, BLOCK/WARN) | **Partly.** BLOCK/WARN → `docs/04`. **R0–R5 deliberately NOT added** — see below |
| `/ultraplan`; the `/agents` wizard removed in v2.1.198 | **Both delivered** — `docs/24` and `docs/07` |
| `/batch`, `/code-review`, `/security-review`, Desktop scheduled tasks | **`/code-review` corrected** in `docs/36`; the rest re-verified, see below |
| ClaudeWarp recorded in `CHANGELOG.md` | **Delivered** in this release's entry |

**The headline lesson was false as stated, and the correction is the more valuable finding.** §4b
said *"`/claude-warp-sync` … retires ClaudeWarp components the moment a native feature covers
them"*, and `docs/24`, `docs/35` and `docs/36` had all repeated it in the indicative. Measured
against ClaudeWarp's own changelog: the mechanism is real and complete, has run **twice** across
**65** Claude Code releases, and has retired **zero** components — both runs record *"no Harness row
is superseded"*. Its one `Removed` component was superseded by another ClaudeWarp skill. All three
docs corrected; `docs/24` now carries the measurement and the three lessons that follow.

**`/ultraplan` was removed in v2.1.222**, so the commitment to document it as a native primitive was
moot as written. Recorded instead as the sharper lesson it became: *native features also depart*, so
retiring your own component is a bet on the native one surviving.

**R0–R5 was refused, not forgotten.** `docs/04` already carries an R0–R5 ladder labelled as this
KB's own; ClaudeWarp's is near-identical row-for-row; and ClaudeWarp ships
`/claude-warp-sync-research`, whose documented job is to fetch **this repository** and implement
what it finds. Citing it back as an external case study would cite the KB to itself. Caught by the
completeness critic.

**A first-party disclosure was added to all five docs citing ClaudeWarp** (`11`, `22`, `24`, `29`,
`35`, canonical note in `36`). The KB flags vendor bias for BrainGrid and Hindsight/Vectorize and
was applying none to the maintainer's own tool.

**Correction to the row for `/code-review`:** this item's table implied the KB said v2.1.218 moved
it *to a plugin*. The KB says **background subagent**, which matches the changelog verbatim. The
real defect there was different and is now fixed — `docs/36`'s v2.1.215 claim that Claude no longer
runs it on its own **no longer holds**, since v2.1.246 says Claude *"can also start it on its own"*.

Original analysis below.

From `20260904_1658-two-pillar-restructure.md` §4b, "these go into Part II **regardless** of the
ClaudeWarp framing":

| Commitment | State at `4ed29ff` |
|---|---|
| ClaudeWarp as a **named case study** (G0–G3 gate, R0–R5 tiers, two-tier BLOCK/WARN verdict) | **Absent.** G0–G3 (`docs/30:114`) and R0–R5 (`docs/04:200`) exist but are attributed to other sources; "BLOCK/WARN" appears nowhere |
| `/ultraplan`; the `/agents` wizard removed in v2.1.198 | **Zero mentions** anywhere in `docs/` |
| `/batch`, `/code-review`, `/security-review`, Desktop scheduled tasks | One line each (`docs/37:120`, `docs/36:112-113`, `docs/39:173`) |
| ClaudeWarp recorded in `CHANGELOG.md [3.0.0]` | Absent — shipped content, unrecorded |

Delivered from the same plan, for contrast: the model line-up table (`docs/11:25-71`), KB errors
#1–#4 (`docs/07:205-217`, `:283-299`, `docs/08:5`), and ClaudeWarp as reference implementation
+ the "harness designed to shrink" lesson (`docs/35:155-160`, `docs/36:191-216`, `docs/24:843-846`).

### C13 — ~~13 `CLAUDE_CODE_*` env vars asserted, never verified as a set~~ · **SHIPPED**

**Done 20260905, PR #36.** All four corrections applied, each re-fetched from the official
env-vars reference in that session rather than taken from the pack on trust. Two improvements on
what the pack proposed: `docs/07`'s row gained a *sourced* fact — the cap takes plain digits and
can be adjusted but **not disabled** — instead of only losing the unsourced error literal; and
`docs/08` gained the fail-open counterpart to its privilege-escalation section, since a settings
`env` block cannot turn `CLAUDE_CODE_RESTRICTED` **on** either. Pack uncertainty #2 is settled:
the v2.1.207 quotation at `docs/08:101` reproduces verbatim upstream. What stayed unsettled is
logged in `KB_GAPS.md` § Claims Awaiting Verification (V1–V4, V6) — nothing was deleted for
being merely unsourced. Original analysis below.

**Do not re-research.** Per-variable verdict table, four concrete corrections, and — critically — a
list of claims that are unsupported but must **NOT** be deleted, in
[`20260905_1349-c6-c13-evidence.md`](20260905_1349-c6-c13-evidence.md), Deliverable 2. The inventory pass flagged
`CLAUDE_CODE_SIMPLE` and `CLAUDE_CODE_SAFE_MODE` as suspected fabrications; **both are real**.
Seven items the evidence could not settle are listed there rather than rounded off.

The fabricated `CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION` row is confirmed gone from `docs/`. The
remaining assertions have never had one systematic pass against the official env-vars reference —
notably `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` (`docs/07:284`, asserting a limit of 20).
Full list, by frequency: `SUBAGENT_MODEL` (18), `SUBAGENT_MODEL_FORCE` (9),
`EXPERIMENTAL_AGENT_TEAMS` (4), `MAX_SUBAGENT_SPAWN_DEPTH` (3), `ENABLE_AUTO_MODE` (2), and one each
of `SIMPLE`, `SESSION_ID`, `SAFE_MODE`, `RESTRICTED`, `REMOTE`, `PRINT_BG_WAIT_CEILING_MS`,
`MAX_CONCURRENT_SUBAGENTS`, `DISABLE_WORKFLOWS`.

### C14 — ~~Background-session CLI contract: four confirmed KB defects~~ · **SHIPPED**

**Done 20260905, PR #36.** Both claims this item listed as *"still peer-reported and NOT verified
here"* are now verified locally against `claude 2.1.261`:

- **The variadic-flag swallow is real.** Reproduced with
  `claude -p --mcp-config /nonexistent.json "reply with OK"` →
  `MCP config file not found: <cwd>/reply with OK`. Seven flags take variadic lists on 2.1.261.
- **`claude agents --all` exists** — *"With --json: also include completed background sessions"*.
- **`waitingFor` remains unverified** and was deliberately **not** written into the KB. Absence
  from our observation is not absence from the CLI. Logged as V5.

Two findings this item did not have, both from *running* the surface rather than reading it:
on `--bg` the swallow is **silent** — the session starts `(idle — send a prompt to start)`, the
launcher exits 0, and no work ever happens — and `--max-budget-usd` is **silently accepted** on
`--bg` rather than rejected. `docs/29` was shipping both in copyable examples.

**Correction to this item as written.** The session-floor arithmetic does **not** "match to four
decimals". 22,659 tokens at Opus 5's $10/MTok 1h-cache-write rate is **$0.2266**, leaving
**$0.0139 — 5.8% of the recorded $0.240609 — unexplained** by the three published token counts.
The generalisable claim survives: the cache write is **94%** of that session's cost, and the
cross-model figures check out ($0.09 on Sonnet 5, $0.05 on Haiku 4.5). Both `docs/29` and
`docs/11` state the residual rather than rounding it off; the gap is logged as V6.

Original analysis below.

Reported by the ClaudeWarp session 20260904 (its
[v0.42.0](https://github.com/lucagattoni/Claude-Warp/releases/tag/v0.42.0) sync), and **re-verified
here against the installed `claude 2.1.261`** rather than taken on the peer's word. These are exactly
the class of fact the changelog pass cannot catch: three of the four are `Fixed`-worded or
help-text-only, and **C10** already flags that `Fixed` bullets were dropped wholesale.

| # | Verified fact (v2.1.261) | KB impact |
|---|---|---|
| 1 | `claude --bg -p …` is **rejected up front**, exit 1: *"--bg and --print conflict… The prompt is the positional — drop --print: `claude --bg '<task>'`"*. Behaviour since v2.1.198; before that it silently created an unattachable session | `docs/29`, `docs/18` |
| 2 | `--max-budget-usd` help reads **"(only works with --print)"**, and `--permission-prompts` is documented only *"with --print"* | **A `--bg` session has no dollar cap and no fail-closed prompt default.** `docs/09`'s fail-closed `--permission-prompts none` guidance is `-p`-only and currently reads as universal. Its only `--bg` ceilings are `--max-turns`, an explicit `--model`/`--effort`, and stopping it |
| 3 | `claude agents --json` returns `id` (8-hex short id), `sessionId` (uuid), `state` (`working`), `status` (`busy`), plus `pid`, `cwd`, `kind`, `startedAt`, `name` | `docs/29` — the short `id` is what `attach`/`logs`/`stop`/`rm` take |
| 4 | `--max-turns` is still accepted but **no longer listed in `claude --help`**; `--max-budget-usd` is listed | `docs/18` — needs a version-stamped note (ties to **H1**) |

**The session-floor finding — peer-measured, arithmetic re-checked here, worth a KB line.**
ClaudeWarp's follow-up ([v0.42.1](https://github.com/lucagattoni/Claude-Warp/releases/tag/v0.42.1))
retracted its own first explanation of the $0.24 figure. The number holds; the *cause* was wrong.
Recorded `cost-state`: `totalCostUSD` 0.242504, of which Opus 5 was $0.240609 on **2 input / 4 output
tokens** — with **thinking tokens 0** and a **22,659-token 1-hour cache write**. Effort did not drive
the cost; 93.4% of it was the session writing its own system prompt and tool definitions into a 1h
cache at Opus's 2x rate, for a session that lived 64 seconds. Re-computing from those token counts at
list price gives $0.2406 against $0.240609 recorded — matches to four decimals, so it is a real
per-session cost and not a rate-limit-window artefact.

> **The generalisable claim:** a fresh `--bg` session pays a floor before doing any work —
> (system prompt + tool definitions) x the model's cache-write rate — so a fan-out's budget is
> (items x floor) + actual work, and **the floor scales with the model's price, not the task**.
> The operator move is therefore *pin a cheaper model*, not *lower the effort*: the identical write
> on Sonnet 5 is $0.09.

Two homes for it: `docs/29` (the `--bg` cost contract, alongside fact 2) and `docs/11`, which argues
the 1h-vs-5m cache-write bet **qualitatively and now has a measured case** of the short-lived-session
loss. Cite ClaudeWarp v0.42.1; we have not reproduced the measurement ourselves.

**Still peer-reported and NOT verified here — verify before writing into the KB:** that a positional
prompt after a variadic flag (`--allowedTools`, `--worktree`) is swallowed as another value; the
`--all` flag and `waitingFor` field on `claude agents`.

**Also:** ClaudeWarp documents the native `--bg --worktree` contract (positional-first, no dollar
cap, workers commit/push their own branch per v2.1.221, nothing merges back) — a concrete consumer
to cite when writing **C6**.

**Method note this vindicates** — and it cuts deeper than **C10** alone. A changelog-only sync
missed a broken scaffold for 60+ releases. But the `Fixed` bullet, had it been read, would only have
said `--bg -p` is now rejected; what revealed the scaffold was *broken* was **running it**. Reading
finds the fact, executing finds the consequence. So **C10**'s Fixed-bullet pass is necessary and not
sufficient: pair it with exercising the surface the way a user does — which is the same test-seam
rule this KB already states and its own pipeline did not follow (see **A1**).

---

## 5. Tier 3 — corpus integrity and hygiene

| # | Item | Effort | Evidence / action |
|---|---|---|---|
| **H1** | Part II's "version-stamped" promise unkept in ~~6~~ **5** of 21 docs | medium | Zero `v2.1.x` markers in ~~`03`~~ `05 06 15` ~~`16`~~ `19` ~~`29`~~ `31` ~~`35`~~ — **`16` closed 20260906 by C5, 0 → 8 markers**; `docs/11` has 34. **`03`, `29` and `18` stamped 20260905 (PR #36)**; `35` re-check pending. Promised at `docs/index.md:76-77` and `LOOP_ENGINEERING.md:78`. Fold the rest into **C1** |
| ~~**H2**~~ | ~~Three repo self-descriptions are falsified~~ · **SHIPPED 20260906, PR #38** | small | `LOOP_ENGINEERING_NEWS.md:3` **and** `KB_GAPS.md:4` both credited `fetch-loop-news`, which writes only `.loop-news/findings.json` — both now credit `integrate-loop-news`. **Correction to this item:** the `docs/34` half is not falsified. `:317`'s "05:00 local" is *correct* (it is the watchdog comment's "04:00 UTC" that drifts — see **H14**), and `:321`'s "L3 — commits and publishes autonomously" became **true** when the tracker published on 20260905; it was only false against the since-superseded `runs = 0`. `CLAUDE.md:3` was rewritten in `v3.1.0`. So: 2 real, 1 self-resolved, 1 already fixed |
| ~~**H3**~~ | ~~README's tracker section is stale and structurally misplaced~~ · **SHIPPED 20260906, PR #38** | small | Both halves fixed: the example + type list moved back under "Add or remove a source", and all **7** types are now documented as a table with row counts. Counts corrected — **28 of 54** rows were of undocumented types (github **23**, not 22; 54 rows, not 53) |
| ~~**H4**~~ | ~~The Boris Cherny "write loops" quote is unpinned in four places~~ · **DONE 20260906** | small | Pinned to [the WorkOS *Acquired Unplugged* talk](https://www.youtube.com/watch?v=RkQQ7WEor7w), verified against the video's own caption track at ~11:45–11:53. **Two corrections to this row:** `docs/20:14` is a *paraphrase* in a table cell, not a quote reproduction — it now carries the full quote and the link; and the row's four-location list **missed `docs/03:3`**, a fifth uncited reproduction, while over-counting `LOOP_ENGINEERING_NEWS.md:268` (drifted to `:808`), which is append-only history and was corrected by a new hand-authored entry rather than rewritten. `docs/32`'s "Primary source ... in his own words" label was false — thenewstack.io embeds a third-party tweet — and both its "Why here" and "Summary" paragraphs are corrected. (`docs/39:334-347` was correctly pinned and was not part of this) |
| ~~**H5**~~ | ~~`docs/17` declares a taxonomy it never applies and has no headings~~ · **DONE 20260906** | medium | The flat table is now split under the three `## ` headings the intro already declared — **Underspecification** (5 rows), **Capability errors** (2), **Harness errors** (31) — giving the doc deep-linkable anchors for the first time despite **16** inbound references (the row's "10" was an undercount, as was its "33 ungrouped rows": there were 37). All 37 original rows are preserved byte-for-byte; a **silent scheduler death** row was added, written against this repo's *corrected* incident record (see §2's `U2`: launchd fired all along — the fault was a hardcoded binary path plus an exit code nobody classified), not the disproven "the scheduler stopped firing" story. **Corrections to this row:** `docs/18` no longer shares the zero-heading shape — it grew to 50 lines and gained `## Flags that do not mean what the snippet suggests` during unrelated work. `docs/15`'s remaining zero-heading shape is closed by **H8**, not here. ~8 of the 37 category assignments are genuine judgement calls, documented in the PR |
| ~~**H6**~~ | ~~Bare citations~~ · **SHIPPED 20260906** — closed, with the sweep's own completeness claim corrected twice | small | **Both originally-named items are now closed.** `docs/20:5` was already fixed incidentally by the C1 pass (`d995b82`, PR #37) about 18 hours after this row was written and was never struck off; `LOOP_ENGINEERING_NEWS.md:1017` (drifted from `:477`) was fixed 20260906. Six more were found and fixed by the step-10 sweep: `docs/37:73` (Tran & Kiela → [arXiv 2604.02460](https://arxiv.org/abs/2604.02460)), three Prithvi Rajasekaran attributions (`docs/11:216`, `docs/13:63`, `docs/24:510`) and two in `docs/17` (Dilger, Ronacher ×2). **Five more repo slugs were surfaced mechanically, on the first run of `scripts/kb-structure-check.sh` (H11)** — after a five-angle manual sweep had reported angle 1 clean. That is the third falsified "complete sweep" claim, and the strongest evidence that H11 was worth shipping. **But the mechanical list was itself over-broad, and was checked slug by slug rather than trusted:** only **three** were real. `docs/04:223` (`jahwag/clem` — unlinked anywhere in that doc), `docs/23:97` (`thirai-classlab/hirai-method` — the single occurrence in the whole corpus, unlinked, and *not* in the mechanical list) and `docs/23:97` (`ruvnet/ruflo` — first mention unlinked, its only link 101 lines below). All three fixed 20260906; all six repos confirmed to exist via `gh api` first. **Three were not defects:** `docs/04:318` (`mateaix/loope`, linked 7 lines below at `:325`), `docs/16:77` (`anthropics/claude-code`, whose issue table links into that repo three times immediately below) and `docs/23:97` (`chf3198/megingjord-harness`, linked 5 lines below at `:102`) — each covered by the KB's established "link once nearby" convention, the same one upheld for `docs/32`. Linking them again would be over-correction. **The lesson generalises: the mechanical check is a candidate generator, not a verdict** — it cannot see a link five lines away, so its output is triaged by hand. That is recorded in the script's own header and in Phase 4c. **Two documented waivers, not defects:** `docs/32:49`'s trailing `— @roanbrasil` follows the reading-list's consistent "title linked, author name bare" convention across ~25 entries, and `docs/31:90`'s `@mention` is a table cell naming a trigger mechanism, not a citation |
| ~~**H7**~~ | ~~`docs/21` is a one-way orphan~~ · **PREMISE FALSIFIED, THEN CLOSED — 20260906** | small | The orphan condition resolved itself before anyone worked the item: `docs/04:733`'s link landed 2026-09-05 (`904c127`, an unrelated "Non-Probabilistic Node Rule" section) and `docs/17:51`'s landed 2026-09-06 (`b1f7ed7`, an unrelated "Scheduler-invisible loop" row) — two ordinary tracker runs, two different days, neither a deliberate fix. The row's counts were also wrong: `docs/21` links out to **8** docs (`02 04 05 13 16 17 24 37`), not seven. The one real remainder — no reciprocal link from `docs/13`, one of those 8 outbound targets — was added 20260906. **Note the mechanism:** the row's own grep (`grep -rln "21-context..." docs/`) matched plain-text mentions in `docs/news.md`/`docs/changelog.md` while missing real inline links, which is what produced the false premise. `scripts/kb-structure-check.sh` (H11) now does this check correctly |
| ~~**H8**~~ | ~~`docs/15` duplicates `docs/36`~~ · **DONE 20260906 — substantiated, not merged** | medium | **Correction to this row:** the "same ground" framing did not survive a close read. `docs/36:26-48` is a strategic three-phase table plus Ng's spec-scaling argument, and it *cites* `docs/15` by link as the mechanism for its Planning phase; grep for `docs/15`'s actual content (`Shift+Tab`, `--permission-mode plan`, `Ctrl+G`) against `docs/36` returns zero overlap. Two altitudes of one topic, which is this KB's deliberate pattern, not duplication. Also refuted: the feared 39-doc renumbering cost — doc IDs already sit non-sequentially in the nav (15/36/37 share section 6), so they are stable identifiers, not positions. `docs/15` had 6 inbound links across 5 files, three of which already treat it as the canonical Plan Mode page, so it was substantiated in place — every added fact live-fetched from `code.claude.com/docs/en/permission-modes` or cross-referenced to already-verified `docs/07`/`docs/36` content — and the `LOOP_ENGINEERING.md` and `docs/index.md` summaries were synced in the same change. Zero link or nav churn; reversible if a later review disagrees |
| ~~**H9**~~ | ~~`findings.json` `"schema": 1` is written but never checked; phase numbers collide~~ · **DONE 20260906** | small | **Half of this closed itself.** `run-loop-news.sh`'s `artifact_state()` (line 266) has asserted `schema == 1` since A11/PR #30 — added for Stage-A resumability, not for this item, and never struck off here. The skill-level half was real and is now fixed: `integrate-loop-news`'s Phase 0 abort list checks `schema` alongside JSON validity and `today`, so a direct (non-wrapper) invocation is guarded too. **The phase-collision half was false as written.** The two skills do define different `## Phase 4` sections (`fetch-loop-news/SKILL.md:331` vs `integrate-loop-news/SKILL.md:38`), but no live cross-file reference is unqualified — `CLAUDE.md:55,158` say "Phase 4c in `integrate-loop-news`" and "`integrate-loop-news`'s Phase 5"; `docs/34:329` (the cited `:319` has drifted) says "Phase 4b/4c", a suffix only `integrate-loop-news` defines. This was already true at `3b1dc7c`, the commit that wrote the claim. One waiver: `LOOP_ENGINEERING_NEWS.md:52`'s "that happens here, in Phase 4" is self-referential inside an append-only digest entry and is left as written |
| ~~**H10**~~ | ~~15 tags have no release~~ · **BACKFILL SHIPPED 20260906** (`v3.1.9`) | small | Was 53 tags / 38 releases; now **63 tags, 63 releases, 0 missing**, `latest` still `v3.1.8`. All 15 (`v1.1.0 v1.2.0 v2.0.1 v2.0.2 v2.1.1 v2.1.2 v2.3.1`–`v2.3.9`) created from each version's own `CHANGELOG.md` section verbatim, marked `--latest=false`. **The other half stays open:** the pipeline still has no tag/release step, by the deliberate decision recorded in `CLAUDE.md` § Releases — `gh` is not in the unattended agent's allowlist. So this recurs every pipeline-cut version and needs the same manual backfill; that standing cost is the thing **D2** still has to settle |
| **H11** | Structural review (Phase 4b/4c) has caught none of H5/H7/H8 across ~20 runs | small | The review is mandated after every run by `CLAUDE.md`; three structural defects survived it. Tighten the phase's checklist with concrete queries (orphan check, heading check, duplicate-coverage check) |
| **H12** | Co-resident session-leak security claim: neither verified nor tracked | medium | Exists as one sentence at `LOOP_ENGINEERING_NEWS.md:125`; `grep -rn 'co-resident' docs/ KB_GAPS.md` → nothing, and `docs/19` has no session-isolation content. At minimum log it in `KB_GAPS.md`; ideally reproduce with a two-session test and publish the finding *or its refutation* |
| **H14** | The tracker's "04:00 UTC" slot expires on 2026-10-25 | small | `StartCalendarInterval` is **local** time (`Hour: 5`), so `05:00 local = 04:00 UTC` holds only during IST. When Ireland leaves IST the slot becomes 05:00 UTC and `tracker-watchdog.yml:15` plus `CHANGELOG.md:867` go stale. The watchdog keeps 4h of margin either way, so this is doc accuracy, not an operational break. Found 20260905 |
| **H13** | `plans/` has no retirement policy | small | `find . -iname '*archive*'` → nothing. Needs **D3**; then archive the two delivered plans in §6 |

---

## 6. Corrections to make to existing documents

These documents are **wrong at `4ed29ff`** and will mislead the next agent. Fixing them is part of
this backlog, not a separate task.

| Document | Claim | Reality |
|---|---|---|
| `20260904_2002-v3-fact-check-gaps.md:14-15` and `LOOP_ENGINEERING_NEWS.md:13` | the tracker was **"re-armed"** | **True after all** — and this backlog was wrong to call it false. `runs = 0` on 20260904 meant the re-arm predated its first 04:00 trigger, not that it had failed. It fired on schedule 20260905 and the sole fault was **A7**. Both now moot: the tracker has published (`v3.0.1`). |
| `plans/split-fetch-loop-news.md:499-556` | 0 of 10 steps checked | **All 10 shipped** as `v2.6.0`: both skills exist, `.gitignore:4`, `run-loop-news.sh:22,135,149,262-268`, `docs/09:203-229`, `CHANGELOG.md:373`, tag `v2.6.0`, release 2026-07-03, PR #7 (`c34d41e`) |
| `plans/loop-engineering-tracker.md:150-166` | Steps 7/9 describe CronCreate scheduling | Superseded by launchd (`570ce26`, v2.3.11); `scripts/SCHEDULING.md:3` states it plainly. No open commitment — just wrong about how the system runs |
| `LOOP_ENGINEERING_NEWS.md:118-119` | "9 docs never fact-checked" | Superseded by the corrected, worse list of **14**. The digest is the stale artifact on this point |
| carried assumption | the 2026-07-08 `max turns (100)` failure is unfixed | **Fixed.** `run-loop-news.sh:51` defaults `INTEGRATE_MAX_TURNS` to 250 (`63c230f`); `SEARCH_MAX_TURNS` stays 100 and has never needed raising |
| carried assumption | the `AskUserQuestion` over-correction was never reverted | **Reverted.** `docs/14:55-58` carries the worked example, citing the `2.1.200` change |
| carried assumption | `KB_GAPS.md` "Recently Filled" needs pruning | Cap honoured — exactly 2 entries |

**Verified green at `4ed29ff`, no action:** `mkdocs build --strict` exits 0; nav ↔ disk ↔
`LOOP_ENGINEERING.md` agree on all 39 docs with no orphans or duplicates; 367 internal links and
anchors, 0 broken; project `CLAUDE.md` is 45 lines (guardrail ~150); `v3.0.0` tags `cb4e489`, is on
the remote, and is marked latest.

---

## 7. UNCLEAR — the evidence does not settle these

| # | Unknown | How to settle |
|---|---|---|
| **U1** | Whether the **2026-07-01 → 07-14** window was ever swept. Round-1 critics flagged it "essentially uncovered" (high severity); the final digest's own "what was NOT swept" section (`LOOP_ENGINEERING_NEWS.md:114-131`) does not mention it, and no finding dates to it. Either round 2 closed it and the digest omits saying so, or the digest missed its own honesty standard | Re-run a source sweep scoped to that window, or recover round 2's per-source date coverage. Add an explicit disclosure line either way |
| **U2** | **RESOLVED 20260905 — one fault, not two.** launchd was firing correctly all along (`runs = 2`, a scheduled run at `04:00:38Z` on 20260905). The backlog's original claim that it was not firing was **wrong** — inferred from absent logs, when the re-arm simply predated its first trigger. The sole fault was A7. | Settled by the 20260905 run. |

---

## 8. Order of work

| Step | Items | Gate |
|---|---|---|
| 1 | **A1** — strict-build gate in the skill | A deliberately broken link aborts the push |
| 2 | **A7** — resolve + preflight `CLAUDE_BIN` | Preflight fires under `env -i` with the launchd PATH |
| 3 | **A2** — one real end-to-end run | Commit on `main` + run log + **a new `launchd.log` entry** (resolves the rest of **U2**) |
| 4 | **A4**, **A5**, **A6** — CI paths, `docs/index.md`, the two no-retry branches | `mkdocs build --strict` |
| 5 | **A3** — remote staleness watchdog | Watchdog fires on a deliberately stale digest header |
| 6 | **§6 corrections** + **C3** — stop the handover docs lying, cheapest possible win | — |
| ~~7~~ | ~~**C2**, **C6**, **C13**, **C14** — small content fixes with sources already in hand~~ · **DONE** — C2 in PR #28, C6/C13/C14 in PR #36 | Citation-link gate |
| ~~8~~ | ~~**C1** + **H1** — the 14-doc fact-check~~ · **PARTIAL** — 49 fixes shipped in PR #37; coverage gaps carried to **C1b**, H1 answered per doc (6 of 14 docs legitimately need no stamp) | One commit per doc, each gated on `--strict` |
| ~~8b~~ | ~~**C1b** — the coverage the C1 pass did not reach~~ · **DONE** — P0s in PR #40 (`v3.1.6`), P1/P2 in `v3.1.8` | Re-run `docs/03`/`docs/29` against HEAD; open the 78 unopened URLs |
| ~~9~~ | ~~**C5**, **C8**, **C9**, **C11**, **C12**~~ · **DONE 20260906** — C5/C9/C11/C12 shipped this pass; C8 was already done | Resource-review rule (score ≥ 3.0 before extracting) |
| 10 | **H2**–**H9**, **H11**, **H12** — corpus hygiene | — |
| 11 | **C7**, **C10** — the two large sweeps | — |
| 12 | **D2**/**H10**, **D3**/**H13** — release policy and plan archival | — |

> **Status 20260906 (updated after step 9):** steps 1–9 are shipped. Step 9 closed C5, C9, C11 and
> C12 — three KB_GAPS entries filled, a fourth closed as still-open, both missing source sweeps run
> and measured, and a **false claim about ClaudeWarp corrected in three docs**.
> **The next task is step 10 — H2–H9, H11, H12 (corpus hygiene)**, then step 11's two large sweeps,
> **C7** and **C10**, which remain the biggest unclaimed content risk. **H1**'s remainder is now
> `05 06 15 19 31` plus the `35` re-check — **`16` was closed by C5** — and folds into C7.
>
> **Three things step 9 established that later steps should not re-derive:**
> 1. **Exhaust the repos already in `SOURCES.md` before searching outward.** F0–F3 sat open through
>    three retries while the answer was in a repo `docs/23` cited three times. A citation is not a read.
> 2. **ClaudeWarp cannot corroborate this KB.** It ships a skill whose job is to read this repo, so
>    agreement between them is shared origin. All five citing docs now carry a first-party disclosure.
> 3. **Cross-model reviewer pairing is closed as still-open after four retries.** Do not schedule a
>    fifth unless someone publishes a replication.
> The paragraph below is retained as the reasoning that ordered automation ahead of content; that
> ordering is now spent.

**Highest-value next task: steps 1-3, in one sitting.** A1 is the only item with two confirmed
production incidents behind it, and it is a strict prerequisite for A2 — re-arming the pipeline
ungated re-arms the exact failure that broke the site on 07-06 and 07-07, this time on a tree nobody
has published from in eight weeks. A7 is non-negotiable before A2: the tracker
invokes a binary that does not exist, so a validation run without it measures nothing. A2 then
converts the repo's biggest unknown into a fact. This beats C1 (the fact-check) because automation
defects **compound daily** — every day the tracker does not run is KB drift no later fact-check can
recover — while the content gap's cost accrues linearly.

---

## 9. Standing gates

Applies to every commit produced from this plan.

- `uv run --with-requirements requirements-docs.txt mkdocs build --strict` — run **bare**, as the
  last step before the commit. A gate is only a gate when its exit status is what the next command
  reads: `check | tail && git commit` reports `tail`'s status, so a failing checker looks green.
- `grep -rn 'repo: github\.com' docs/ | grep -v '\[github'` — and note this grep is narrow; **H6**
  exists because it misses bare `@handles` and bare `owner/repo` slugs.
- Worktree per `CLAUDE.md`; branch `YYYYMMDD_HHMM-<name>` (UTC, read from the clock).
- Public repo — the PRIMARY CHECK runs on every file before every commit.
- Commit and push at each iteration; never batch a review round into one commit.

---

## 10. How this backlog was produced

A 16-agent workflow over the tree at `4ed29ff`: 7 dimension auditors → 7 independent adversarial
verifiers (each told to hunt false-OPEN and false-DONE) → 1 completeness critic → 1 synthesis pass.
Auditors and verifiers on Sonnet; critic and synthesis on Opus. 941k tokens, 22 minutes, 0 agent
errors.

**Known weaknesses in the audit itself — stated so they are not mistaken for coverage:**

- The `changelog-selfdefects` auditor returned a placeholder stub and its verifier supplied no
  evidence of its own sweep. That dimension was redone by hand; **C13** and the `AskUserQuestion`
  row in §6 come from that manual pass.
- The completeness critic's 13 items received **no** adversarial verification. Those that survived
  into this file (**C4**, **H1**, **H3**, **H5**, **H9**, **H13**) were spot-checked by hand
  afterwards; the rest were dropped.
- Two auditors cited wrong line numbers repeatedly. Their conclusions held on re-derivation; every
  line reference in this file was re-checked against the tree.
- **C12** was not found by the workflow at all — it came from reading
  `20260904_1658-two-pillar-restructure.md` §4b directly. Treat the agent sweep as a floor on what
  is outstanding, not a ceiling.
