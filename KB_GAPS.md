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
  ruled out.)

- **Effort-vs-tooling budget boundary**: docs/11 documents that reasoning effort dominates
  tool access for *first-try reliability* on a greenfield spec'd build (arXiv 2607.02436), but
  *when does a testing tool / checker pass actually pay off* (e.g. large existing codebases,
  regression-heavy work, long-horizon tasks) rather than just adding cost is still unspecified.
  Search keywords: `agent testing tool ROI codebase size`, `"reasoning effort" vs tools
  agentic benchmark`, `when checker pass pays off agent`.

- **Held-out eval sizing for harness evolution**: docs/24 now documents edonadei/caliper's
  with/without-skill baseline comparison and SEAGym's finding that intermediate harness
  snapshots can *collapse* on later iterations (2026-07-06) — regressing against a fixed
  suite of earlier-solved cases catches this, and source/trace diversity affects reliability.
  Still open: *how large* a held-out set needs to be and how to detect overfitting to the
  harness's own eval before it happens, not just after a regression. Search keywords:
  `harness evolution held-out eval sizing`, `agent harness overfitting benchmark`,
  `Terminal-Bench harness ablation`.

- **Reviewer-freshness enforcement mechanism**: docs/17 (Zombie finding) and docs/04
  (Clean-Room Review) both require a reviewer with no prior exposure to the finding/task,
  and gomilesf/convergo requires "a newly-spawned reviewer (never the same one)" at the
  final exit gate — but no source yet specifies how a loop *mechanically* verifies reviewer
  non-identity (session fingerprint? spawn-time nonce?) rather than just instructing the
  orchestrator not to reuse one. Search keywords: `"reviewer identity" agent verification`,
  `session fingerprint agent review`, `fresh reviewer enforcement mechanism agent`.

- **Cross-model reviewer selection criteria**: docs/04 now documents *how* to arbitrate when
  cross-model reviewers disagree (houshuang/compound-review's verdict-driven severity +
  promote-on-confirm, 2026-07-06) and that model-family diversity beats consensus voting
  (~85-90% of findings caught by exactly one reviewer) — but *which* specific model pairs
  catch the most non-overlapping failure classes (beyond "different family") is still
  unspecified. Search keywords: `cross-model reviewer pairing benchmark`, `"model diversity"
  code review coverage`, `which LLM pair catches most bugs`.

---

## Recently Filled (archive — keep last 2 entries; remove older ones)

- ~~**SECURITY_MATRIX default-deny loading mechanism**~~ — filled 2026-07-06 by docs/33
  (four concrete loading points converged this cycle: MCP-proxy daemon identity
  verification, tool-dispatch-layer egress control shared across harnesses, OS/kernel
  policy compilation, and session-bootstrap eval-parity — mcpharbour, cross-provider-egress-guard,
  ActPlane arXiv 2606.25189, codeafix/agent-assistant)
- ~~**Cross-model checker arbitration (the disagreement-resolution half)**~~ — filled
  2026-07-06 by docs/04 (houshuang/compound-review: verdict-driven severity overriding raw
  reviewer severity, "promote-on-confirm" floor, bounded 3-round reconciliation gated on
  blocker/high severity only — the "which model to pair" half is refined, not fully closed;
  see the new Active Gap above)
