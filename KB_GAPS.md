# KB Gaps — Topics Needing Deeper Coverage

This file tracks areas of the loop engineering KB that are currently thin or missing.
Updated by each `fetch-loop-news` run. Gap keywords drive targeted GitHub and web searches.

---

## Active Gaps

- **Multi-loop STATE.md coordination example**: docs/34 defines the `acting_on` field
  convention but there is no concrete example of a multi-loop STATE.md file showing
  two loops coexisting — search keywords: `"state machine" "agent coordination" "loop"
  claude`, `multi-agent state file`, `"acting_on" claude loop`

- **Verifier calibration techniques**: docs/07 names "Verifier Theater" as a failure
  mode and flags evaluator anti-patterns, but lacks specific techniques for calibrating
  a verifier against a ground-truth test set to prevent both false positives and false
  negatives — search keywords: `"LLM judge" calibration`, `"agent evaluator" accuracy`,
  `"claude code" verifier tuning`

- **GOAL.md schema**: docs/30 (goal-engineering) establishes GOAL.md as a pattern but
  provides no concrete schema or template — search keywords: `GOAL.md template`,
  `"goal engineering" schema`, `agent goal state file format`

- **Loop correctness testing**: docs/04 covers testing what a loop produces but not
  testing the loop's own behaviour (does it stop when it should, does it escalate,
  does it respect the budget?) — search keywords: `"loop testing"` agent, `"agent
  harness" testing`, `"claude code" loop validation`

- **Cost attribution in multi-agent systems**: docs/11 gives per-pattern token budgets
  but not profiling techniques to identify which agent is responsible for runaway costs
  — search keywords: `"agent cost" attribution`, `"multi-agent" profiling tokens`,
  `claude api usage breakdown`

- **Credential rotation patterns**: docs/33 covers provisioning secrets to agents but
  not rotating them mid-session or on credential expiry — search keywords:
  `"secret rotation" agent`, `credential refresh` agentic, `claude code` secrets

---

## Recently Filled (keep for reference, 2 most recent)

- ~~**L1/L2/L3 readiness levels**~~ — filled 2026-06-24 by docs/34 (cobusgreyling)
- ~~**Multi-loop collision detection**~~ — filled 2026-06-24 by docs/34 and docs/10
