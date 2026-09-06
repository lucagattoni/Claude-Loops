# RESUME — backlog step 10 (corpus hygiene)

**Started** 20260906 14:14 UTC · branch `20260906_1414-step10-corpus-hygiene` · base `6619d49`

## Scope
Backlog `plans/20260904_2053-open-work-backlog.md` §8 step 10. Open items are **H4, H5, H6, H7,
H8, H9, H11, H12** — H2 and H3 are already shipped (PR #38, v3.1.3); CLAUDE.md's "H2–H9" is loose.

## Done so far
- Worktree created; baseline `mkdocs build --strict` exits 0.
- CI watcher armed (Monitor, persistent).
- Peer session `Claude Loops: review open work` consulted — reports empty file set, no conflict.
- Investigation workflow run `wf_950e5037-5e0` launched: 9 investigators → adversarial verify →
  Opus adjudication.

## Verified facts (checked against 6619d49, not taken from the backlog or the peer)
- `docs/17` has **37** data rows and **0** `##` headings. Backlog says 33, peer said 38 — both wrong.
- `docs/20:5`'s `@0xCodez` is **already** a proper markdown link. H6's first half is done.
- `docs/21` already has real inbound links from `docs/17` and `docs/04` — H7's premise is likely stale.
- `scripts/run-loop-news.sh:266` **already** asserts `d.get("schema") != 1`. H9's wrapper half is done;
  the `integrate-loop-news` Phase 0 abort list is the part that may still be open.
- `KB_GAPS.md` "Claims Awaiting Verification" rows are `| **V##** | claim | how to settle |`;
  highest is **V18**, so H12's entry is **V19**. Sixteen live entries (V10, V16 settled).
- `CLAUDE.md` is **158** lines — already over the ~150 guardrail. Trim, don't add.
- `docs/news.md`, `docs/changelog.md`, `docs/sources.md` are **symlinks** to the repo-root files.

## Hard constraints
- Repo is **PUBLIC** — PRIMARY CHECK on every file before every commit.
- `LOOP_ENGINEERING_NEWS.md` is **append-only** history; do not rewrite past digest entries.
  Any hand-authored `##` header must start with a **word**, not a digit.
- Do not prune `KB_GAPS.md`'s "Claims Awaiting Verification" section, and do not derive search
  keywords from it.
- Standing gate, run **bare** as the last step before each commit:
  `uv run --with-requirements requirements-docs.txt mkdocs build --strict`
  plus `bash scripts/check-digest-freshness.sh` if the digest is touched.
- The tracker lands on `main` at 04:00 UTC daily — a PR open across that needs a rebase.
- Close the backlog items and correct `CLAUDE.md` in the SAME PR as the work.

## Next command
Read the workflow ruling, then apply approved changes one commit per item, pushing each.
