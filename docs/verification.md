# Verification: The Non-Negotiable Foundation

> A loop is only as trustworthy as its ability to check its own work.

Without verification, the loop has no stopping condition — it either halts too early
("looks done") or spins forever. **Always give Claude a check it can run.**

A check is anything that returns a pass/fail signal Claude can read:

- Test suite (`npm test`, `pytest`, `cargo test`)
- Build exit code (`npm run build`)
- Linter (`eslint`, `ruff`)
- Script that diffs output against a fixture
- Browser screenshot compared against a design
- A separate evaluator model (a subagent that did not write the code)

## Verification strategies

| Scope | Mechanism | How to set it up |
|---|---|---|
| Single prompt | Ask Claude to run the check and iterate in the same message | `"implement X. run tests after. fix any failures."` |
| Across a session | `/goal` condition | `"my goal is: all tests pass and the build succeeds"` |
| Deterministic gate | Stop hook | Runs a script; blocks the turn from ending until it passes |
| Independent review | Verification subagent | Fresh model reviews the diff, not the work-in-progress |

## The self-verifying loop pattern

```text
1. Claude implements the feature
2. Claude runs: npm test
3. If tests fail → Claude reads output, edits code, re-runs
4. Loop ends only when tests pass
5. Stop hook runs linter as a final gate before the turn closes
```

**Show evidence, not assertions.** Have Claude output the test result, the command
it ran, and what it returned. Reviewing evidence is faster than re-running
verification yourself.
