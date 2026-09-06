# RESUME — backlog step 9 (C5, C9, C11, C12)

**Branch:** `20260906_1024-step9-c5-c9-c11-c12` · **Base:** `origin/main` @ `49e4a3f` (v3.1.9)
**Started:** 20260906 10:24 UTC

Working the backlog's §8 step 9 from `plans/20260904_2053-open-work-backlog.md`.
C8 is already shipped, so the set is **C5, C9, C11, C12**.

| Item | What it is | State |
|---|---|---|
| **C5** | `docs/16-memory-patterns.md` has zero native auto-memory coverage | evidence gathering |
| **C9** | KB_GAPS gaps 1,3,4,5 have had no targeted search in 8+ weeks | evidence gathering |
| **C11** | `x` rows never read profile timelines; no LinkedIn person-search row | in progress (browser, main loop) |
| **C12** | Four commitments from `plans/20260904_1658-two-pillar-restructure.md` §4b/§4c never delivered | evidence gathering |

## Confirmed before starting (do not re-derive)

- `claude --version` → **2.1.263**. `claude --help` for `--bare` reads: *"Minimal mode: skip hooks,
  LSP, plugin sync, attribution, auto-memory, background prefetches, keychain reads, and CLAUDE.md
  auto-discovery."* — so **auto-memory is a real, CLI-named feature**, and C5 is a genuine gap.
- `~/.claude/projects/<slug>/memory/` directories exist on this machine.
- C12 re-measured at `49e4a3f`, still open: `/ultraplan` → **0 hits** in `docs/`; `BLOCK/WARN` →
  **0 hits**; ClaudeWarp appears in 6 docs but never as a named case study; `CHANGELOG.md`'s only
  Claude-Warp line is about the MkDocs site setup, not the content.
- C9 numbering: the backlog's "gaps 2–5" were numbered against `4ed29ff`, where gap 2 was
  `claude --worktree` — since **filled**. The open set is F0–F3 fleet maturity, effort-vs-tooling,
  cross-model pairing, underspecified-input.

## Next command

Evidence workflow: run id `wf_754beab5-093`.

```
Workflow({scriptPath: ".../workflows/scripts/step9-evidence-wf_754beab5-093.js",
          resumeFromRunId: "wf_754beab5-093"})
```

Its first launch died wholesale on a session usage limit (12/12 agents, 0 cached) and was
relaunched. If it dies again, resume it — completed agents replay from cache. Read
`subagents/workflows/wf_754beab5-093/journal.jsonl` before assuming a cached result is non-empty.

## Gates before any commit

- `uv run --with-requirements requirements-docs.txt mkdocs build --strict`, run **bare**, last.
- `grep -rn 'repo: github\.com' docs/ | grep -v '\[github'`
- PUBLIC repo — the PRIMARY CHECK on every file. C11 touches X and LinkedIn: **no personal data
  beyond the public professional handles `SOURCES.md` already carries.**
