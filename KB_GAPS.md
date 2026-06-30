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

- **Credential rotation patterns**: docs/33 covers provisioning secrets to agents but
  not rotating them mid-session or on credential expiry — search keywords:
  `"secret rotation" agent`, `credential refresh` agentic, `claude code` secrets

- **F0-F3 fleet maturity indicators**: docs/23 defines the F0-F3 levels but the
  observable indicators for passing each gate are underspecified — search keywords:
  `fleet engineering maturity`, `"F0" "F1" fleet agent`, `agent fleet governance metrics`

- **Goal-cost token estimation**: docs/30 mentions a goal-cost token estimator in the
  cobusgreyling/goal-engineering repo but does not describe the estimation method.
  Partially advanced 2026-06-28 — omnigent surfaces authoritative *post-hoc* per-session
  `cost_usd`, and MetaHarness routes models by cost learned from eval logs — but neither
  gives an *a-priori* estimate from objective scope. Search keywords: `"goal cost" estimation
  token`, `agent loop token prediction`, `"GOAL.md" token budget`, `cost routing eval logs agent`

- **Cross-model checker arbitration**: docs/04 (pattern 5) and docs/07 now name cross-model
  independence (Claude implements / Codex reviews), but two open questions are thin — (a) *which*
  model to pair as checker (criteria beyond "different"), and (b) how to arbitrate when two
  models *disagree* on a BLOCK (tie-break, escalate, third model?). Search keywords:
  `"cross-model" reviewer agent`, `Claude Codex reviewer disagreement`, `multi-model verifier arbitration loop`

- **Self-scaffolding / model-generated harness**: MindStudio's Ornith 1.0 finding (model
  generates a discrete inspectable per-task harness instead of running inside a fixed loop) is
  not covered in docs/22 or docs/24, which assume a human-authored harness. Search keywords:
  `"self-scaffolding" agent harness`, `model generates own harness`, `per-task harness synthesis claude`

---

## Recently Filled (archive — keep last 2 entries; remove older ones)

- ~~**agentskills.io / .apm/ spec format**~~ — filled 2026-06-26 by docs/24 (Monad-Harness: six primitive subdirectories — skills/instructions/hooks/prompts/commands/tools; compiler generates harness-specific layout)
- ~~**Multi-loop STATE.md coordination example**~~ — filled 2026-06-26 by docs/34 (concrete PR Babysitter + CI Sweeper STATE.md example with acting_on fields; harnery heartbeat alternative pattern)
