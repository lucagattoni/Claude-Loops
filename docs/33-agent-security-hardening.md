# Agent Security Hardening

`CLAUDE.md` rules and permission allowlists protect against accidents. They do not
protect against a compromised prompt, a leaked credential, or an agent escaping its
intended scope. Production unattended loops require security enforced at the OS and
network layer — below the model, not inside it.

(Based on clem — [jahwag/clem](https://github.com/jahwag/clem), Jun 2026.)

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

## Runtime Policy Gating (below the matrix)

SECURITY_MATRIX.md is a static document the agent self-checks against. A stronger layer
is a **runtime policy engine** that gates each action mechanically, independent of the
model's cooperation:

| Policy | Gates on | Purpose |
|---|---|---|
| **blast_radius** | The scope/impact a single action can have | Bound the damage any one step can do (a containment budget, not a permission list) |
| **intent_gate** | Whether the operation matches the agent's *stated* intent | Default-deny: an action the agent never declared it would take is refused |
| **phase-scoped tool access** | Which native tools are callable *in the current phase* | A search-phase agent cannot commit; a build-phase agent cannot deploy |

`intent_gate` is the closest public mechanism to the default-deny loading the
SECURITY_MATRIX implies: instead of enumerating attacks to refuse, it refuses anything
outside the declared plan. `blast_radius` complements it by capping *how much* an
allowed action may touch. ([omnigent-ai/omnigent](https://github.com/omnigent-ai/omnigent), Jul 2026.)

**Update (Jul 2026):** `intent_gate` was renamed **Intent Based Authorization** and its
off-task-tool-call policy softened from hard-`DENY` to `ASK` — an off-plan action now
prompts the human for approval instead of silently refusing, trading strict default-deny
for a human-in-the-loop escalation on the boundary case. The all-or-nothing refusal
remains the default for clearly out-of-scope actions; `ASK` only applies to the
ambiguous middle. ([omnigent-ai/omnigent](https://github.com/omnigent-ai/omnigent), Jul 2026.)

### Where Default-Deny Actually Gets Loaded

The open question was never *whether* to default-deny — it's *where in the stack* the
policy gets enforced so it can't be bypassed by the model simply not calling it. Four
concrete answers converged this cycle, each intercepting at a different layer:

| Layer | Mechanism | Cannot be bypassed by... |
|---|---|---|
| **MCP proxy** | A standalone daemon sits in front of every MCP server, verifying agent identity and denying tool calls by default before they reach the server | The agent skipping a CLAUDE.md rule — the proxy is a separate process the agent never talks to directly |
| **Tool-dispatch layer** | Destination-aware egress control enforced at the point every tool call is dispatched, shared across Claude Code *and* Codex from one policy | Switching harnesses — the policy lives below the harness, not inside it |
| **OS/kernel** | The policy engine is compiled into the OS layer itself; guardrails are enforced via kernel integration, not application code | The agent's own process — kernel enforcement holds even if the agent process is fully compromised |
| **Session bootstrap + eval parity** | A bounded runtime loads a default-deny MCP policy at session start and runs its eval suite over the *same code path* as production | Config drift between "the policy we tested" and "the policy that's live" |

The pattern across all four: **the highest-assurance loading mechanisms move the
default-deny check outside the process the model runs in** — a proxy daemon, the
tool-dispatch layer, or the kernel — rather than trusting a CLAUDE.md import or a
SessionStart hook the model's own process could theoretically route around.
([mcpharbour/mcpharbour](https://github.com/mcpharbour/mcpharbour);
[saagpatel/cross-provider-egress-guard](https://github.com/saagpatel/cross-provider-egress-guard);
ActPlane, [arXiv 2606.25189](https://arxiv.org/abs/2606.25189);
[codeafix/agent-assistant](https://github.com/codeafix/agent-assistant), Jul 2026.)

## Credential Rotation Mid-Session

Provisioning and resolving credentials (above) is not enough for long-running loops:
credentials expire or get compromised *during* a run, and blind rotation can sever a
live consumer. A safe in-session rotation loop is a **verify-before-revoke cutover**:

```
discover → reconcile → assess → prioritize → plan
  → [Gate 1: approve staging] → stage
  → [Gate 2: approve cutover] → cutover → report
```

- **Classify, and treat unknowns as unsafe.** Reconcile live credentials against managed
  inventory into four states: *in store & rotating* → DEFER; *in store, not rotating* →
  OWN_STALE; *absent from all stores* → OWN_UNMANAGED; *unreachable/unclassifiable* →
  UNKNOWN → **"escalated, never assumed safe."**
- **Never revoke before verifying the replacement.** The cutover is
  **promote → repoint → verify**, and the old credential is revoked *only after*
  verification passes. On verify failure, consumers repoint back to the still-valid old
  credential and the run escalates — "nothing is lost."
- **Stop if blast radius is unknown.** The `assess` step blocks if consumers can't be
  fully enumerated — you cannot safely rotate a credential whose dependents you can't see
  (this is the [blast_radius](#runtime-policy-gating-below-the-matrix) principle applied to secrets).

([rashmi1112/Credential-Sentinel](https://github.com/rashmi1112/Credential-Sentinel), Jul 2026.)

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

## Credential Resolution Without Model Exposure (credbroker)

A common credential mistake: secrets are resolved in the prompt or system context,
making them visible to the model. A better pattern resolves credentials entirely
outside model context:

```bash
pip install credbroker
```

**[credbroker](https://pypi.org/project/credbroker/)** resolves credentials in this order:
1. Environment variables
2. OS keyring (Keychain, Windows Credential Store, libsecret)
3. Dotfiles (`.env`, `~/.netrc`)

The resolved value is injected as an environment variable that the tool reads directly.
The model never sees the credential value — only the tool can access it.

This is distinct from the provisioning pattern (generating short-lived tokens):
credbroker handles *resolution of existing credentials* without exposure.
Use both: provision short-lived credentials, then resolve them via credbroker.

([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Jun 2026.)

## Skill Ingestion Security (OWASP Agentic Skills Top 10)

Credential and OS-level hardening (above) assume the agent's own skills/plugins are
trustworthy. They may not be: a skill installed from a marketplace or catalog is a
supply-chain surface with its own attack class — the **OWASP Agentic Skills Top 10**
(AST01–AST10) names it: malicious natural-language instructions embedded in a skill,
permission over-declaration, unsafe metadata parsing, SSRF/external-reference integrity,
and isolation-boundary violations.

The mitigation is a **mandatory reviewer-only, non-automatable security gate** at the
skill-ingestion step: before a new skill/pack is assimilated into a harness, a human (or
a fully independent reviewer agent) checks it against the AST01–AST10 checklist — this
gate cannot be satisfied by the ingesting agent self-certifying, since a compromised
skill could falsify its own compliance claim.
([eugenelim/agent-ready-repo](https://github.com/eugenelim/agent-ready-repo), Jul 2026.)

## Grading Harness Security Posture

The patterns above (OS-user isolation, credential disposition, runtime policy gating)
are individually well-specified but hard to audit *in aggregate* — a harness might get
credential handling right and egress control wrong. A **harness security scorecard**
closes that gap: grade a harness A–F across ten dimensions (secret protection, egress
control, prompt-injection defense, git safety, harness self-protection, verification
gates, subagent isolation, rollback safety, provenance, audit trail), using **capability
gates** that cap the overall grade when the effective enforcement floor is weak — e.g. a
rich `deny` list scores no better than its weakest override (a `bypassPermissions` flag
discounts an otherwise-strong hard-deny block). Each gate is proven against a
vulnerable/fixed fixture pair rather than graded by inspection alone, so the score is
reproducible. Use this as an audit step alongside — not instead of — the design
patterns above. ([saagpatel/harness-scorecard](https://github.com/saagpatel/harness-scorecard), Jul 2026.)

## Relationship to MCP Security

[MCP Security](19-mcp-security.md) covers AgentJacking and prompt injection via MCP
connectors. Agent security hardening operates one layer below: it enforces boundaries
even when a connector has been compromised or an agent has accepted a malicious
instruction. The two layers are complementary, not alternatives.

For fleet-scale deployment see [Fleet Engineering](23-fleet-engineering.md).
