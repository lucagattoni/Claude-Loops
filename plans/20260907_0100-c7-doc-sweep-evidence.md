# C7 — evidence pack for the 23-doc fact-check sweep

**Status: discovery complete, adjudication in flight.** Written so the sweep is not re-run.

## 1. What the scope actually was

The backlog names 20 "partially-verified" docs. Two (`11`, `23`) were excluded — `CLAUDE.md` records
them as swept on 2026-09-06 — and H1's remainder (`05 06 19 31 35`) folded in, giving **23 docs**.

The real scope is not "23 docs" but the part of them nobody had checked. Only content added on or
after **2026-09-04** had been verified, so every earlier line was unverified. Measured with
`git blame` per line: **4,025 of 6,010 lines (67%)**. Two docs sit at the extremes — `docs/19` is
**100%** unverified (never touched), `docs/35` is **0%** (written entirely after the cutoff, so it
needed only H1's version stamps).

## 2. Coverage, per unit

| Unit | Part | Lines | Pre-09-04 | Claims checked | URLs opened | Findings |
|---|---|---|---|---|---|---|
| `24[351-700]` | I | 302 | 302 | 19 | 14 | 4 |
| `24[1-350]` | I | 253 | 253 | 38 | 34 | 6 |
| `09[141-365]` | II | 225 | 225 | 20 | 2 | 4 |
| `24[701-1000]` | I | 201 | 201 | 22 | 27 | 7 |
| `08[251-487]` | II | 188 | 188 | 14 | 9 | 3 |
| `32[181-360]` | II | 180 | 180 | 32 | 24 | 5 |
| `34[171-344]` | I | 170 | 170 | 14 | 8 | 7 |
| `07[1-230]` | II | 167 | 167 | 17 | 14 | 4 |
| `32[1-180]` | II | 162 | 162 | 28 | 11 | 4 |
| `33[1-190]` | II | 162 | 162 | 14 | 9 | 3 |
| `32[361-520]` | II | 145 | 145 | 36 | 24 | 9 |
| `12[1-160]` | II | 144 | 144 | 32 | 27 | 7 |
| `34[1-170]` | I | 140 | 140 | 14 | 9 | 1 |
| `05` | II | 125 | 125 | 17 | 8 | 7 |
| `25` | I | 122 | 122 | 11 | 11 | 4 |
| `12[161-304]` | II | 119 | 119 | 22 | 8 | 5 |
| `07[231-464]` | II | 107 | 107 | 25 | 9 | 3 |
| `28` | II | 105 | 105 | 13 | 5 | 5 |
| `01` | I | 103 | 103 | 14 | 9 | 6 |
| `33[191-387]` | II | 100 | 100 | 22 | 19 | 5 |
| `26` | I | 97 | 97 | 23 | 15 | 1 |
| `09[1-140]` | II | 95 | 95 | 23 | 6 | 4 |
| `13` | II | 88 | 88 | 21 | 18 | 2 |
| `14` | I | 79 | 79 | 21 | 18 | 4 |
| `08[1-250]` | II | 67 | 67 | 19 | 4 | 5 |
| `21` | I | 67 | 67 | 6 | 5 | 2 |
| `06` | II | 65 | 65 | 9 | 6 | 2 |
| `31` | II | 62 | 62 | 14 | 9 | 4 |
| `19` | II | 61 | 61 | 12 | 11 | 5 |
| `17` | I | 34 | 34 | 23 | 14 | 2 |
| `18` | II | 33 | 33 | 11 | 45 | 1 |
| `24[1001-1172]` | I | 32 | 32 | 14 | 25 | 4 |
| `15` | II | 25 | 25 | 17 | 4 | 0 |
| `35` | II | 0 | 0 | 19 | 10 | 4 |
| **Total** | | | **4025** | **656** | **471** | **139** |

**34 of 34 units returned; zero lost.** 656 claims examined,
471 distinct external URLs actually fetched, 139 findings, and
**47 claims recorded as UNVERIFIABLE** rather than silently dropped or asserted false.

The URL number is the one to compare against history: an earlier pass in this repo left **78 of 98**
cited URLs unopened while reporting its docs covered. This one opened 471.

## 3. What kind of defect this sweep finds

C10 (the changelog sweep) found the KB **stale against a moving platform**. C7 finds something
different and worse: **the KB's own sourcing discipline failing**. The dominant classes:

| Class | n |
|---|---|
| `CORRECT` | 71 |
| `ADD_CITATION_LINK` | 22 |
| `ADD_VERSION_STAMP` | 19 |
| `RESTRUCTURE` | 12 |
| `ADD_MISSING_FACT` | 8 |
| `REMOVE` | 7 |

Worked examples, each verified before being raised:

- **A blockquote attributed to an article that never contained it.** `docs/24:380` credits
  *"Verification closure creates reliability; reliability creates scalability"* to a named piece.
  The words *reliability*, *scalab* and *closure* appear nowhere in it — not in the live page, and
  not in a Wayback snapshot from **2026-06-18**, five days *before* the KB committed the line. So
  this is not a source that changed after capture; the quote was never there.
- **A table stating the opposite of the cited repo.** `docs/24:856` says a `directive` steer
  *cancels* the current subtask; the repo's own README shows it *continues* the in-flight job. The
  adjacent "risks ledger corruption" warning names a ledger the tool does not have.
- **A figure absent from its cited source.** "3–5 prompt refinement cycles" is not in the
  Anthropic page cited for it.
- **A model misattribution.** `docs/32:195` credits an Anthropic result to the wrong model version.

## 4. Method, and its stated limits

34 per-doc-section finders (Sonnet, blame-scoped to the unverified lines) → per-doc re-verification
against the worktree → adversarial refutation, **two lenses on every proposed removal**
(over-correction + source-fidelity) → one Opus adjudicator → one Opus completeness critic.

**The removal bar is deliberately high.** This repo has already shipped an over-correction that
stripped a *true* claim after checking two of the four sources carrying it. So every removal must
check the source **as of the KB's capture date** — `git log` the line, then fetch that dated
version or a pre-commit Wayback snapshot. Both removals inspected by hand did exactly that.

**Limits.** The find pass ran against `main`, which did not yet carry this branch's 29 C10 edits,
so a few findings duplicate work already done — the finalise stage drops those by anchor mismatch
rather than force-fitting them. Four session limits interrupted this work; the find stage was
restructured to bank discovery *before* spending on refutation, which is why 34/34 units survive.

## 5. Do not re-derive

- The 47 UNVERIFIABLE claims are in the run artifact. They are **not** "false" — they are claims no
  fetch settled. Read them before re-searching any of them.
- Per-unit `verifiedClean` notes record what each finder checked and found **correct**, with sources.
  That is the half of a sweep normally thrown away, and it is what stops the next pass re-checking
  13 arXiv citations, the Terminal-Bench figures, or the Anthropic harness articles.
