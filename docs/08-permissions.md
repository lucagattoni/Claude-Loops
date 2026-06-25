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

## Risk-Tiered Authorization by Consequence

Rather than categorising permissions by tool name, classify them by the reversibility
of their outcome. This framing catches dangerous tool combinations that name-based
lists miss:

| Tier | Consequence | Examples | Policy |
|---|---|---|---|
| **Read** | Fully reversible — observation only | File reads, listing directories, running tests | Allow freely in all modes |
| **Write** | Reversible with effort — changes can be undone | File edits, git commits, opening PRs | Allow in auto mode; log all actions |
| **Irreversible** | Cannot be undone without significant recovery work | `rm -rf`, force-push, database drops, secret rotation, production deploys | Deny by default; require explicit `ask` even in auto mode |

Apply this framing to the `allow`/`deny`/`ask` lists in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Read", "Edit", "Bash(git commit *)", "Bash(git push origin feature-*)"],
    "ask":   ["Bash(git push origin main)", "Bash(npm publish)", "Bash(rm -rf *)"],
    "deny":  ["Bash(git push --force *)", "Bash(DROP TABLE *)"]
  }
}
```

(wquguru/harness-books, AgentWay, Jun 2026.)

## Safety Path Denylist

For unattended loops, maintain a denylist of paths the loop must never touch
autonomously, regardless of what it is instructed to do:

```json
{
  "permissions": {
    "deny": [
      "Edit(**/.env)",
      "Edit(**/secrets/**)",
      "Edit(auth/**)",
      "Edit(payments/**)",
      "Edit(**/migrations/**)",
      "Edit(k8s/production/**)",
      "Edit(**/credentials/**)"
    ]
  }
}
```

Add project-specific sensitive paths to this list in `.claude/settings.json` before
deploying any unattended loop. The denylist is a last-resort safety net — it does not
replace scoped allowlists.

(cobusgreyling/loop-engineering, Jun 2026.)

## Agent Trust Ramp

Before granting any loop write permissions, build trust incrementally:

| Stage | Mode | What the loop can do |
|---|---|---|
| **1. Read-only** | `plan` permission mode | Read files, analyse state, report findings — no writes |
| **2. Summarise** | Auto mode + read + summarise | Write summaries to a dedicated output file; no code edits |
| **3. Hard limits** | Auto mode + allow list | Write code in specified paths only; hard denylist for infra/secrets |
| **4. Loop cap** | Full auto mode | Standard unattended loop with BUDGET cap and escalation path |

Start every new loop at Stage 1, regardless of engineer experience. Advance only after one
full week of zero unexpected actions at the current stage. These stages align with the
[per-loop readiness levels](20-loop-maturity-model.md) (L1 report-only → L2 assisted → L3 autonomous)
— the trust ramp is the permission configuration that makes each readiness level operational.

> "before you trust an agent to run on its own, do these 4 things" — @Sabrina_Ramonov, Jun 2026

## Relationship to Agent Security Hardening

The [Agent Security Hardening](33-agent-security-hardening.md) doc covers the OS-layer
complement to these software-layer controls: OS-user-per-agent kernel isolation,
credential broker/sidecar dispositions, and the SECURITY_MATRIX.md adversarial policy.

Software-layer permission lists operate inside the model's execution environment.
OS-layer hardening operates outside it — enforcing boundaries that the model cannot
override even if instructed to. The two layers are designed to be deployed together.

## Settings precedence

Later sources override earlier ones:
1. Managed policy (IT/org-wide)
2. `~/.claude/settings.json` (user)
3. `.claude/settings.json` (project, committed)
4. `.claude/settings.local.json` (local, gitignored)
5. CLI flags (`--permission-mode`, `--allowedTools`)
