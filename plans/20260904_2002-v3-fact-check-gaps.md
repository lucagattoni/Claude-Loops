# Handover — Fact-Check Coverage Gaps After v3.0.0

**Written** 20260904 20:02 UTC · session that shipped [`v3.0.0`](https://github.com/lucagattoni/Claude-Loops/releases/tag/v3.0.0)
**For:** the next agent, after this session's context was cleared.
**One line:** `v3.0.0` fixed everything it *checked*. It did not check everything. 14 of 39 docs
were never touched at all; most of the rest only had their *new* content verified.

If you were pointed here from `CLAUDE.md`, start at **§4 — the exact next command**.

---

## 1. Where things stand

`v3.0.0` shipped, merged, tagged, released, verified by artifact (not by CI status), tracker
re-armed. Nothing here is blocking or broken. This file exists because the fact-check work that
release did was **targeted, not exhaustive** — it checked the docs the restructure touched, plus
9 specific claims flagged as suspicious. It never swept the other 30.

Read these first if you need the "why" behind any of this:
- `CHANGELOG.md` → `[3.0.0]` entry — what shipped, including what the release got wrong about
  itself (a fabricated table row it introduced, and an over-correction that stripped a true claim)
- `LOOP_ENGINEERING_NEWS.md` → the `20260904 18:11 UTC (catch-up run)` entry — full method, and its
  own `### Coverage — what was NOT swept` section (superseded in part below — see §2)
- `KB_GAPS.md` → the `claude --worktree <name>` entry — a related, separate gap, already logged

---

## 2. The precise coverage picture

The digest's own Coverage section lists `docs 04, 13, 22, 24, 27, 28, 29, 31, 32` as never
fact-checked. That was accurate when written, but **later commits in the same release** added new
(verified) content to four of those nine — 13, 24, 28, 32 — without re-checking what was already
in those files. This table is the corrected, current picture, derived from
`git diff --name-only 43e86f6 cb4e489 -- docs/` against the full 39-doc set.

### Never touched by v3.0.0 at all (14 docs) — highest priority

| Doc | Title | Why it matters |
|---|---|---|
| `02` | The Core Agent Loop Cycle | Foundational; cites runtime termination signals that may have version-specific mappings |
| `03` | The Six Building Blocks | Names concrete primitives (worktrees, connectors) that move fast |
| `04` | **Verification** | The KB's own "non-negotiable foundation" — highest-value doc in Part I, untouched since before this release's fact-check existed |
| `05` | CLAUDE.md | Documents CLAUDE.md mechanics themselves — a moving platform surface |
| `06` | Skills | Frontmatter fields, `disable-model-invocation`, etc. — exactly the class of fact that broke in docs/07 |
| `10` | Fan-Out | Cites specific hook-based scope-verification patterns |
| `16` | Memory Patterns | Predates **auto memory**, a distinct on-by-default mechanism this release found docs/16 never covered even in its own scope — check whether that gap was closed |
| `19` | MCP Security | Security-relevant; stale advice here has real cost |
| `20` | Loop Maturity Model | Lower risk — mostly conceptual, fewer checkable platform facts |
| `22` | Learned Orchestration | Lower risk — research-summary heavy |
| `27` | **The Loop Contract** | The KB's stated "design spine" — same priority tier as doc 04 |
| `29` | Background Agents | `--bg`, worktree isolation — exactly the surface that changed under docs/07 and docs/39 this release |
| `30` | Goal Engineering | Cites `/goal` readiness gates — check against current `/goal` docs |
| `31` | Claude Tag | Product surface, moves independently of Claude Code CLI releases |

### Touched, but only the *new* content was verified (16 docs) — medium priority

`01, 07, 08, 09, 11, 12, 13, 14, 15, 17, 18, 21, 23, 24, 25, 26, 28, 32, 33, 34` — pre-existing
sentences in these files were **not** re-checked unless they happened to overlap with what an
agent was explicitly told to verify. Treat every version number, flag name, and limit written
*before* 20260904 in these files as unverified, same as the untouched set — the fact-check budget
just wasn't spent there.

Two of these, `07` and `08`, already had 9 specific claims checked (the original round-2
fact-check) — those 9 are solid. Everything else in all 20 files is not.

### Brand new in v3.0.0 (5 docs) — lowest priority

`35, 36, 37, 38, 39` — written and self-verified this release, plus caught by the adversarial
review's quote/version lenses. Not risk-free, but the freshest content in the KB.

---

## 3. Method — reuse what worked, and its two failure modes

The pattern that found 8 stale facts plus a fabricated quote: grep the docs for checkable claims,
fetch the current official page for each, compare, report `WRONG | STALE | UNVERIFIABLE | CORRECT`
with the fix inline. Useful starting greps (adapt per doc):

```bash
cd /path/to/repo
grep -rnE "Haiku|Sonnet|Opus|Fable" docs/ | head -60
grep -rnE "depth [0-9]|cap(ped)? at [0-9]|max(imum)? of [0-9]|default(s)? to" docs/ | head -60
grep -rnE "\-\-[a-z-]+" docs/18-quick-reference.md
grep -rn "v2\.[0-9]+\.[0-9]+" docs/*.md
```

For the Claude Code changelog specifically: **the full raw file from this session lived in a
scratchpad directory that no longer exists.** Re-fetch it:

```bash
curl -sL https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md -o /tmp/CC_CHANGELOG.md
```

`code.claude.com/docs/en/changelog` only renders `v2.1.235` and up — use the raw GitHub file for
anything earlier. **This release's own pass covered only `v2.1.200`–`v2.1.260` (187 of 2,076
bullets, filtered from 385 versions).** Everything from `0.2.21` through `v2.1.199` — the large
majority of the project's history — has never been examined for KB relevance.

**Two failure modes this release hit, in opposite directions — guard against both:**

1. **A fabricated claim can ship.** This release itself invented a table row (a spawn-cap env var
   that doesn't exist) and only caught it because two independent processes — an adversarial
   review lens and a systematic changelog re-read — flagged the same row simultaneously. Never
   write a version number, flag, or limit without a fetched source open in front of you.
2. **An over-correction is the same defect, reversed.** A true claim (`AskUserQuestion`
   auto-continuing since `v2.1.198`) was stripped as "fabricated" after checking only 2 of 4
   available sources (changelog, HN thread — but not the article the HN thread linked, and not
   Anthropic's own `env-vars` reference, which stated the version explicitly). **Before removing
   a claim as unsourced, check every source that could plausibly carry it — not just the first
   two that come to mind.**

WebFetch's page-summarizer is unreliable for exact quotes — it silently truncated content at least
twice this session (a different "earliest version" for the same changelog file, and a dropped
leading clause on a quote). Prefer `curl` + a strip-tags pass for anything you plan to quote
verbatim, or fetch the same page twice and diff.

**On agent count:** one Sonnet agent per doc or small cluster, run in parallel via the `Workflow`
tool, is the pattern used throughout `v3.0.0` — see any commit message on the `v3.0.0` branch
history for the exact schema shape (`kb_claim` / `truth` / `verdict` / `fix`). Judge/synthesis
passes over the collected results go to **Opus**, not Sonnet — see the two bullets in the global
`~/.claude/CLAUDE.md` this release added (`Judges and synthesisers are the exception…`).

---

## 4. The exact next command

Paste this to start immediately:

> Read `plans/20260904_2002-v3-fact-check-gaps.md` in the Claude-Loops repo. Run the fact-check
> pattern in §3 against the **14 never-touched docs in §2**, highest-priority ones first (04, 27,
> 05, 06, 16, 29, then the rest). Work in a git worktree per this repo's `CLAUDE.md`. Fix what's
> wrong, commit each doc's fixes separately, run `mkdocs build --strict` as a hard gate before any
> commit, and append a dated entry to `LOOP_ENGINEERING_NEWS.md` when done stating exactly which
> docs were checked and what remains open — the same honesty standard `v3.0.0`'s own digest entry
> set. Delete the "Open work" pointer in `CLAUDE.md` once this file's gap is closed.

---

## 5. Other open items, carried forward unresolved from the v3.0.0 digest

- **X/Twitter** was never fetched directly this release, only searched. One quote the KB attributes
  to Boris Cherny is real but its wording is unstable across reproductions — pin it to a talk
  transcript, not a tweet, if you touch that citation.
- **LinkedIn** was swept for posts only; person-level search was never run.
- One LinkedIn-reported security repro (a co-resident session allegedly handed over another
  session's folder contents on request) could not be independently verified and was deliberately
  excluded from the KB — leave excluded unless you can verify it yourself.
- `claude --worktree <name>` standalone semantics — found, not integrated. Full detail already in
  `KB_GAPS.md`, no need to re-derive.
