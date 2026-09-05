# KB Gaps — Topics Needing Deeper Coverage

This file tracks areas of the loop engineering KB that are currently thin or missing.
Updated by each `fetch-loop-news` run. Gap keywords drive targeted GitHub and web searches.

---

## Active Gaps

- **F0-F3 fleet maturity indicators**: docs/23 defines the F0-F3 levels but the
  observable indicators for passing each gate are underspecified — search keywords:
  `fleet engineering maturity`, `"F0" "F1" fleet agent`, `agent fleet governance metrics`.
  (2026-07-06 retry: thirai-classlab/hirai-method's F1-F3 naming looked promising but
  turned out to be unrelated enforcement-gate layers, not fleet maturity — false lead,
  ruled out. 2026-07-07 retry: chf3198/megingjord-harness documents F0-F3-consistent
  fleet-aware routing/telemetry/policy infrastructure but — like every source checked so
  far — stops short of the concrete, checkable per-gate signal; still open. 2026-07-08
  retry: ruvnet/ruflo's Trust Loop scores individual agents, not fleet-wide gate
  readiness — adjacent but not a fleet maturity indicator either; still open.)

- **Effort-vs-tooling budget boundary**: docs/11 documents that reasoning effort dominates
  tool access for *first-try reliability* on a greenfield spec'd build (arXiv 2607.02436), but
  *when does a testing tool / checker pass actually pay off* (e.g. large existing codebases,
  regression-heavy work, long-horizon tasks) rather than just adding cost is still unspecified.
  Search keywords: `agent testing tool ROI codebase size`, `"reasoning effort" vs tools
  agentic benchmark`, `when checker pass pays off agent`.

- **Cross-model reviewer selection criteria**: docs/04 documents *how* to arbitrate when
  cross-model reviewers disagree (houshuang/compound-review's verdict-driven severity +
  promote-on-confirm, 2026-07-06) and that model-family diversity beats consensus voting
  (~85-90% of findings caught by exactly one reviewer) — but *which* specific model pairs
  catch the most non-overlapping failure classes (beyond "different family") is still
  unspecified. (2026-07-07: erikhuang76821/fable-harness-kit and Sparra
  ([project page](https://krisbaker.com/building/sparra/); its GitHub repo returns 404 as of
  2026-09-05) both configure cross-model pairing manually per role rather than by a benchmarked
  selection criterion — pairing remains a user judgment call, not yet a measured one.
  2026-07-08: dev.to's 4-commercial-code-review-tool study (93.4% non-overlap, 146 PRs)
  corroborates the non-overlap finding again but is product-level, not model-pair-level —
  still no source names which *specific* model pairs catch the most distinct classes.)
  Search keywords: `cross-model reviewer pairing benchmark`, `"model diversity"
  code review coverage`, `which LLM pair catches most bugs`.

- **Underspecified-input mitigation for autonomous pipelines**: Multiple 2026-07-08
  sources (MindStudio's dark-factory pipeline, Kaola-Workflow's DAG planner) name
  underspecified input as the dominant bottleneck once implementation/review/deploy are
  all automated, but none specify a *mechanism* for catching underspecification before
  it propagates through the pipeline (as opposed to catching bad output after the fact).
  Search keywords: `spec quality gate agent pipeline`, `underspecified input detection
  LLM agent`, `pre-implementation ambiguity check autonomous coding`.

- **Retrieval infrastructure as a multi-agent scaling constraint**: a 2026-09-03 source
  claims retrieval engineering, not model choice, is the key constraint on scaling
  multi-agent systems without breaking them, but names no concrete mechanism (what fails
  first, what a retrieval-infrastructure fix actually looks like) — search keywords:
  `retrieval infrastructure multi-agent scaling`, `agent RAG scaling failure mode`,
  `"retrieval engineering" agentic systems`.

- **Quantifying "parallel graphs cost more than sequential loops"**: docs/21 and docs/04
  now cite Rubén Domínguez's claim that parallel review graphs often cost more than the
  sequential loop they replace, and that same-model parallel reviewers are correlated
  ("chorus not ensemble") — but the claim is argued, not measured. No source yet gives a
  benchmarked cost comparison (tokens/dollars, at matched output quality) between an
  N-way parallel review graph and an equivalent sequential loop. Search keywords:
  `parallel review agent cost benchmark`, `"ensemble" vs "chorus" LLM reviewers`, `graph
  vs sequential loop cost comparison agent`.

---

## Recently Filled (archive — keep last 2 entries; remove older ones)

- ~~**`claude --worktree <name>` standalone semantics**~~ — filled 2026-09-05 by docs/03
  (`### The built-in flag: claude --worktree`): path/branch naming, PR/MR branching and
  its per-host ref resolution, `.worktreeinclude`, the resume/cleanup lifecycle, and the
  four hard-enforced isolation checks — the point being that these are *enforced by the
  runtime*, where a CLAUDE.md worktree rule is only advisory prose)

- ~~**Reviewer-freshness enforcement mechanism**~~ — filled 2026-07-07 by docs/04
  (beingcognitive/unprimed-dialectic: two independence axes — model vs. perspective —
  reviewers must see only the problem/constraints and never the draft until their own
  solution is formed; the synthesizer-bias problem addressed by logging rejections
  alongside acceptances and defining convergence as "no further changes after synthesis")

---

## Claims Awaiting Verification — not search targets

Each item below is a specific factual claim that **no search can settle**: it needs someone to run a
command, read a raw value in the right environment, or reproduce a measurement. `fetch-loop-news`
should **skip this section** — there are no useful search keywords in it. They are recorded here so
a session with the right environment can close them, and so nobody re-derives them from scratch.

They are listed rather than acted on because of the rule this KB keeps re-proving: *"not on the page
we fetched" is a fact about our fetch; "contradicted by the page we fetched" is a fact about the KB.*
Only the second licenses an edit. None of these is contradicted — they are simply unconfirmed.

| # | Claim | How to settle |
|---|---|---|
| **V1** | `CLAUDE_CODE_REMOTE`'s literal value. The [env-vars reference](https://code.claude.com/docs/en/env-vars) says it is *"Set automatically to `true`"*, and `docs/12` now says `true` — but nobody has read the raw value as a shell script sees it. `"1"` was wrong; `true` is a strict improvement, not a confirmed observation | Echo `$CLAUDE_CODE_REMOTE` from a hook inside a real cloud session (a Routine) |
| **V2** | The error text at the concurrent-subagent cap. `docs/07` used to quote `` `Concurrent subagent limit reached` ``; no fetched source contains that string, so the literal was removed while the default, variable and version stayed | Spawn 21 concurrent subagents and record the message. Restore it **with that provenance** |
| **V3** | `docs/09`'s claim that skills under `--add-dir` still load with `--bare`. `CLAUDE_CODE_SIMPLE`'s description says skill auto-discovery is disabled and says nothing about `--add-dir` either way | `claude --bare --add-dir <dir containing a skill>`, then check whether the skill is available |
| **V4** | The numeric default of `cleanupPeriodDays`, which governs the worktree retention sweep now referenced in `docs/03`. Named on the worktrees page, never defined there | Fetch the background-sessions and settings reference pages directly. **Publish no day count until then** |
| **V5** | The `waitingFor` field on `claude agents --json`. Peer-reported; not present in any session state observable on 2.1.261 here (`working`, `done`, `failed`, `busy`). Absence from our observation is not absence from the CLI | Put a background session into a permission prompt, then dump `claude agents --json` |
| **V6** | The 5.8% residual in the ClaudeWarp per-session cost floor: 22,659 tok x $10/MTok = $0.2266 against $0.240609 recorded, leaving $0.0139 unexplained by the three published token counts. The 94% conclusion does not depend on it | Recover that session's full `cost-state` — every token class, including cache reads and any 5-minute write |

*Logged 20260905 by the C6/C13/C14 pass.*
