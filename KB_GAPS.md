# KB Gaps — Topics Needing Deeper Coverage

This file tracks areas of the loop engineering KB that are currently thin or missing.
Updated by each `fetch-loop-news` run. Gap keywords drive targeted GitHub and web searches.

---

## Active Gaps

- **Multi-loop STATE.md coordination example**: docs/34 defines the `acting_on` field
  convention but there is no concrete example of a multi-loop STATE.md file showing
  two loops coexisting — search keywords: `"state machine" "agent coordination" "loop"
  claude`, `multi-agent state file`, `"acting_on" claude loop`

- **SECURITY_MATRIX.md implementation mechanism**: docs/33 says the agent "reads
  SECURITY_MATRIX.md at startup and self-assesses" but doesn't specify the loading
  mechanism (CLAUDE.md import vs. SessionStart hook vs. system prompt) — search
  keywords: `SECURITY_MATRIX.md` implementation, `agent security policy` loader,
  `claude code` startup file loading

- **Credential rotation patterns**: docs/33 covers provisioning secrets to agents but
  not rotating them mid-session or on credential expiry — search keywords:
  `"secret rotation" agent`, `credential refresh` agentic, `claude code` secrets

- **agentskills.io / .apm/ spec format**: docs/24 mentions harness-agnostic projection
  via `.apm/` source → multi-harness compilation, but the actual format of the spec
  file and how it maps to different harness layouts is not documented — search keywords:
  `agentskills.io format`, `".apm/" agent specification`, `harness-agnostic agent`

- **F0-F3 fleet maturity indicators**: docs/23 defines the F0-F3 levels but the
  observable indicators for passing each gate are underspecified — search keywords:
  `fleet engineering maturity`, `"F0" "F1" fleet agent`, `agent fleet governance metrics`

- **Goal-cost token estimation**: docs/30 mentions a goal-cost token estimator in the
  cobusgreyling/goal-engineering repo but does not describe the estimation method —
  search keywords: `"goal cost" estimation token`, `agent loop token prediction`, `"GOAL.md"
  token budget`

---

## Recently Filled (archive — keep last 2 entries; remove older ones)

- ~~**Verifier calibration techniques**~~ — filled 2026-06-25 by docs/04 (thalys/agent-ab: A/A baseline, deterministic-only graders, bootstrap confidence intervals)
- ~~**Loop correctness testing**~~ — filled 2026-06-25 by docs/04 (void2610: Type A/B classification, verdict taxonomy; JeremyW1990: clean-room review, held-out test layer, cross-task defect ledger)
