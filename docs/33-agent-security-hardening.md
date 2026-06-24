# Agent Security Hardening

`CLAUDE.md` rules and permission allowlists protect against accidents. They do not
protect against a compromised prompt, a leaked credential, or an agent escaping its
intended scope. Production unattended loops require security enforced at the OS and
network layer — below the model, not inside it.

(Based on clem — jahwag/clem, Jun 2026.)

## OS-User-Per-Agent Isolation

The strongest isolation primitive for multi-agent fleets: each agent runs as a
separate Linux OS user with its own home directory, git identity, and UID-scoped
firewall rules. The kernel enforces the boundary — no in-process escape is possible.

| Model | Boundary | Enforced by | Bypassable from userspace? |
|---|---|---|---|
| Worktree isolation | Separate git checkout per agent | Filesystem | Yes |
| OS-user isolation | Separate Linux user (uid/gid) per agent | Kernel | No |

Each agent gets: a dedicated `/home/agent-<id>/` directory, a unique git author
identity, and nftables rules scoped to its UID. One agent cannot read another's
state, credentials, or working directory even if it receives a malicious instruction
to do so.

## Credential Isolation: Four Disposition Types

Never provision secrets directly into an agent's environment. Apply one of four
dispositions per credential:

| Disposition | Mechanism | Agent ever sees the secret? |
|---|---|---|
| **Broker** | HTTP proxy intercepts egress and injects the real credential on the way out | No |
| **Sidecar** | A separate-user MCP server holds the credential; agent calls over loopback | No |
| **Remove** | Don't provision credentials the agent doesn't need | Not provisioned |
| **Egress Firewall** | UID-level nftables rules block egress to disallowed endpoints | Can't exfiltrate even if obtained |

**Broker** is the strongest disposition: the agent constructs requests with a
placeholder token; the proxy transparently substitutes the real credential on egress.
The agent cannot log, print, or exfiltrate a credential it never received.

**Sidecar** is the right choice for credentials used via MCP: the MCP server runs
as a separate OS user, holds the credential, and exposes only the narrow operations
the agent needs. The agent calls the MCP tool; the sidecar makes the authenticated
request.

## SECURITY_MATRIX.md

A machine-readable safety policy document shipped with every deployed agent. It defines:
- **Known-safe command patterns** — explicitly whitelisted; agent executes without verification
- **Known-attack patterns** — flagged as suspicious regardless of instruction source

The agent reads SECURITY_MATRIX.md at startup and self-assesses ambiguous instructions
before executing. Example: `kill $PPID` (a runner-exit protocol) must be explicitly
whitelisted or the agent flags it as a potential injection attack.

The SECURITY_MATRIX is the adversarial counterpart to the Loop Contract: the contract
says what the loop *should* do; the matrix says what it must *refuse*, regardless of
what any instruction — including CLAUDE.md — tells it to do.

## Fail-Safe Secret Exposure Gate

A runtime gate that monitors agent output for potential credential leaks:

| Mode | Behaviour |
|---|---|
| `strict` | Halt the agent turn immediately on any detected leak |
| `warn` | Log the detection and continue (dev/debug contexts) |
| `off` | Disabled |

Default for unattended production runs: `strict`. Default for dev environments: `warn`.
Never ship a production loop with `off`.

## Session Watchdog and Hard Time Limits

Unattended agents can stall, crash, or spin indefinitely without a watchdog:

- Set a **hard session limit** (e.g. 2 hours) after which the agent sleeps and the
  watchdog restarts it cleanly from state file rather than letting it accumulate
  context indefinitely
- The watchdog monitors the agent process and restarts crashed sessions without
  human intervention
- Implement via systemd or equivalent process supervisor — not a shell loop,
  which can itself become a zombie

This is distinct from `--max-turns` (turn cap) and `--max-budget-usd` (cost cap):
both are inside the process. The watchdog operates outside it.

See [Long-Running Agents](25-long-running-agents.md) for state recovery patterns.

## Relationship to Permissions & Allowlists

The [Permissions & Auto Mode](08-permissions.md) doc covers the software-layer companion
to OS-level hardening: risk-tiered authorization by consequence (read/write/irreversible),
`allow`/`deny`/`ask` lists in `.claude/settings.json`, and the safety path denylist
for sensitive file paths.

OS-user isolation and software-layer permissions enforce the same boundary from
different layers: OS rules prevent kernel-level escape; permission lists prevent
the model from taking in-process actions it was never meant to take. Both are needed;
neither alone is sufficient.

## Relationship to MCP Security

[MCP Security](19-mcp-security.md) covers AgentJacking and prompt injection via MCP
connectors. Agent security hardening operates one layer below: it enforces boundaries
even when a connector has been compromised or an agent has accepted a malicious
instruction. The two layers are complementary, not alternatives.

For fleet-scale deployment see [Fleet Engineering](23-fleet-engineering.md).
