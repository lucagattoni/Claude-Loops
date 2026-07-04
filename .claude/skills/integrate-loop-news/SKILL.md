---
name: integrate-loop-news
description: Integrate + restructure step of the daily loop-engineering tracker — consumes .loop-news/findings.json from fetch-loop-news, writes the digest, integrates each finding into the KB, runs the structural reviews, cuts a release, commits, and pushes to main.
---

Integrate today's findings into the knowledge base and publish.

This is the **KB-reasoning half** of the tracker. It consumes the findings artifact
produced by `fetch-loop-news`, decides how each finding maps into the KB, restructures the
KB for coherence (the two review passes), determines the release tier, commits, and pushes
to `main`. It does **no** searching — everything it needs is in `.loop-news/findings.json`.

## Phase 0 — Load the handoff artifact

1. Read `.loop-news/findings.json`.
2. **Abort with a clear error** if the file is absent, is not valid JSON, or its `today`
   field does not equal the current UTC date (`TZ=UTC date '+%Y-%m-%d'`). A stale or
   missing artifact means the search half did not complete this run — do not proceed, and
   do not commit anything. Print what was wrong so the wrapper's logs show it.
3. Extract `today`, `run_time`, `last_run_date`, `findings`, `sources_to_consider`, and
   `source_updates`. Use these throughout — never re-derive the time or re-search.
4. **Already-published check — do this before reading any docs or reasoning about the
   KB.** Run `git fetch origin main`, then
   `git log --oneline --grep="loop news run ${run_time}" origin/main` (the `run_time`
   just extracted; use `--fixed-strings` if your git wraps `--grep` in a way that treats
   it as a regex, since `run_time` contains no regex metacharacters but there's no reason
   to rely on that). Check against `origin/main`, not just local history — a different
   worktree or process may have already published this exact run without your local
   checkout knowing yet, and a local-only check would miss that. Do not cap the log
   depth — an arbitrary limit could miss the match on a day with several unrelated
   commits. If it returns a match, this exact run has already been integrated and pushed
   — **stop immediately, print which commit, and make no changes.** This can happen if
   `fetch-loop-news` already carried the pipeline through on its own (a known failure
   mode when the two-session split gets collapsed) or if this skill is re-invoked by
   mistake against an artifact that was already consumed. Do this check first, cheaply —
   don't rediscover it the slow way by reasoning through git evidence later.

## Phase 4 — Write digest

1. Take the `findings` array from the artifact (already merged and scored by
   `fetch-loop-news`).
2. Deduplicate: remove any item whose `url` already appears in `LOOP_ENGINEERING_NEWS.md`.
3. Insert a new section immediately after the initial `---` separator (so the
   newest run always appears at the top). The format:

```markdown
## YYYY-MM-DD HH:MM UTC (run)

### New findings

| Tier | Source | Title | URL | Summary |
|---|---|---|---|---|
| 1 | @handle | "Title" | [link](url) | Summary sentence |

### No new content
- Actor — reason (e.g. no keyword matches found in their posts)

### Docs updated this run
- (list any docs/ changes made below)

### Sources to consider adding to SOURCES.md
- (list any newly surfaced actors worth tracking)

---
```

Use `run_time` from the artifact for the `YYYY-MM-DD HH:MM UTC` header.

If zero new findings after deduplication, write the section with an empty findings
table and list all sources under "No new content". Never skip the section.

4. For each item in "New findings", assess whether it introduces a **new concept,
   technique, or tool** not yet present in any `docs/*.md` file:
   - Read the relevant `docs/*.md` files to check coverage
   - New concept → create `docs/<NN-topic>.md` and add a row to `LOOP_ENGINEERING.md`.
     **Link to the published Pages URL, not the repo path** (the index routes readers to
     the 3-column site): `| N | [Topic](https://lucagattoni.github.io/Claude-Loops/<NN-topic>/) | One-sentence summary |`
     (MkDocs uses directory URLs, so `docs/04-verification.md` → `.../04-verification/`).
     Also add the page to the `nav:` in `mkdocs.yml` under the right numbered chapter.
   - Updates existing concept → edit only that `docs/<NN-topic>.md`
   - Already fully covered → no doc changes needed

5. **Reading list curation** — after KB doc writes, evaluate new findings against
   `docs/32-reading-list.md`:

   a. Read `docs/32-reading-list.md` to understand the current entries and groups.

   b. For each new finding that is a **full article or GitHub repo** (not an X post
      or a short thread); GitHub repos with substantial documentation count and go
      into the *Reference Implementations* group:
      - Determine which reading list group it fits. Current groups:
        *Why Loops* / *Getting Started* / *Harness Design & Architecture* /
        *Goal Engineering & Stopping Conditions* / *Loops in Production* /
        *Reference Implementations* — or a **new group** if the topic isn't covered.
        Reference implementations (GitHub repos, sample codebases) belong in
        *Reference Implementations*, not in article groups.
      - Ask: does this article offer something the existing entries in that group do not?
        Strong signals for inclusion: quantified claims, authoritative source (official
        Anthropic engineering, creator of a major tool), unique technique not documented
        elsewhere in `docs/`, or a real-world case study with outcome data.
      - Weak signals (skip): restatement of concepts already well-covered, no original
        contribution, promotional without substantive content.

   c. **Add** the article if it clears the bar. Write the full entry format:
      ```
      ### [Title](url) — Author
      **Added:** YYYY-MM-DD · **Published:** Mon YYYY

      **Why here:** One or two sentences on what uniquely earns this article a place —
      what it offers that existing entries in this group do not.

      **Summary:** 3–5 sentences covering the article's key claims, data points,
      patterns, or techniques.
      ```

   d. **Remove or replace** — if adding an article would push a group past ~4 entries,
      remove the weakest existing entry in that group (the one with the least unique
      contribution relative to the rest of the KB). A group should never exceed 5
      entries; the list must stay slim.

   e. **New groups** — if a new finding covers a topic not represented by any existing
      group (e.g. "Fleet Engineering at Scale", "MCP Security"), add a new `##` group
      section with a one-sentence description before the first entry.

   f. Record any reading list changes in "Docs updated this run":
      `- docs/32-reading-list.md — added "<title>"; removed "<title>" (replaced)`

6. **Apply source suggestions** — using `sources_to_consider` and `source_updates` from
   the artifact:
   - For each `sources_to_consider` actor that published 2+ relevant pieces and has
     meaningful engagement, add a row to `SOURCES.md` under the appropriate type, and
     list it under the digest's "Sources to consider adding to SOURCES.md".
   - For each `source_updates` entry (a discovered feed URL, or a low-yield keyword
     refinement), apply it to the relevant `SOURCES.md` row so future runs search better.

7. **KB gap tracking** — after all doc writes, update `KB_GAPS.md` to record which
   areas of the KB are currently thin or missing:

   a. Read `KB_GAPS.md` (create it if it doesn't exist).
   b. Review all existing `docs/*.md` for completeness. Topics that are thin:
      - Only 1-2 sentences on a concept that warrants deeper coverage
      - Cross-references that say "see X" but X is thin too
      - A failure pattern that lacks a concrete fix mechanism
   c. For each gap, write one line in `KB_GAPS.md`:
      ```
      - <topic>: <what's missing> — search keywords: <2-3 specific keyword phrases>
      ```
   d. Remove gaps that were filled by this run's doc writes.
   e. **These keywords are inputs to future github-search and web search queries.**
      The goal is iterative deepening: each run identifies what's still thin and
      provides targeted keywords so the next run searches more specifically.

   Example `KB_GAPS.md` entry:
   ```markdown
   # KB Gaps — topics needing deeper coverage

   - Fleet coordination protocols: STATE.md multi-loop coordination needs an
     example implementation — search keywords: "state machine" "agent coordination"
     "claude code" fleet
   - Verifier tuning techniques: criteria for distinguishing Verifier Theater from
     genuine passing — search keywords: "agent evaluator" "verification criteria"
     "LLM judge" calibration
   ```

8. Update `CHANGELOG.md` under `[Unreleased]` for any doc additions or changes.

## Phase 4b — Devil's Advocate KB Review

After all per-finding doc writes are done, apply a **devil's advocate** lens to the
knowledge base — assume each change you just made could be wrong, incomplete, or
subtly inconsistent, and look for evidence of that.

This is not about individual findings — it is about whether the docs still form a
coherent, well-structured, internally-consistent body of knowledge.

### Devil's advocate questions

**Assume each doc update is wrong. Ask:**

1. **Internal contradictions** — Does anything written this run conflict with claims
   in other docs? (Example: a new token cost number that differs from a figure in
   docs/11; a new failure pattern that is the same as an existing one under a
   different name.) Fix the contradiction; prefer the more specific, cited source.

2. **Missing cross-references** — Is there any doc that now references a concept
   that lives in another doc, without a link? A reader who needs the concept should
   never have to search for it. Add the link.

3. **Unverifiable claims** — Did any edit introduce a pattern, metric, or technique
   attributed to a repo or post, but the source does not actually say this? Remove
   or flag it.

4. **Better placement** — Is there content now in doc X that belongs more naturally
   in doc Y (which already covers the parent topic)? A well-structured KB has one
   canonical place per concept.

5. **Redundancy** — Is any new section nearly identical to existing content in
   another doc? If yes, consolidate: keep the canonical version, replace the
   duplicate with a cross-reference.

**Structural coherence:**

6. **Grouping**: Does `LOOP_ENGINEERING.md` still organise topics logically? New
   docs added this run — do they belong in an existing section or warrant a new one?

7. **Staleness**: Do any existing doc summaries in the index no longer reflect the
   doc's current content (because it was extended this run)? Update the summary.

8. **Progression**: Does the ordering within each section still reflect the logical
   reading sequence — from foundational to advanced? Reorder if needed.

9. **Fragmentation**: Is any concept now split across 3+ docs without a canonical
   home? Consider merging thin docs or designating one as primary.

**Apply the minimum change that resolves each issue found.** Restructuring the index
counts as a MAJOR release (see Phase 5). Adding cross-reference lines or updating
summaries counts as PATCH.

## Phase 4c — Findings-Driven Structural Review (the norm after every run)

Phase 4b checks whether *this run's edits* stayed consistent. Phase 4c is broader and
**mandatory after every run**: read **all of this run's findings as a single set** and
ask whether the body of knowledge should be *re-thought and restructured* in light of
them — not whether any single finding needs a home.

Treat the findings as evidence, not instructions. The same critical posture applies to
**direction the user gives during the review**: pressure-test it against the findings
before adopting it; if the evidence contradicts or refines what was suggested, say so
and propose the better framing rather than complying silently.

### The design spine

The KB's central organizing principle is the **loop-design process** — the five
questions every loop must answer: **What? / How? / When? / How much? / How do you know
it's done?** (mapped to the Loop Contract's SCOPE / ACTION / TRIGGER / BUDGET /
STOP+verifier; see [docs/27](../../../docs/27-loop-contract.md)). When evaluating
structure, ask whether the docs still make this design process easy to find and follow,
and whether each new theme strengthens or muddies one of these five questions.

### Structural questions (ask of the run as a whole)

1. **Dominant theme without a canonical home.** Did one concept recur across many of
   this run's findings (e.g. ≥3 findings touch it) while being scattered across many
   docs with no single canonical owner? If so, *designate a canonical home* (an existing
   doc that already owns the parent topic) and consolidate the taxonomy/definition there,
   adding cross-references from the others — do **not** spin up a new doc that fragments
   it further.

2. **Missing thesis.** Did the findings converge on a framing claim the KB never states
   outright (e.g. "the harness matters more than the model")? Add it to the doc that owns
   that level of abstraction (usually [docs/01](../../../docs/01-paradigm-shift.md)).

3. **Unrepresented primitive.** Did the findings name a first-class concept the KB only
   ever mentions in passing (e.g. observability)? Give it a real section in the doc that
   owns the relevant lens.

4. **Centrality drift.** Has the index drifted so the design spine is buried under
   component/scaling detail? If so, re-emphasise design centrality in
   `LOOP_ENGINEERING.md`'s intro and the relevant summaries.

5. **Reorder or merge.** Do the findings reveal that two docs now overlap heavily, or
   that a section's reading order no longer goes foundational → advanced? Merge or
   reorder.

### Output

- Apply the **minimum structural change** that resolves each issue; prefer consolidation
  and canonical-home designation over new docs.
- Record every structural change in the digest's "Docs updated this run" list with a
  one-line rationale (what the finding-set revealed, what you changed).
- Index restructures, doc merges, renames, or reorderings are **MAJOR** (see Phase 5);
  new canonical sections + cross-refs + summary updates are MINOR/PATCH.

## Phase 5 — Release determination, commit, and publish

After all Phase 4 writes are complete:

### 5a — Determine release tier

Count the outputs of this run:
- **M** = number of new `docs/*.md` files created
- **U** = number of existing `docs/*.md` files updated
- **N** = number of new findings added to the digest

Apply this decision table:

| Condition | Release tier |
|---|---|
| Any existing doc removed or renamed, or `LOOP_ENGINEERING.md` restructured | **MAJOR** |
| M ≥ 1 (at least one new doc file created) | **MINOR** |
| M = 0 and U ≥ 1 (existing docs updated, none new) | **PATCH** |
| M = 0 and U = 0 and N ≥ 1 (findings only, no doc changes) | **PATCH** |
| N = 0 and M = 0 and U = 0 (nothing changed) | **None** — skip commit |

### 5b — Cut a release if warranted

For **MINOR** or **PATCH** releases:
1. Read the most recent versioned section header in `CHANGELOG.md` (format `## [X.Y.Z]`) to determine the current version.
2. Increment it: MINOR bumps Y and resets Z to 0; PATCH bumps Z only.
3. In `CHANGELOG.md`, rename `## [Unreleased]` to `## [X.Y.Z] — <today's date> <TZ>` (the new version) and add a fresh `## [Unreleased]` section above it with empty `### Added` and `### Changed` subsections.

For **MAJOR** releases: leave `[Unreleased]` in place and note the major change there — major releases require a manual decision.

For **None**: skip all changelog changes and skip the commit entirely (do not push).

### 5c — Commit and push

Stage the KB content files (note: **includes `mkdocs.yml`** — Phase 4 edits its `nav:` —
and does **not** stage the skills, which are feature-managed via PR):
```bash
git add LOOP_ENGINEERING_NEWS.md LOOP_ENGINEERING.md SOURCES.md CHANGELOG.md KB_GAPS.md mkdocs.yml docs/
git commit -m "feat: loop news run <run_time> — <N> findings, <M> new docs [<tier>]"
git push origin HEAD:main
```
Where `<tier>` is the release tier (e.g. `minor`, `patch`, or `none`). Omit `[none]` from
the message when tier is None (but in that case the commit is skipped anyway).

The push publishes the run. It is the pipeline's final, atomic step — everything above
must succeed first. (When run under `scripts/run-loop-news.sh` the push is a fast-forward
onto `main`; the wrapper handles worktree teardown and primary-checkout alignment.)
