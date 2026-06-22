# Headless & Non-Interactive Mode

`claude -p "prompt"` runs Claude without a session — no terminal UI, no interactive
prompts. This is the entry point for all automation.

```bash
# One-off task
claude -p "summarize what changed in the last 10 commits"

# Structured output for scripting
claude -p "list all exported functions in src/" --output-format json

# Streaming JSON for real-time processing
claude -p "analyze error.log" --output-format stream-json --verbose
```

## Key flags

- `--permission-mode auto` — safe unattended execution
- `--max-turns 20` — cap turns; start conservative, raise with data
- `--allowedTools "Edit,Bash(git *)"` — scope permissions per invocation
- `--output-format json|stream-json` — machine-readable output

**Build explicit halt conditions.** In headless mode there is no UI to escalate to.
If the loop hits an unrecoverable state, it terminates. Log everything at the step
where it fails, not silently at the end.
