# KB Gaps — Topics Needing Deeper Coverage

This file tracks areas of the loop engineering KB that are currently thin or missing.
Updated by each `fetch-loop-news` run. Gap keywords drive targeted GitHub and web searches.

---

## Active Gaps

- **SECURITY_MATRIX.md implementation mechanism**: docs/33 says the agent "reads
  SECURITY_MATRIX.md at startup and self-assesses" but doesn't specify the loading
  mechanism (CLAUDE.md import vs. SessionStart hook vs. system prompt). GitHub search
  for `SECURITY_MATRIX claude agent` returned zero results (2026-06-28, retry) — the
  closest public pattern is **default-deny MCP governance** (ruvnet/agent-harness-generator
  `harness mcp-scan`). Search keywords to try next: `"default-deny" MCP policy agent`,
  `"mcp-scan" agent harness`, `"security policy loader" claude agent`, `SessionStart hook` agent policy

- **F0-F3 fleet maturity indicators**: docs/23 defines the F0-F3 levels but the
  observable indicators for passing each gate are underspecified — search keywords:
  `fleet engineering maturity`, `"F0" "F1" fleet agent`, `agent fleet governance metrics`

- **SECURITY_MATRIX default-deny *loading mechanism***: partially advanced 2026-07-01 —
  omnigent's runtime `intent_gate` (default-deny against stated intent) + `blast_radius`
  policies are now in docs/33, but the *startup loading* mechanism (how a static policy
  doc becomes an enforced gate: CLAUDE.md import vs. SessionStart hook vs. policy engine)
  is still under-specified. Search keywords: `"policy engine" agent startup`, `SessionStart hook policy`

- **Cross-model checker arbitration**: docs/04 (pattern 5) and docs/07 now name cross-model
  independence (Claude implements / Codex reviews), but two open questions are thin — (a) *which*
  model to pair as checker (criteria beyond "different"), and (b) how to arbitrate when two
  models *disagree* on a BLOCK (tie-break, escalate, third model?). Search keywords:
  `"cross-model" reviewer agent`, `Claude Codex reviewer disagreement`, `multi-model verifier arbitration loop`

- **Effort-vs-tooling budget boundary**: docs/11 now documents that reasoning effort dominates
  tool access for *first-try reliability* on a greenfield spec'd build (arXiv 2607.02436), but the
  finding is task-class-specific — *when does a testing tool / checker pass actually pay off* (e.g.
  large existing codebases, regression-heavy work, long-horizon tasks) rather than just adding cost?
  The crossover conditions are unspecified. Search keywords: `agent testing tool ROI codebase size`,
  `"reasoning effort" vs tools agentic benchmark`, `when checker pass pays off agent`

- **Held-out eval construction for harness evolution**: docs/24 (Self-Improving Harnesses) now
  says to gate every proposed harness edit on a held-out run and that gains come from
  tools/middleware/memory not prompts (AHE ablation) — but *how* to build the held-out task set,
  size it, and avoid overfitting the harness to its own eval is unspecified. Search keywords:
  `harness evolution held-out eval`, `agent harness overfitting benchmark`, `Terminal-Bench harness ablation`

---

## Recently Filled (archive — keep last 2 entries; remove older ones)

- ~~**Goal-cost a-priori token estimation**~~ — filled 2026-07-01 by docs/30 (cobusgreyling `goal-cost --pattern <p> --level <G>`: pattern-keyed pre-run cost forecast feeding the Budget primitive before launch)
- ~~**Self-scaffolding / model-generated harness**~~ — filled 2026-07-02 by docs/24 (Self-Improving Harnesses: Self-Harness weakness-mining→propose→validate; AHE observability-driven evolution with verified prediction contracts, beats human Codex-CLI baseline; HarnessX substitution algebra + AEGIS — the harness optimizes itself from execution traces, model held fixed)
