# Quick Reference

```bash
# Non-interactive with safety limits
claude -p "prompt" --permission-mode auto --max-turns 20

# Fan-out across files
for f in $(cat files.txt); do
  claude -p "process $f" --permission-mode auto --allowedTools "Read,Edit" &
done; wait

# Structured output
claude -p "prompt" --output-format json | jq '.result'

# Resume a session
claude --continue           # most recent
claude --resume             # pick from list

# Plan mode (explore without editing)
# Shift+Tab cycles permission modes in interactive, or --permission-mode plan

# Clear context
/clear

# Compact with instructions
/compact Preserve: task objective, modified files, open questions

# Set a goal (loop until verified)
/goal all tests pass and build succeeds

# Run a skill
/fix-issue 1234
/deploy staging
```

## Flags that do not mean what the snippet suggests

Version-stamped against `claude` **2.1.261**, 2026-09-05.

| Gotcha | Detail |
|---|---|
| `--max-turns` | Still accepted, but **no longer listed in `claude --help`**. `--max-budget-usd` is listed |
| `--max-budget-usd` | Help reads *"(only works with --print)"* — accepted but **silently inert** on a `--bg` session |
| `--permission-prompts` | Documented *"with --print"* only, so a `--bg` session cannot fail closed this way |
| Variadic flags before the prompt | `--add-dir`, `--allowedTools`, `--betas`, `--disallowedTools`, `--file`, `--mcp-config` and `--tools` all take `<...>` lists and will **swallow the positional prompt**. Put the prompt first, or the variadic flag last |
| `claude agents --json` | Interactive sessions carry no `id`. Filter with `--cwd "$PWD"` or `select(.kind=="background")` before reading `.id` |
| `claude --bg -p` | Rejected outright since v2.1.198 (exit 1). Before that it created an unattachable session |

Each of these is worked through in [Background Agents](29-background-agents.md); the
`--print`-scoped permission guarantee is in [Headless Mode](09-headless-mode.md).
