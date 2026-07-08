# Fan-Out — Parallelizing at Scale

For large migrations, analyses, or batch operations, distribute work across many
parallel Claude invocations:

```bash
# Step 1: Generate task list
claude -p "list all Python files that need migrating to async. output one path per line" \
  > files_to_migrate.txt

# Step 2: Fan out across files
while IFS= read -r file; do
  claude -p "Migrate $file to async/await. Preserve all behavior. Return OK or FAIL." \
    --permission-mode auto \
    --allowedTools "Read,Edit,Bash(git commit *)" \
    --max-turns 15 &
done < files_to_migrate.txt
wait
```

**Test on 2-3 files first.** Refine the prompt on small batch failures, then run
the full set. The `--allowedTools` flag prevents the fan-out from touching anything
outside its intended scope.

## Scope-Verified Parallelism

When multiple sessions fan out and write to the same codebase, file collisions cause
corrupt merges and lost work. Prevent this at the hook layer rather than through manual
file-locking discipline:

```json
// .claude/settings.json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "type": "command",
        "command": "scripts/check-file-lock.sh"
      }
    ]
  }
}
```

`check-file-lock.sh` reads each active session's STATE.md, extracts its `acting_on`
file list, and exits `2` (deny) if the requested file is already claimed by another
session. On exit `0`, it writes the current session's claim before returning.

This enables safe parallel fan-out without coordination overhead: each agent checks
at the point of write, not at the point of task assignment.

(session-orchestrator — [Kanevry/session-orchestrator](https://github.com/Kanevry/session-orchestrator), Jun 2026.)

**A complementary check earlier in the pipeline**: rather than only catching a
collision at the point of write, a **classifier-gated** pre-claim check can mark
candidate parallel work green/yellow/red/blocked *before* dispatch, based on file
overlap, shared dependencies, and shared infrastructure — reducing how often the
write-time lock above actually has to deny anything. See
[Task-Shaped DAG Orchestration](24-harness-patterns.md#task-shaped-dag-orchestration)
for the full pattern; the two checks are complementary layers, not substitutes for
each other.

## Multi-Loop Coordination

For repos running multiple distinct loops (CI Sweeper + PR Babysitter + Dependency
Sweeper, etc.), fan-out coordination extends to cross-loop ownership:

1. Each action loop writes `acting_on: <branch-or-pr-id>` in its STATE.md before
   starting any work on that item
2. All loops read all STATE.md files before claiming a new item — skip items
   already claimed by any other loop
3. Priority ordering determines who acts first when two loops find the same work
4. Cross-loop conflicts that cannot be auto-resolved go to a human inbox in STATE.md

See [Loop Patterns](34-loop-patterns.md) for the full priority ordering and seven
named loop patterns with defined STATE.md coordination.

## Agentic MapReduce

For codebase-wide analysis tasks (security audits, dependency sweeps, dead-code
detection), structure the fan-out as an explicit MapReduce rather than an unstructured
swarm:

1. **Map** — a coordinator agent scans the codebase and maps out signal locations
   (files, patterns, or regions likely to contain what you're looking for)
2. **Fan out** — each mapped region is assigned to its own bounded agent invocation,
   scoped to only that region (same scope-verified parallelism as above)
3. **Reduce** — a synthesis pass collects all per-region findings into a single
   deduplicated list
4. **Verify** — each candidate finding is independently confirmed in an isolated sandbox
   before being reported, so the reduce step doesn't just aggregate unverified guesses

The map stage is what separates this from plain fan-out: instead of dividing work
mechanically (one agent per file), a signal-aware pass decides *where* to look first,
so bounded-context agents spend their budget on high-likelihood regions rather than
scanning uniformly.

([Devin, "Security Swarm"](https://threadreaderapp.com/thread/2072368168182432109.html), Jul 2026.)

## Pipe Claude into your existing pipelines

```bash
cat error.log | claude -p "identify the root cause" --output-format json | jq '.result'
```
