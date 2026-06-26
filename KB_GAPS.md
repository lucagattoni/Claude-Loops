# KB Gaps — Topics Needing Deeper Coverage

This file tracks areas of the loop engineering KB that are currently thin or missing.
Updated by each `fetch-loop-news` run. Gap keywords drive targeted GitHub and web searches.

---

## Active Gaps

- **SECURITY_MATRIX.md implementation mechanism**: docs/33 says the agent "reads
  SECURITY_MATRIX.md at startup and self-assesses" but doesn't specify the loading
  mechanism (CLAUDE.md import vs. SessionStart hook vs. system prompt). GitHub search
  for `SECURITY_MATRIX claude agent` returned zero results — search keywords to try:
  `"security policy loader" claude agent`, `"permission matrix" agent harness`,
  `CLAUDE.md import` security startup, `SessionStart hook` agent policy

- **Credential rotation patterns**: docs/33 covers provisioning secrets to agents but
  not rotating them mid-session or on credential expiry — search keywords:
  `"secret rotation" agent`, `credential refresh` agentic, `claude code` secrets

- **F0-F3 fleet maturity indicators**: docs/23 defines the F0-F3 levels but the
  observable indicators for passing each gate are underspecified — search keywords:
  `fleet engineering maturity`, `"F0" "F1" fleet agent`, `agent fleet governance metrics`

- **Goal-cost token estimation**: docs/30 mentions a goal-cost token estimator in the
  cobusgreyling/goal-engineering repo but does not describe the estimation method —
  search keywords: `"goal cost" estimation token`, `agent loop token prediction`, `"GOAL.md"
  token budget`

---

## Recently Filled (archive — keep last 2 entries; remove older ones)

- ~~**agentskills.io / .apm/ spec format**~~ — filled 2026-06-26 by docs/24 (Monad-Harness: six primitive subdirectories — skills/instructions/hooks/prompts/commands/tools; compiler generates harness-specific layout)
- ~~**Multi-loop STATE.md coordination example**~~ — filled 2026-06-26 by docs/34 (concrete PR Babysitter + CI Sweeper STATE.md example with acting_on fields; harnery heartbeat alternative pattern)
