# C10 — evidence pack for the changelog sweep

**Status: discovery complete, adjudication in flight.** Written so the sweep does not have to be re-run.

## 1. What was swept, and the proof it was

The range the 2026-07-16 pass left unswept: `0.2.21`–`2.1.199`, **plus** `2.1.261`+ (that
pass covered `2.1.200`–`2.1.260`). Split into 24 chunks; one agent read each chunk in full and
reported its own bullet count, which was compared against a count taken independently by script.

| Chunk | Expected | Read | Candidates |
|---|---|---|---|
| `0.2.21..1.0.30` | 150 | 150 | 95 |
| `1.0.31..1.0.97` | 150 | 150 | 105 |
| `1.0.106..2.0.30` | 154 | 154 | 103 |
| `2.0.31..2.0.70` | 156 | 156 | 89 |
| `2.0.71..2.1.0` | 150 | 150 | 63 |
| `2.1.2..2.1.20` | 167 | 167 | 95 |
| `2.1.21..2.1.45` | 154 | 154 | 103 |
| `2.1.46..2.1.59` | 153 | 153 | 114 |
| `2.1.61..2.1.70` | 164 | 164 | 110 |
| `2.1.71..2.1.76` | 176 | 176 | 103 |
| `2.1.77..2.1.83` | 208 | 208 | 108 |
| `2.1.84..2.1.90` | 168 | 168 | 98 |
| `2.1.91..2.1.98` | 163 | 163 | 109 |
| `2.1.101..2.1.111` | 177 | 177 | 116 |
| `2.1.112..2.1.119` | 178 | 178 | 117 |
| `2.1.120..2.1.129` | 176 | 176 | 104 |
| `2.1.131..2.1.139` | 151 | 151 | 81 |
| `2.1.140..2.1.144` | 181 | 181 | 116 |
| `2.1.145..2.1.153` | 150 | 150 | 88 |
| `2.1.154..2.1.162` | 157 | 157 | 99 |
| `2.1.163..2.1.178` | 170 | 170 | 115 |
| `2.1.179..2.1.193` | 156 | 156 | 103 |
| `2.1.195..2.1.261` | 164 | 164 | 97 |
| `2.1.263..2.1.263` | 1 | 1 | 0 |
| **Total** | **3774** | **3774** | **2331** |

**3774 of 3774 bullets, 24 of 24 chunks, zero count mismatches.** Coverage is the one thing
this pass can assert without hedging — every chunk's reported read equals its measured size.

## 2. Verdict distribution (520 verified rows)

| Verdict | n |
|---|---|
| `KB_GAP` | 319 |
| `KB_CORRECT_NO_ACTION` | 86 |
| `DROP_NOT_RELEVANT` | 54 |
| `DROP_SUPERSEDED` | 45 |
| `KB_STALE` | 10 |
| `KB_WRONG` | 6 |

**Read this honestly.** 319 `KB_GAP` does not mean 319 defects — it means the KB is silent on
319 platform changes, and silence is usually right. A doc is a curated argument, not a changelog
mirror. The valuable rows are the **16** where the KB actively misleads.

## 3. The 16 rows where the KB is wrong or stale

| # | Verdict | Version | Doc | Sev | What |
|---|---|---|---|---|---|
| 1 | `KB_STALE` | `1.0.90` | `docs/08-permissions.md` | medium | The 1.0.90 blanket claim is now an oversimplification; the real (narrower) rule is undocumented |
| 2 | `KB_WRONG` | `2.1.0` | `docs/08-permissions.md` | high | Permission pattern-token table is stale and asserts an unconfirmed `?` token |
| 3 | `KB_WRONG` | `v2.1.3` | `docs/12-hooks.md` | high | Hook timeout table is wrong for command, http, AND mcp_tool hooks |
| 4 | `KB_STALE` | `v2.1.9` | `docs/12-hooks.md` | high | additionalContext is documented as Stop/SubagentStop-only, but it's now general |
| 5 | `KB_STALE` | `v2.1.20` | `docs/29-background-agents.md` | medium | Doc describes background agents as fire-and-forget with prompts surfacing only mid-run — a pre-launch prompt changes that |
| 6 | `KB_WRONG` | `2.1.49` | `docs/08-permissions.md` | high | Settings-precedence section has the managed-policy override direction backwards |
| 7 | `KB_WRONG` | `2.1.49` | `docs/12-hooks.md` | high | Hooks doc's own scope hierarchy has the same managed-policy-last error |
| 8 | `KB_WRONG` | `v2.1.69` | `docs/12-hooks.md` | high | TeammateIdle/TaskCompleted's continue:false stops one teammate, not the whole session — doc12 states the opposite scope |
| 9 | `KB_STALE` | `2.1.98` | `docs/09-headless-mode.md` | low | --exclude-dynamic-system-prompt-sections is documented but carries no version marker |
| 10 | `KB_WRONG` | `2.1.105` | `docs/12-hooks.md` | high | docs/12's hook table says PreCompact cannot block — it can, since v2.1.105 |
| 11 | `KB_STALE` | `2.1.136` | `docs/15-explore-plan-implement.md` | medium | Plan mode's write-block guarantee had a bypass via allow rules, pre-2.1.136 |
| 12 | `KB_STALE` | `2.1.178` | `docs/08-permissions.md` | medium | Tool-parameter permission syntax documented but not version-stamped |
| 13 | `KB_STALE` | `2.1.169` | `docs/09-headless-mode.md` | low | `--safe-mode` documented correctly but missing its version marker |
| 14 | `KB_STALE` | `v2.1.261` | `docs/08-permissions.md` | medium | Missing latest row in the KB's own versioned rm-rf safety-prompt table |
| 15 | `KB_STALE` | `v2.1.199` | `docs/12-hooks.md` | low | Hooks that can't block still silently hid stderr on exit 2, until v2.1.199 |
| 16 | `KB_STALE` | `v2.1.261` | `docs/09-headless-mode.md` | low | File-based variant of an already-documented flag is missing |

### The one to read first — a security-relevant error, in two docs

`docs/08:480-487` and `docs/12:251-257` both list settings/hook sources as *"later overrides
earlier"* with **managed policy first** — which makes org policy the *weakest* source and CLI
flags the strongest. That is backwards. Verified against
[the official settings page](https://code.claude.com/docs/en/settings), fetched 2026-09-07:

> When the same key appears in more than one place, Claude Code uses the value from the highest
> level that sets it. The stack below shows the levels, **highest on top** [...]
> In order, highest precedence first:
> **Managed settings** [...] Nothing you set overrides them

Correct order, highest first: **Managed → command line (incl. `--settings`) → project local →
shared project → user.** The KB has the lower four in the right relative order and managed at the
wrong end. Two further facts the KB omits and this page states: **list keys such as
`permissions.allow` merge rather than override**, and for a few security-sensitive keys a
*stricter* value from a lower level beats a managed one.

## 4. Method, and what it cost

24 chunk sweepers (Sonnet) → 24 verifiers, each doing supersession-grep + KB-grep + verdict
(Sonnet) → 90 adversarial refuters (Sonnet) → 1 adjudicator + 1 completeness critic (Opus).
Per-doc triage was added after the first run showed the sweepers returning ~100 candidates per
chunk — too many for any verifier to treat rigorously.

**Two honest limitations.**
1. A refutation cap of 90 was applied to 335 actionable findings; 245 reached triage with no
   refuter. They are marked, not hidden.
2. The run was killed twice by session limits. 43 refuters and the first adjudicator died. The
   sweep and verify stages are complete and cached; the loss was in refutation depth, not coverage.

## 5. Do not re-derive

- The full 520-row verified set and the per-doc split are reproducible from this run's journal;
  the sweep costs ~9M tokens to repeat and should not be.
- The corrected `2,076` → `5,132` denominator is proved in §6 below; three of the prior pass's four
  counts reproduce exactly, only the total is wrong.

---

## 6. The prior sweep's "2,076 bullets" is wrong — and the backlog inherited it

### What the digest claims
`LOOP_ENGINEERING_NEWS.md:644-649` (the 2026-07-16 run's "The changelog pass" section):

> The full Claude Code changelog was fetched raw and filtered **locally** — 620KB, 385 versions,
> 2,076 bullets.
>
> | Stage | Bullets |
> | All | 2,076 |
> | Topic-relevant, de-noised | 643 |
> | Added / Changed / Removed, v2.1.200+ | **187** |
>
> The noise is overwhelmingly `Fixed` (2,740 across all history). The signal concentrates in
> `Removed` — only **35 in the entire project history** — and `Changed` (168).

### The contradiction is inside that same passage
`2,740 Fixed` alone exceeds the stated total of `2,076`. Adding the `Changed` (168) and `Removed`
(35) it names gives **2,943** — already 42% more than the total the table asserts.

### Measured, reproducibly
The file was reconstructed as it stood at **385 versions** (today's file minus `2.1.261` and
`2.1.263`, the only two added since) and counted with `^- ` top-level bullets:

| Category | Then (385 versions) | Digest said |
|---|---|---|
| `Fixed` | **2,740** | 2,740 ✓ |
| `Changed` | **168** | 168 ✓ |
| `Removed` | **35** | 35 ✓ |
| uncategorised | 1,137 | — |
| `Added` | 556 | — |
| `Improved` | 457 | — |
| `Updated` | 30 | — |
| `Deprecated` | 9 | — |
| **All** | **5,132** | **2,076 ✗** |

Three of the four stated counts reproduce **exactly**. Only the total is wrong, and `2,076` matches
no natural subset either: non-`Fixed` = 2,392; non-`Fixed`-non-`Improved` = 1,935;
`Added`+`Changed`+`Removed` = 759.

Today (387 versions): **5,200** bullets, `Fixed` **2,767**.

### Why it matters
The backlog prices C10 as "187 of 2,076 bullets reviewed" — implying ~1,889 unswept. The real
unswept range (`0.2.21`–`2.1.199` plus `2.1.261`+) is **3,774 bullets across 335 versions**. The
task was **~2x** what the backlog costed, and the "2,076" figure made the remaining work look
half-done when it was under a quarter done.

### Where the wrong number is recorded
| File | Line | Note |
|---|---|---|
| `LOOP_ENGINEERING_NEWS.md` | 644 | prose: "620KB, 385 versions, 2,076 bullets" |
| `LOOP_ENGINEERING_NEWS.md` | 649 | table row: `\| All \| 2,076 \|` |
| `LOOP_ENGINEERING_NEWS.md` | 714 | "2,076 bullets exist across 385 versions" |
| `CHANGELOG.md` | 792 | "620KB, 385 versions, 2,076 bullets" |
| `plans/20260904_2053-open-work-backlog.md` | 520 | "187 of 2,076 bullets reviewed, across 385 versions" |
| `plans/20260904_2002-v3-fact-check-gaps.md` | 95 | "only `v2.1.200`-`v2.1.260` (187 of 2,076" |

**How to correct each.** `LOOP_ENGINEERING_NEWS.md` and `CHANGELOG.md` are append-only history —
per the H4 precedent, they are corrected by a NEW hand-authored entry, never rewritten in place.
The new entry's header must begin with a **word**, not a digit, or `check-digest-freshness.sh` and
`fetch-loop-news` will both read it as a real tracker run. The two `plans/` files are working
documents and are corrected in place, per "record the correction in place rather than quietly
deleting it".

The `620KB` and `385 versions` figures were both correct; only the bullet count was not.
