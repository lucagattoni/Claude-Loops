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
