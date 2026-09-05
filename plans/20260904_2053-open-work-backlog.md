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

### C5 — `docs/16-memory-patterns.md` has zero auto-memory coverage · medium

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

### C8 — `SOURCES.md` post-outage revalidation · medium

53 data rows; **52 carry no confirmation newer than Jul 2026** — predating the entire outage.
`SOURCES.md:96` still reads "**Still 404 as of 2026-07-08**" with a suggested fix never acted on.
Start with the known-broken row, then the 21 dated Jul 2026 or earlier.

### C9 — KB_GAPS gaps 2–5 have had no targeted search in 8+ weeks · small to schedule

All four confirmed still open. v3.0.0 was a fact-check/restructure pass that never ran their
keywords, so incidental discovery is the only thing that has been tried. Gap 3
(effort-vs-tooling boundary) has **zero** retry annotations ever — start there.

### C10 — Changelog `0.2.21`–`v2.1.199` unswept; all "Fixed" bullets dropped · large

187 of 2,076 bullets reviewed, across 385 versions. Re-fetch the raw file
(`raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md` — the rendered site only
covers v2.1.235+), run the Added/Changed/Removed filter over the unswept range, then a second pass
over `Fixed` bullets for behaviour-changing language ("now", "previously", "no longer").
No changelog-category logic exists in either skill, so this filter was one-off, not recurring.

### C11 — X never fetched directly; LinkedIn person-search never run · medium

Seven `x` rows are the plan on paper, but `SOURCES.md:136` still describes the strategy as keyword
search, and keyword search cannot quantify what it missed. The only LinkedIn row is a content
search. Have `x` rows read profile timelines directly; add a `linkedin` person-search row and run a
baseline.

### C12 — Plan §4b/§4c commitments never delivered · medium

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
| **H1** | Part II's "version-stamped" promise unkept in **6** of 21 docs | medium | Zero `v2.1.x` markers in ~~`03`~~ `05 06 15 16 19` ~~`29`~~ `31` ~~`35`~~; `docs/11` has 34. **`03`, `29` and `18` stamped 20260905 (PR #36)**; `35` re-check pending. Promised at `docs/index.md:76-77` and `LOOP_ENGINEERING.md:78`. Fold the rest into **C1** |
| **H2** | Three repo self-descriptions are falsified, one on a published page | small | `LOOP_ENGINEERING_NEWS.md:3` credits `fetch-loop-news`, which `SKILL.md:13-16` now forbids from writing tracked files; `docs/34:319` claims "Daily cron (launchd), 05:00 local" and "L3 — commits and publishes autonomously" against `runs = 0`; `CLAUDE.md:3` predates the two-part scope |
| **H3** | README's tracker section is stale and structurally misplaced | small | `README.md:125` lists 3 source types; **7** are in use (github 22, rss 14, x 7, html 5, github-search 3, x-search 1, linkedin 1) — the 4 undocumented types are 27 of 53 rows. Move `:121-126` back under "Add or remove a source" (`:110-113`) |
| **H4** | The Boris Cherny "write loops" quote is unpinned in four places | small | `docs/26:29` (no link at all), `docs/32:35-42` (secondary source), `docs/20:14`, `LOOP_ENGINEERING_NEWS.md:268` — four differing reproductions. Pin one talk/interview. (`docs/39:334-347` is correctly pinned and is not part of this) |
| **H5** | `docs/17` declares a taxonomy it never applies and has no headings | medium | `grep -c '^## ' docs/17` → 0, with 33 ungrouped rows, an empty on-page TOC and no deep-linkable anchors despite 10 inbound links. Add a row for **silent scheduler death** — the failure this repo just lived through. `docs/15` (26 lines) and `docs/18` (34 lines) share the zero-heading shape |
| **H6** | Two bare citations, and the sweep that found them is unreliable | small | `docs/20:5` (`@0xCodez` — a working link for the same source already exists at `LOOP_ENGINEERING_NEWS.md:1322`) and `LOOP_ENGINEERING_NEWS.md:477` (`github.com/openai/symphony`). The auditor claimed a complete pass over all 39 docs and still missed `docs/20:5`, so **"only these two" is unproven** — re-run a full sweep |
| **H7** | `docs/21` is a one-way orphan | small | `grep -rln "21-context-vs-loop-engineering" docs/` → only `docs/index.md`, while `docs/21` links out to seven docs. Add an inbound link from `docs/13` |
| **H8** | `docs/15` duplicates `docs/36` | medium | 26 lines beside `docs/36:26-48`, same ground. Merge, or give it substance worth nav slot 6.3 |
| **H9** | `findings.json` `"schema": 1` is written but never checked; phase numbers collide | small | `fetch-loop-news/SKILL.md:275` writes it; `grep -n schema integrate-loop-news/SKILL.md` → nothing; `findings_valid()` (`run-loop-news.sh:152-157`) reads only `today`. Add a `schema == 1` assertion to Phase 0's abort list. Both skills define a different `## Phase 4`, referenced unqualified from `CLAUDE.md` and `docs/34:319` |
| **H10** | No tag/release step in the pipeline; 15 tags have no release | small | 53 tags, 53 CHANGELOG versions, 38 releases. Missing: `v1.1.0 v1.2.0 v2.0.1 v2.0.2 v2.1.1 v2.1.2 v2.3.1`–`v2.3.9`. Needs **D2** |
| **H11** | Structural review (Phase 4b/4c) has caught none of H5/H7/H8 across ~20 runs | small | The review is mandated after every run by `CLAUDE.md`; three structural defects survived it. Tighten the phase's checklist with concrete queries (orphan check, heading check, duplicate-coverage check) |
| **H12** | Co-resident session-leak security claim: neither verified nor tracked | medium | Exists as one sentence at `LOOP_ENGINEERING_NEWS.md:125`; `grep -rn 'co-resident' docs/ KB_GAPS.md` → nothing, and `docs/19` has no session-isolation content. At minimum log it in `KB_GAPS.md`; ideally reproduce with a two-session test and publish the finding *or its refutation* |
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
| 8 | **C1** + **H1** — the 14-doc fact-check, version stamps folded in | One commit per doc, each gated on `--strict` |
| 9 | **C5**, **C8**, **C9**, **C11**, **C12** — new content and source revalidation | Resource-review rule (score ≥ 3.0 before extracting) |
| 10 | **H2**–**H9**, **H11**, **H12** — corpus hygiene | — |
| 11 | **C7**, **C10** — the two large sweeps | — |
| 12 | **D2**/**H10**, **D3**/**H13** — release policy and plan archival | — |

> **Status 20260905:** steps 1–7 are shipped (`v3.0.1`, `v3.1.0`, PR #36). **The next task is
> step 8 — C1 + the remainder of H1.** The paragraph below is retained as the reasoning that
> ordered automation ahead of content; that ordering is now spent.

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
