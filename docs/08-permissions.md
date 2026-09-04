# Permissions & Auto Mode

Repeated permission prompts break autonomy. Three options, in order of trust.

> "On Pro, Max, and Team plans, the built-in starting permission mode is auto mode."
> — Anthropic, [Choose a permission mode](https://code.claude.com/docs/en/permission-modes)

This changes the framing below. Auto mode used to be something you opted into for unattended
runs. For most readers on those plans it is now where a session already starts, so the live
question is no longer "when do I turn auto mode on" but **when do I turn it off** — see
option 2, below.

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

## 2. Auto mode (the default on Pro, Max, and Team — not an opt-in)

A separate classifier model reviews each tool call instead of you. Blocks scope escalation,
unknown infrastructure changes, and actions that look driven by hostile content Claude read.
Lets routine work proceed without interruption:

```bash
claude --permission-mode auto -p "fix all lint errors and commit"
```

The classifier itself defaults to a specific model, version-stamped:

> "Improved auto mode: the permission classifier now defaults to Sonnet 5 for external sessions,
> validated on the session's first request and pinned for the session."
> — [CHANGELOG.md](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md), v2.1.210

If the classifier blocks the same action 3 consecutive times (or 20 total), auto mode pauses and
Claude Code falls back to prompting you rather than looping forever
([Choose a permission mode](https://code.claude.com/docs/en/permission-modes#when-auto-mode-falls-back)).

### When it does NOT start in auto mode

The built-in starting mode is plan- and surface-dependent, not universal:

| Surface | Built-in starting mode |
|---|---|
| Terminal or VS Code, Pro/Max/Team plan (Claude Code v2.1.228+ on macOS/Linux/WSL, v2.1.233+ on native Windows) | `auto` |
| `claude -p` (headless) or the Agent SDK | `default` (Manual) |
| Enterprise plan or a Claude Console API key | `default` (Manual) |
| Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, Claude Platform on AWS, or a signed-in Claude apps gateway session | `default` (Manual) — but auto mode is selectable without an opt-in flag; see the v2.1.207 row below |

(["Which mode a session starts in"](https://code.claude.com/docs/en/permission-modes#which-mode-a-session-starts-in), Anthropic. On earlier CLI versions than those listed, the built-in default is Manual everywhere.)

### Turning it off

The official guidance is explicit that auto mode is convenience, not a safety guarantee:

> "Auto mode reduces permission prompts but does not guarantee safety. Use it for tasks where you
> trust the general direction, not as a replacement for review on sensitive operations."
> — Anthropic, [Choose a permission mode](https://code.claude.com/docs/en/permission-modes)

Turn it off for one session with `claude --permission-mode default` (or `Shift+Tab` to cycle back
to Manual), or as a standing default:

```json
// ~/.claude/settings.json
{
  "permissions": { "defaultMode": "default" }
}
```

An organization can remove auto mode entirely, so nobody can select it, via managed settings:

```json
{ "permissions": { "disableAutoMode": "disable" } }
```

**Gotcha, version-stamped (v2.1.207):** `defaultMode: "auto"` does not take effect from
`.claude/settings.json` or `.claude/settings.local.json` — both repo-resident — only from
`~/.claude/settings.json` (user) or managed settings. A loop whose config lives in the repo and
sets `"defaultMode": "auto"` there silently falls back to Manual mode with no error. Before
v2.1.207, `.claude/settings.local.json` *was* read for this key, so a config that worked on an
older CLI can go silently stale after an upgrade.

### Auto mode: what changed, v2.1.205 → v2.1.257

Every row below is version-stamped and quoted verbatim from
[CHANGELOG.md](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md) (the
rendered [changelog](https://code.claude.com/docs/en/changelog) at code.claude.com only covers
v2.1.235 and later, so earlier entries here come from the raw GitHub file).

| Version | What changed | Verbatim |
|---|---|---|
| v2.1.205 | Session transcripts protected from tampering | "Added an auto mode rule that blocks tampering with session transcript files." |
| v2.1.205 | Unresolved deletion targets now questioned | "Improved auto mode to ask before running `rm -rf` on a variable it can't resolve from context." |
| v2.1.207 | Opt-in requirement removed on three providers | "Auto mode is now available without `CLAUDE_CODE_ENABLE_AUTO_MODE` opt-in on Bedrock, Vertex AI, and Foundry; disable via `disableAutoMode` in settings." |
| v2.1.207 | Repo-resident settings stop carrying `autoMode` | "Changed auto mode to no longer read `autoMode` from `.claude/settings.local.json` (repo-resident); use `~/.claude/settings.json` instead." |
| v2.1.208 | Substitution forms close a deletion loophole | "Catastrophic removals (e.g. `rm -rf ~`) in commands containing `$(…)`/backticks/`<(…)` now prompt in `--dangerously-skip-permissions` and auto mode, matching the plain form." |
| v2.1.210 | Classifier model pinned per session | "Improved auto mode: the permission classifier now defaults to Sonnet 5 for external sessions, validated on the session's first request and pinned for the session." |
| v2.1.211 | Always-allow rules persist across worktrees | "When you choose 'Yes, and don't ask again' … Claude Code saves the rule to `.claude/settings.local.json` at the root of the git repository, resolved through worktrees to the main checkout." — [Configure permissions](https://code.claude.com/docs/en/permissions) |
| v2.1.214 | Long Bash commands always prompt | "Fixed Bash permission checks misjudging very long commands — commands over 10,000 characters now always prompt instead of running automatically." |
| v2.1.248 | Hardened `--restricted` session mode added | "Added `--restricted` (or `CLAUDE_CODE_RESTRICTED=1`): removes the built-in tools that run commands or code and `WebFetch` (unless named in `--tools`), keeps file tools inside the working directory, refuses `bypassPermissions`, and ignores user, project and local settings files." |
| v2.1.257 | Cloud/container-escape primitives blocked by default | "Added a Containment Escape rule to auto mode so cloud metadata-credential fetches, egress evasion, and cross-tenant reach are no longer auto-approved unless your environment marks them expected." |
| v2.1.257 | Reads outside working directories can be fenced | "Added a one-time prompt in auto mode before the first file read outside the working directories, with the option to block such reads (`permissions.blockReadsOutsideWorkingDirectories`)." |

The last row is a new setting, not just a prompt: set
`"permissions": {"blockReadsOutsideWorkingDirectories": true}` to make the file tools refuse such
reads in **every** permission mode, in every later session — not only auto mode
([Configure permissions](https://code.claude.com/docs/en/permissions#working-directories)).

Two of the v2.1.207 changes above matter together for anyone deploying loops on Bedrock, Vertex,
or Foundry: auto mode stopped requiring the `CLAUDE_CODE_ENABLE_AUTO_MODE` flag, and in the same
release stopped reading `autoMode` from the repo-resident settings file. A loop config that relied
on both — the env var and a committed `.claude/settings.local.json` — needs re-checking after an
upgrade past v2.1.207: the flag now does nothing (accepted for compatibility only), and the
setting needs to move to `~/.claude/settings.json`.

### The confused-environment attack class

On 2026-08-27, Simon Willison published
[Breaking Claude Code Opus 5 Auto Mode](https://simonwillison.net/2026/Aug/27/breaking-claude-code-opus-5-auto-mode/),
covering an exploit from prompt-injection researcher Johann Rehberger that worked **80% of the
time**. The mechanism, verbatim:

> "tricking Claude Code into downloading and uncompressing a zip archive, then executing code that
> imports base64 without noticing that this will import and execute a local struct.py file
> extracted from the archive."

This is explicitly **not classic prompt injection** — no malicious instruction is ever followed.
A reader named hyperpape put the distinction precisely, in a Lobsters comment Willison quoted in a
2026-08-30 update to the post:

> "this doesn't fit the bill of a classic prompt injection attack because at no point are
> malicious instructions from the website accidentally followed by the LLM" — instead "this is
> more of a confused environment attack where the nature of the environment that the agent is
> exposed to results in an exploit."

The failure that made it worse than the exploit itself: auto mode's own safety gate blocked the
agent's correct response. Willison, quoting the writeup:

> "In a few cases auto mode directly prevented the agent from preventing harmful code from
> continuing to execute! … Claude detects the compromise, but Auto Mode blocks its cleanup
> command."

Willison's recommended mitigations, verbatim: "Run unattended coding agents in a container, VM or
OS sandbox. Restrict network egress. Monitor your agents. Do not expose home directories, SSH
keys, cloud credentials,… to the agent runtime." This is the same conclusion as
[Agent Security Hardening](33-agent-security-hardening.md): OS-layer isolation is the load-bearing
control for unattended loops, because a software-layer permission system — even a diligent one —
can misjudge a case its designers didn't anticipate.

**Timeline, stated without asserting causation.** Five days after Willison's post, Claude Code
v2.1.257 (2026-09-01) shipped the Containment Escape rule quoted in the table above — cloud
metadata-credential fetches, egress evasion, and cross-tenant reach no longer auto-approved by
default. The v2.1.257 release notes name none of Willison's post, Rehberger, or "confused
environment attack," and the rule's own scope (cloud metadata endpoints, egress evasion,
cross-tenant reach) is a different attack surface than Rehberger's local package-shadowing
exploit. The five-day gap makes a connection **plausible**; nothing in either the post or the
release notes **establishes** that v2.1.257 was a direct response to it.

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

([wquguru/harness-books](https://github.com/wquguru/harness-books), AgentWay, Jun 2026.)

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

([cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering), Jun 2026.)

## Reject+Replan Pattern

When a safety gate (deny list, PermissionRequest hook, or budget cap) blocks an action,
the loop should **replan** rather than abort. The safety layer is not a terminal error —
it is a constraint the agent must reason around.

The pipeline within a single loop turn:

```
Validate (schema, intent) → Scope (permissions, boundaries) → Budget (cost, step, rate limit)
    → Allow  → execute
    → Reject → return rejection reason to agent → replan the step
```

Prompt addition for loops that will encounter permission gates:

```
If a tool call is denied, treat the denial message as a constraint, not a failure.
Replan the current step using an approach that does not require the denied action.
If no alternative exists, produce a handoff verdict with the blocked action listed
explicitly so a human can unblock it.
```

This prevents the loop from producing a silent `stopped` verdict when a gate fires.
The agent either finds an alternative path or escalates cleanly as a `handoff` — both
are deliberate outcomes. See [Verification](04-verification.md) for the full verdict taxonomy.

([@akshay_pachaar](https://x.com/akshay_pachaar), DailyDoseofDS, Jun 2026.)

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

> "before you trust an agent to run on its own, do these 4 things" — [@Sabrina_Ramonov](https://x.com/Sabrina_Ramonov), Jun 2026

## Relationship to Agent Security Hardening

The [Agent Security Hardening](33-agent-security-hardening.md) doc covers the OS-layer
complement to these software-layer controls: OS-user-per-agent kernel isolation,
credential broker/sidecar dispositions, and the SECURITY_MATRIX.md adversarial policy.

Software-layer permission lists operate inside the model's execution environment.
OS-layer hardening operates outside it — enforcing boundaries that the model cannot
override even if instructed to. The two layers are designed to be deployed together.

## ASK Verdict and Soft Warning Thresholds

Beyond hard ALLOW/DENY, a permission system can return a third verdict: **ASK** — "proceed
only after human confirmation." This is distinct from DENY (blocked) and ALLOW (auto).

### ASK verdict behaviour

```
Validate → Scope → Budget
    → ALLOW   → execute immediately
    → DENY    → reject; agent replans
    → ASK     → pause; surface to human; wait for explicit approval
```

ASK fires when an action is within the agent's declared scope but exceeds a risk or cost
threshold. The agent does not retry, does not replan — it waits. This is the same
**Surface** action described in [Verification](04-verification.md): emit a situation
report and halt until a human responds.

### Soft warning thresholds (`ask_thresholds_usd`)

Hard budget caps (`max_cost_usd`) block the loop when spend is exceeded. Soft warning
thresholds trigger ASK *before* the hard cap, giving humans an interception point:

```json
// .claude/settings.json
{
  "budget_tokens": 50000,
  "max_cost_usd": 2.00,
  "ask_thresholds_usd": {
    "single_action": 0.10,
    "session_total": 1.50
  }
}
```

When any single action would cost ≥ $0.10, or the session total has reached $1.50, the loop
surfaces for approval before continuing. The agent states: what action it wants to take,
estimated cost, and current session total. The human approves or redirects.

### Session-fires-first evaluation order

When multiple threshold types apply simultaneously, evaluate in this order:
1. **Schema / intent validation** (first; cheapest to check)
2. **Scope** (permission list — ALLOW/DENY/ASK per action)
3. **Single-action soft threshold** (`ask_thresholds_usd.single_action`)
4. **Session budget** (hard `max_cost_usd` cap — fires last)

A session-level cap that fires before a scope check would allow a denied action to consume
budget before being blocked. Scope must gate before spend.

([omnigent-ai/omnigent](https://github.com/omnigent-ai/omnigent), Jun 2026.)

## Settings precedence

Later sources override earlier ones:
1. Managed policy (IT/org-wide)
2. `~/.claude/settings.json` (user)
3. `.claude/settings.json` (project, committed)
4. `.claude/settings.local.json` (local, gitignored)
5. CLI flags (`--permission-mode`, `--allowedTools`)
