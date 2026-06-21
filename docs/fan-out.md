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

## Pipe Claude into your existing pipelines

```bash
cat error.log | claude -p "identify the root cause" --output-format json | jq '.result'
```
