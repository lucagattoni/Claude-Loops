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
