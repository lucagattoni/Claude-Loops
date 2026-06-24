# Memory Patterns for Long-Running Loops

A loop that runs for hours or days needs external memory. Build it into the loop.

## Pattern A: Progress file

```text
At the end of each task, append to PROGRESS.md:
- Task: [name]
- Status: [done|blocked|in-progress]  
- Files changed: [list]
- Next: [what the loop should do when it resumes]
```

## Pattern B: GitHub Issues as a task queue

```text
1. Loop reads open issues labeled "loop-task"
2. Picks the highest-priority one
3. Implements, tests, commits, opens PR
4. Labels issue "loop-done" and moves to next
```

## Pattern C: Spec-driven loop

```text
1. Write SPEC.md with all requirements and acceptance criteria
2. Loop implements one requirement at a time
3. Each requirement has a verifiable test
4. Loop stops when all tests pass
```

## Pattern D: Multi-Backend Task Queue

For multi-agent fleets, the task queue can live in the communication tools the team
already uses, enabling agents to self-assign work without a separate coordination
server:

**Slack/Discord thread claiming:**
```
1. Agent reads channel for messages tagged with a claim keyword (e.g. "clem:todo")
2. Agent replies to claim the thread (marks it as in-progress)
3. Agent posts progress updates to the thread as it works
4. Agent posts final result and marks the thread resolved
```

**GitHub Issue label workflow:**
```
1. Maintainer labels an issue "clem:todo"
2. Agent detects the label, self-assigns the issue
3. Agent implements the fix, opens a PR referencing the issue
4. Agent labels the issue "clem:done" and removes "clem:todo"
```

The advantage over a file-based queue: the task state is visible to the whole team
in the tools they already monitor, with no separate dashboard needed.

(clem — jahwag/clem, Jun 2026.)

## Pattern E: STATE.md Wave Recovery

For loops with multiple sequential phases (e.g. the five-wave execution model),
STATE.md tracks phase-level progress rather than just task completion:

```markdown
# STATE.md
current_wave: 3
waves_completed: [1, 2]
wave_3_status: in_progress
wave_3_started: 2026-06-24T05:20:00Z
deviations: []
```

On crash or interruption, the orchestrator reads STATE.md and **resumes from the
last completed wave** — not from the beginning. This is distinct from GOAL.md
(tracks the goal's done condition) and PROGRESS.md (tracks individual task completion):
STATE.md tracks multi-phase execution state.

The recovery check at startup:
```
Read STATE.md
→ if current_wave is in_progress → resume from wave N (restart this wave's agents)
→ if all waves completed → run finalization
→ if STATE.md missing → this is a first run, initialise
```

(session-orchestrator — Kanevry/session-orchestrator, Jun 2026.)

See [Long-Running Agents](25-long-running-agents.md) for the architectural pattern
(Ralph loop / planner-worker-judge) that uses these memory strategies to coordinate
work across multiple context windows.
