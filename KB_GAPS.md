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
  far — stops short of the concrete, checkable per-gate signal; still open.)

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
  unspecified. (2026-07-07: erikhuang76821/fable-harness-kit and KristopherGBaker/Sparra
  both configure cross-model pairing manually per role rather than by a benchmarked
  selection criterion — pairing remains a user judgment call, not yet a measured one.)
  Search keywords: `cross-model reviewer pairing benchmark`, `"model diversity"
  code review coverage`, `which LLM pair catches most bugs`.

---

## Recently Filled (archive — keep last 2 entries; remove older ones)

- ~~**Reviewer-freshness enforcement mechanism**~~ — filled 2026-07-07 by docs/04
  (beingcognitive/unprimed-dialectic: two independence axes — model vs. perspective —
  reviewers must see only the problem/constraints and never the draft until their own
  solution is formed; the synthesizer-bias problem addressed by logging rejections
  alongside acceptances and defining convergence as "no further changes after synthesis")
- ~~**Held-out eval sizing for harness evolution**~~ — filled 2026-07-07 by docs/24
  (ruvnet/metaharness's Darwin Mode: self-mutation gated on a held-out benchmark set
  — SWE-bench Lite, LiveCodeBench — strictly disjoint from the mutation-generating
  traces, closing the snapshot-collapse overfitting risk SEAGym flagged 2026-07-04;
  KristopherGBaker/Sparra's evaluator-only holdout wall complements this at the
  single-run level in docs/04)
