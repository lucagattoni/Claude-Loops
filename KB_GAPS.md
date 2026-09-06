# KB Gaps — Topics Needing Deeper Coverage

This file tracks areas of the loop engineering KB that are currently thin or missing.
Updated by `integrate-loop-news` at the end of each run — `fetch-loop-news` writes only
`.loop-news/findings.json` and never touches a tracked file. Gap keywords drive the next run's
targeted GitHub and web searches.

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

- **The METR/OpenAI transcript-tampering report's actual title and scope**: `docs/17`
  cites a "joint METR/OpenAI incident report" on agents spoofing tool calls and tampering
  with transcripts, sourced via MindStudio's derivative coverage — the primary report was
  never directly fetched, and a separately-linked MindStudio article ("Inside OpenAI's
  PhaseOne Report: How AI Agents Formed a Rogue Swarm") appears to carry specific Hugging
  Face incident numbers (~1,200 agents, 70,000+ messages coordinating via Artifactory
  filesystem metadata) that were *not* independently confirmed as being about Hugging Face
  and so were deliberately left out of the KB citation — search keywords: `"PhaseOne
  Report" OpenAI METR`, `Hugging Face agent swarm incident Artifactory`, `AI agent
  transcript tampering incident report 2026`.

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
command, read a raw value in the right environment, or reproduce a measurement.

> **Both pipeline skills: leave this section alone.**
> `fetch-loop-news` — **do not derive search keywords from it.** There are none; a search cannot
> close any of these, so querying them wastes the run's budget.
> `integrate-loop-news` — **do not prune it.** Phase 7 removes *gaps filled by that run's doc
> writes*. These are not gaps of that kind and a run will never fill one, so a pruning pass that
> treats them as stale would silently delete verified research. Only a session that actually
> settles an item removes its row, and it says how it settled it.

They are recorded here so a session with the right environment can close them, and so nobody
re-derives them from scratch.

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

| **V7** | `docs/05`'s *"Circular imports are ignored."* The official memory page confirms the four-hop depth limit but says nothing about circular `@imports` either way; one verifier claimed the sentence is verbatim there and it is not | Make a two-file circular `@import` chain in a scratch repo, launch Claude Code, and observe: loads, errors, or loops. Then stamp it empirically or replace it with what actually happens. **Do not delete on absence** |
| **V8** | Does `SessionEnd` fire when a detached `--bg` session terminates? The event table says *"When a session terminates"*, but every documented reason value (`clear`, `resume`, `logout`, `prompt_input_exit`, `other`) is interactive. It was left out of `docs/29`'s corrected hook table rather than asserted | Register a `SessionEnd` hook that touches a marker file, run `claude --bg` on a trivial task, and check whether the marker appears. Add the row only if it does |
| **V9** | Which hook, if any, actually fires after a **Routine** run completes. `post-session` is removed from `docs/12`, `docs/28` and `docs/29` as fabricated, which leaves the real answer unknown | Check the Routines docs and the cloud-session env vars (`CLAUDE_CODE_REMOTE`, `CLAUDE_CODE_REMOTE_SESSION_ID`). If no end-of-run hook exists, **say so explicitly** rather than leaving a silent gap |
| **V10** | A standing policy for dead-but-formerly-real citations. Two cited repos now bare-404 (`orobsonn/claude-harness`, cited in `docs/04` and twice in `docs/07`; `KristopherGBaker/Sparra`). Both were demonstrably real at citation time per this KB's own digest | Decide once: dated 404 note (what this pass did), an archive.org snapshot, or re-source from the author's own site (what Sparra got). Then apply it uniformly and record it in `CLAUDE.md` |
| **V11** | The exact wording of the `docs/20` blockquote at the `@steipete` stop-condition line. One verifier fetched the live tweet and reports a longer sentence than the KB shows; the other could not fetch it at all | Re-fetch the tweet and restore the sentence verbatim, or mark the elision properly. **Do not paste a quote body only one agent has seen** |
| **V12** | Whether any genuine primary source exists for an oracle-leakage precision figure. `docs/04`'s `~6%` is removed because the source that carried it retracted it as fabricated (`e6ecf262`, *"drop fabricated critic stat"*, 2026-07-04), leaving the claim qualitative | If a real measured figure is found, restore it with the primary citation. Otherwise `"very low precision"` stands and no number is known |

| **V13** | `docs/04`'s zeroshot quote *"can't lie about code it didn't write"* is **not** in the-open-engine/zeroshot's README today — but it **was** at the KB's 2026-07-02 capture date. The KB was right when written; the source was rewritten afterwards | Nothing to fix. Recorded so the next pass dismisses it in seconds rather than re-deriving: `8e8d4d83` was live at capture, `bfe4bc22` is the rewrite. This is the shape of a *false* fabrication finding |
| **V14** | `docs/04`'s Mozilla case study, list item 3 (a dedicated verifier subagent tuned to reject fixes with unresolved edge cases) has no locatable source. The rest of the case study checks out | Listen to the Lenny's / Claire Vo episode (YouTube `Idjt53tTv2U`; captions are auth-gated to `curl`) or find a transcript. One artifact settles it |
| **V15** | `docs/27`'s Self-Discovery Loop — the five moves (Schedule → Discover → Build → Verify → Repeat) have no verified primary source, and the Anthropic attribution is removed as fabricated | Read Addy Osmani's 7 Jul 2026 post in full and check whether that sequence is actually in it. If yes, cite it. If no, the pattern stands as **this KB's own synthesis**, labelled as such with no external citation |

| **V17** | The primary source for the Uber spend cap. `docs/27` now quotes explainx.ai exactly — "$1,500 per person per tool per month for Claude Code and Cursor after burning its annual AI budget in four months" — but that article sources it only to "June 2026 reporting in the discourse". No filing, press report, or Uber statement has been located | Find the primary report, or establish there is none. If none exists, the KB's hedge stands and the number stays labelled an anecdote. **Do not delete it on absence** — the source is real and correctly quoted; only its own provenance is thin |
| **V18** | Who originated the Loop Contract. `docs/27` — the KB's stated design spine — credits explainx.ai's *"How to Build Your First Agent Loop"*. A *different* explainx article attributes the same TRIGGER/SCOPE/ACTION/BUDGET construct to **Developers Digest**: "The loop contract Developers Digest names the pieces that turn an agent from a clever assistant into a useful background process". The KB may be crediting a repeater rather than the originator | Fetch `explainx.ai/blog/how-to-build-your-first-agent-loop-step-by-step-2026` and check whether it credits Developers Digest too, then locate the Developers Digest original. Re-attribute `docs/27`'s opening if the origin is elsewhere. Found 20260906 while citing the Uber figure; not acted on because re-attributing the spine doc's central concept needs the originating artifact in hand, not an inference from one sentence |

*Logged 20260905 by the C6/C13/C14 pass (V1–V6) and the C1 fact-check (V7–V12); 20260906 by the C1b deep pass (V13–V16) and the C1b P1/P2 pass (V17–V18).*

**V16 is settled — do not re-derive it.** `docs/04`'s *"~85–90% of findings are caught by exactly
one reviewer"* is **correct and verbatim** in its cited source. Traced with `git log -S` to
`198c302` (loop news run 2026-07-06), then read at
[houshuang/compound-review](https://github.com/houshuang/compound-review)'s README: *"Reviewers
don't converge on findings — they're additive. ~85–90% of findings are caught by exactly one
reviewer."* The same read confirmed `agreement_n`, promote-on-confirm, verdict-driven severity and
the 3-round cap. Note for anyone re-checking: that repo's default branch is **`master`** — a raw
fetch against `main` 404s, which would read as a dead citation. Settled 20260906.

**Settled by the C1 pass rather than logged**, because they were cheap to run: `--max-turns` is
silently inert on `--bg` (paired test — fixed in `docs/29`/`docs/18`), and `claude mcp add` has no
interactive form (`missing required argument 'name'` — fixed in `docs/03`).
