# Permissions & Auto Mode

Repeated permission prompts break autonomy. Three options, in order of trust:

## 1. Permission allowlists (surgical)

Allow specific commands you know are safe:

```bash
# In .claude/settings.json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git *)", "Bash(pnpm *)", "Edit", "Read"]
  }
}
```

## 2. Auto mode (recommended for unattended runs)

A separate classifier model reviews each tool call. Blocks scope escalation, unknown
infrastructure changes, and prompt-injection-driven actions. Lets routine work proceed
without interruption.

```bash
claude --permission-mode auto -p "fix all lint errors and commit"
```

If the classifier blocks the same action 3 consecutive times (or 20 total), it
escalates to the human rather than looping forever.

## 3. bypassPermissions (CI / containers only)

Runs all tools without asking. Only use in isolated environments (Docker, CI, VMs)
where the agent's actions cannot affect systems you care about.

```bash
claude --permission-mode bypassPermissions -p "run migration"
```

## Deny and ask lists

Block specific tools or prompt for confirmation before others run:

```json
// .claude/settings.json
{
  "permissions": {
    "allow": ["Bash(git *)", "Bash(npm run *)", "Edit", "Read"],
    "deny":  ["Bash(curl *)", "Bash(rm -rf *)"],
    "ask":   ["Bash(git push *)", "Bash(npm publish)"]
  }
}
```

- **`deny`** — tool call is blocked outright
- **`ask`** — permission dialog appears even in auto mode
- `"*"` in the deny list blocks all tools (emergency lockdown)

### Tool-parameter pattern syntax

Patterns can match on the command argument, not just the tool name:

```json
"allow": ["Bash(git *)"],          // any git command
"deny":  ["Agent(model:opus)"],    // block Opus subagents
"deny":  ["Bash(rm -rf *)"]        // block recursive deletes
```

Pattern tokens: `*` (any substring), `**` (any path), `?` (single char).

## PermissionRequest hook

For fine-grained control in auto mode, handle permission decisions programmatically
instead of using static lists:

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "type": "command",
        "command": "scripts/check-permission.sh"
      }
    ]
  }
}
```

The hook receives the tool name and input; return `allow`, `deny`, `ask`, or
`defer` (fall through to default auto mode classifier) in `permissionDecision`.

## Settings precedence

Later sources override earlier ones:
1. Managed policy (IT/org-wide)
2. `~/.claude/settings.json` (user)
3. `.claude/settings.json` (project, committed)
4. `.claude/settings.local.json` (local, gitignored)
5. CLI flags (`--permission-mode`, `--allowedTools`)
