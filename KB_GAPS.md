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

---

## Recently Filled (archive — keep last 2 entries; remove older ones)

- ~~**Credential rotation mid-session**~~ — filled 2026-07-01 by docs/33 (Credential-Sentinel: verify-before-revoke cutover — promote→repoint→verify, revoke old only after verify passes, rollback to still-valid old on fail; 4-state classify with default-deny on unknowns; two human gates)
- ~~**Goal-cost a-priori token estimation**~~ — filled 2026-07-01 by docs/30 (cobusgreyling `goal-cost --pattern <p> --level <G>`: pattern-keyed pre-run cost forecast feeding the Budget primitive before launch)
