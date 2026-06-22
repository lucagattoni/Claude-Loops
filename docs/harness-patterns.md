# Harness Patterns

The harness is the scaffolding around the agent — prompts, tools, context policies,
sandboxes, and feedback loops. It is a first-class engineering artefact that requires
continuous refinement, not a disposable wrapper.

## The Two-Part Harness (Anthropic Engineering)

Anthropic's ["Effective Harnesses for Long-Running Agents"](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
defines a two-role harness split:

### 1. Initializer Agent
- Reads the high-level goal and generates a **structured JSON feature list** — a machine-readable work plan
- Sets up session state: which files are in scope, what the success criteria are, what constraints apply
- Writes a mandatory **session init routine** that the coding agent reads at the start of every context window

### 2. Coding Agent
- Executes tasks from the JSON feature list, one unit at a time
- Uses **browser automation testing** to verify UI/UX changes without requiring a human
- Applies **git-based recovery**: commits after each unit so any crash can resume from the last known-good state

The key invariant: the initializer runs once; the coding agent runs many times, each
time within its own context window, always starting by reading the session init file.

## The Four-Type Loop Taxonomy (Claire Vo / Lenny's Newsletter)

Every agent loop has a trigger type. Choosing the wrong trigger type is one of the
most common harness design mistakes:

| Type | Trigger | Notes |
|---|---|---|
| **Heartbeat** | Fixed interval (every N minutes) | Checks for work; exits immediately if nothing to do. Cheap if work is rare; expensive if the interval is too short |
| **Cron** | Scheduled time (daily, weekly) | Predictable resource usage; suits batch jobs and digests |
| **Hook** | Event-driven (push, PR, webhook, file change) | Only fires when work exists — no polling overhead. Preferred for reactive workflows |
| **Goal** | Runs until a success condition is met | Hardest to write; most likely to burn tokens without output. Requires a rigorous stop condition and budget cap |

The goal loop is the most powerful and the most dangerous: without a verifiable
stopping condition and a hard spend cap, it will run indefinitely.

See also: [Loop Contract](loop-contract.md) for mandatory BUDGET and STOP properties.
