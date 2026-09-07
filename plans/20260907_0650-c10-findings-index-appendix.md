# C10 appendix — the 335 actionable changelog findings, indexed

**Why this file exists.** The C10 evidence pack says the findings left unrefuted under the
refutation cap are *"marked, not hidden"*. That was only true inside a workflow transcript, which
does not survive a session. This index makes it true on disk. Caught during the pre-clear check for
step 11.

**What this is and is not.** These are the findings that survived verification against the
changelog and the KB — **not** a list of defects. 319 of them are `KB_GAP`, meaning *the KB is
silent*, and **silence is usually correct**: a doc is a curated argument, not a changelog mirror.
Per-doc triage cut all 335 down to 29 applied edits deliberately. **Do not treat an unapplied row
here as outstanding work.** Its value is as a re-audit surface: if a future pass suspects a doc is
thin on some platform area, this says what the changelog offered and what was decided.

Sorted `KB_WRONG` → `KB_STALE` → `KB_GAP`, then by severity.

| Verdict | n | Meaning |
|---|---|---|
| `KB_WRONG` | 6 | the KB asserts something the changelog contradicts — all applied |
| `KB_STALE` | 10 | right for an older version, behaviour has since changed |
| `KB_GAP` | 319 | the KB is silent; mostly correct to stay silent |

| # | Verdict | Sev | Version | Target doc | Finding |
|---|---|---|---|---|---|
| 1 | `KB_WRONG` | high | `2.1.0` | docs/08-permissions.md | Permission pattern-token table is stale and asserts an unconfirmed `?` token |
| 2 | `KB_WRONG` | high | `2.1.49` | docs/08-permissions.md | Settings-precedence section has the managed-policy override direction backwards |
| 3 | `KB_WRONG` | high | `v2.1.3` | docs/12-hooks.md | Hook timeout table is wrong for command, http, AND mcp_tool hooks |
| 4 | `KB_WRONG` | high | `2.1.49` | docs/12-hooks.md | Hooks doc's own scope hierarchy has the same managed-policy-last error |
| 5 | `KB_WRONG` | high | `v2.1.69` | docs/12-hooks.md | TeammateIdle/TaskCompleted's continue:false stops one teammate, not the whole session — doc12 states the opposite scope |
| 6 | `KB_WRONG` | high | `2.1.105` | docs/12-hooks.md | docs/12's hook table says PreCompact cannot block — it can, since v2.1.105 |
| 7 | `KB_STALE` | high | `v2.1.9` | docs/12-hooks.md | additionalContext is documented as Stop/SubagentStop-only, but it's now general |
| 8 | `KB_STALE` | medium | `1.0.90` | docs/08-permissions.md | The 1.0.90 blanket claim is now an oversimplification; the real (narrower) rule is undocumented |
| 9 | `KB_STALE` | medium | `2.1.178` | docs/08-permissions.md | Tool-parameter permission syntax documented but not version-stamped |
| 10 | `KB_STALE` | medium | `v2.1.261` | docs/08-permissions.md | Missing latest row in the KB's own versioned rm-rf safety-prompt table |
| 11 | `KB_STALE` | medium | `2.1.136` | docs/15-explore-plan-implement.md | Plan mode's write-block guarantee had a bypass via allow rules, pre-2.1.136 |
| 12 | `KB_STALE` | medium | `v2.1.20` | docs/29-background-agents.md | Doc describes background agents as fire-and-forget with prompts surfacing only mid-run — a pre-launch prompt changes that |
| 13 | `KB_STALE` | low | `2.1.98` | docs/09-headless-mode.md | --exclude-dynamic-system-prompt-sections is documented but carries no version marker |
| 14 | `KB_STALE` | low | `2.1.169` | docs/09-headless-mode.md | `--safe-mode` documented correctly but missing its version marker |
| 15 | `KB_STALE` | low | `v2.1.261` | docs/09-headless-mode.md | File-based variant of an already-documented flag is missing |
| 16 | `KB_STALE` | low | `v2.1.199` | docs/12-hooks.md | Hooks that can't block still silently hid stderr on exit 2, until v2.1.199 |
| 17 | `KB_GAP` | high | `2.1.144` | docs/02-agent-loop-cycle.md | Read-before-edit and grep exit-code handling loosened |
| 18 | `KB_GAP` | high | `2.0.12` | docs/03-building-blocks.md | The Plugin System (marketplaces bundling commands/agents/hooks/MCP) is missing; doc03's '4. Plugins / Connectors' section only covers MCP + Chrome |
| 19 | `KB_GAP` | high | `2.1.119` | docs/03-building-blocks.md | Worktree isolation's "enforcement, not convention" claim had a real, more severe bypass |
| 20 | `KB_GAP` | high | `2.1.128 / 2.1.133` | docs/03-building-blocks.md | worktree.baseRef default is "fresh" (origin) — KB never states it, so unpushed commits are silently dropped |
| 21 | `KB_GAP` | high | `2.1.153` | docs/03-building-blocks.md | Agent tool silently discarded gitignored subagent output before v2.1.153 |
| 22 | `KB_GAP` | high | `2.1.149` | docs/03-building-blocks.md | Worktree sandbox once allowed writes across the whole main repo |
| 23 | `KB_GAP` | high | `1.0.123` | docs/06-skills.md | SlashCommand tool (Claude invoking its own slash commands) is undocumented |
| 24 | `KB_GAP` | high | `2.1.105` | docs/06-skills.md | docs/06 has zero SKILL.md frontmatter reference despite owning 'Skills — SKILL.md' |
| 25 | `KB_GAP` | high | `2.1.119` | docs/06-skills.md | Skill silently re-firing across a compaction boundary — matches the KB's own 'silent default' defect class |
| 26 | `KB_GAP` | high | `2.0.43` | docs/07-subagents.md | Subagent `skills:` frontmatter field is undocumented |
| 27 | `KB_GAP` | high | `2.1.77` | docs/07-subagents.md | Doc 07's version-stamped background table skips the resume-mechanism API change |
| 28 | `KB_GAP` | high | `2.1.78` | docs/07-subagents.md | Doc 07's custom-agent frontmatter example is missing most current fields |
| 29 | `KB_GAP` | high | `2.1.153` | docs/07-subagents.md | Subagent-declared MCP servers bypassed session-level and managed MCP policy until v2.1.153 — undocumented in docs/07 |
| 30 | `KB_GAP` | high | `2.1.178` | docs/07-subagents.md | Auto mode not reviewing subagent spawns (now fixed) is undocumented in both Subagents and Permissions |
| 31 | `KB_GAP` | high | `2.1.178` | docs/07-subagents.md | Subagent-level MCP tool blocking bug is undocumented |
| 32 | `KB_GAP` | high | `2.1.186` | docs/07-subagents.md | Background-subagent permission handling missing from the background-subagent version table |
| 33 | `KB_GAP` | high | `v2.1.199` | docs/07-subagents.md | Subagent silent-failure-as-success fix (v2.1.199) missing from the subagent-resilience section |
| 34 | `KB_GAP` | high | `1.0.45` | docs/08-permissions.md | Concurrent-session ~/.claude.json safety — undocumented, and this KB's own worktree workflow runs exactly the failure mode |
| 35 | `KB_GAP` | high | `2.0.70` | docs/08-permissions.md | MCP wildcard permission syntax is undocumented |
| 36 | `KB_GAP` | high | `2.0.54` | docs/08-permissions.md | PermissionRequest hook's persistent-approval mechanism is undocumented |
| 37 | `KB_GAP` | high | `v2.1.34` | docs/08-permissions.md | A real permission-bypass security bug is missing from the KB's own auto-mode/sandbox change history table |
| 38 | `KB_GAP` | high | `v2.1.69` | docs/08-permissions.md | acceptEdits mode had a symlink escape (fixed v2.1.69) — fits doc08's existing security-gotcha table |
| 39 | `KB_GAP` | high | `v2.1.69` | docs/08-permissions.md | allowManagedDomainsOnly had a human-approvable bypass (fixed v2.1.69), and a second unrelated enforcement gap surfaced later at v2.1.126 |
| 40 | `KB_GAP` | high | `2.1.121 / 2.1.126` | docs/08-permissions.md | bypassPermissions scope widened twice in-slice (skills/agents/commands, then .claude/.git/.vscode/shell-config) — undocumented in the KB's permissions |
| 41 | `KB_GAP` | high | `2.1.162` | docs/08-permissions.md | An explicit WebFetch deny rule used to be overridden by the built-in preapproved-domain auto-allow |
| 42 | `KB_GAP` | high | `2.1.162` | docs/08-permissions.md | Windows-style backslash permission rules never matched, and a Read deny rule didn't hide files from Glob/Grep |
| 43 | `KB_GAP` | high | `2.1.157` | docs/08-permissions.md | Sandbox network permission prompts used to interrupt auto/bypass-permissions mode, defeating unattended operation |
| 44 | `KB_GAP` | high | `2.1.175` | docs/08-permissions.md | The `availableModels` allowlist mechanism is entirely absent from the KB |
| 45 | `KB_GAP` | high | `2.1.169` | docs/08-permissions.md | Managed MCP allow/deny lists are a persistently fragile mechanism the KB never mentions |
| 46 | `KB_GAP` | high | `2.1.183` | docs/08-permissions.md | Auto-mode destructive-command guardrails missing from the version table |
| 47 | `KB_GAP` | high | `2.0.19` | docs/09-headless-mode.md | Bash auto-backgrounding on timeout (BASH_DEFAULT_TIMEOUT_MS) is undocumented |
| 48 | `KB_GAP` | high | `v2.1.69` | docs/09-headless-mode.md | Path-scoped rules and nested CLAUDE.md silently did not load under claude -p — direct hit on doc09's headless-mode remit |
| 49 | `KB_GAP` | high | `2.1.119` | docs/09-headless-mode.md | Agent-frontmatter tool restrictions were not a headless boundary before v2.1.119 |
| 50 | `KB_GAP` | high | `2.1.147` | docs/09-headless-mode.md | Headless/SDK mode silently no-op'd on an unknown slash command before v2.1.147 |
| 51 | `KB_GAP` | high | `2.1.161` | docs/09-headless-mode.md | Background subagent output could corrupt the parsed stdout of a headless `-p` run |
| 52 | `KB_GAP` | high | `v2.1.199 / v2.1.239 / v2.1.261` | docs/09-headless-mode.md | Native retry/timeout env vars entirely undocumented next to a whole hand-rolled retry-wrapper section |
| 53 | `KB_GAP` | high | `2.1.161` | docs/10-fan-out.md | A failed Bash call in a parallel batch used to cancel every sibling call |
| 54 | `KB_GAP` | high | `1.0.77` | docs/11-cost-control.md | The opusplan model alias is undocumented anywhere in the KB (doc07/doc11/doc15 all silent) |
| 55 | `KB_GAP` | high | `1.0.88` | docs/11-cost-control.md | ANTHROPIC_DEFAULT_*_MODEL env vars are undocumented in doc11 |
| 56 | `KB_GAP` | high | `v2.1.69` | docs/11-cost-control.md | CLAUDE_CODE_MAX_OUTPUT_TOKENS is entirely undocumented in the KB, and had two separate reliability bugs |
| 57 | `KB_GAP` | high | `2.1.97` | docs/11-cost-control.md | 429 retry logic could exhaust its own budget in 13 seconds |
| 58 | `KB_GAP` | high | `1.0.68` | docs/12-hooks.md | disableAllHooks global kill switch is undocumented in doc12 |
| 59 | `KB_GAP` | high | `2.1.76` | docs/12-hooks.md | MCP elicitation can block an unattended run — undocumented, and directly in doc12/doc19's remit |
| 60 | `KB_GAP` | high | `2.1.77` | docs/12-hooks.md | Doc 12 documents hook permissionDecision output but not deny-first precedence |
| 61 | `KB_GAP` | high | `v2.1.89` | docs/12-hooks.md | `defer` permission decision is named but never explained |
| 62 | `KB_GAP` | high | `v2.1.90` | docs/12-hooks.md | The KB's own worked PostToolUse auto-lint example is exactly the pattern this bug (and its 2.1.89 companion warning) affects |
| 63 | `KB_GAP` | high | `2.1.163` | docs/12-hooks.md | Hook `if`-condition matching has a real, repeated-bug history the doc doesn't flag |
| 64 | `KB_GAP` | high | `1.0.86` | docs/13-context-management.md | /context — the primary context-debugging command — is completely absent from doc13 |
| 65 | `KB_GAP` | high | `v2.1.7 / v2.1.14` | docs/13-context-management.md | Context-window blocking limit (the hard stop, distinct from auto-compact) is undocumented |
| 66 | `KB_GAP` | high | `v2.1.69` | docs/13-context-management.md | MCP tools used to dump raw base64 binary content straight into context — a real, undocumented context-budget fact |
| 67 | `KB_GAP` | high | `v2.1.89` | docs/13-context-management.md | The KB recommends a manual 3-strikes compaction circuit breaker that the product has actually shipped natively since v2.1.89 |
| 68 | `KB_GAP` | high | `2.1.117` | docs/13-context-management.md | Doc 13's auto-compact version history starts after this earlier, more basic context-window bug |
| 69 | `KB_GAP` | high | `v2.1.69` | docs/14-human-in-the-loop.md | Skill allowed-tools could silently defeat AskUserQuestion escalation |
| 70 | `KB_GAP` | high | `v2.1.85` | docs/14-human-in-the-loop.md | The deterministic alternative to the AskUserQuestion timeout is undocumented |
| 71 | `KB_GAP` | high | `2.1.119` | docs/15-explore-plan-implement.md | Plan mode's human-checkpoint gate was overridable by auto mode before v2.1.119 |
| 72 | `KB_GAP` | high | `0.2.93` | docs/16-memory-patterns.md | Native TodoWrite tool is off by default on current models — KB never mentions it |
| 73 | `KB_GAP` | high | `v2.1.33` | docs/16-memory-patterns.md | Subagent memory has a third scope — `local` — that the KB never mentions |
| 74 | `KB_GAP` | high | `v2.1.69` | docs/19-mcp-security.md | MCP server trust flow silently over-trusted on first run (fixed v2.1.69) — MCP-security doc never covers the trust/approval flow at all |
| 75 | `KB_GAP` | high | `2.1.129` | docs/19-mcp-security.md | deniedMcpServers/allowedMcpServers enforcement has a long history of gaps — the mechanism itself is entirely absent from the KB's MCP security doc |
| 76 | `KB_GAP` | high | `2.1.154` | docs/19-mcp-security.md | Headless/CI runs used to silently auto-connect unapproved MCP servers |
| 77 | `KB_GAP` | high | `2.1.154` | docs/19-mcp-security.md | allowedMcpServers/deniedMcpServers — a whole enterprise MCP policy mechanism the KB never describes |
| 78 | `KB_GAP` | high | `2.1.161` | docs/19-mcp-security.md | MCP config commands used to print secrets to the terminal |
| 79 | `KB_GAP` | high | `2.1.183` | docs/19-mcp-security.md | MCP auth-stub tool exposure bug absent from the MCP security doc |
| 80 | `KB_GAP` | high | `2.1.59` | docs/23-fleet-engineering.md | Fleet doc asks "what happens with 50 running simultaneously" but never answers the shared-config-corruption risk |
| 81 | `KB_GAP` | high | `2.1.186` | docs/25-long-running-agents.md | CLAUDE_CODE_RETRY_WATCHDOG / CLAUDE_CODE_MAX_RETRIES entirely absent from Long-Running Agents |
| 82 | `KB_GAP` | high | `2.1.187` | docs/25-long-running-agents.md | CLAUDE_CODE_MCP_TOOL_IDLE_TIMEOUT absent — a loop's exact 'zombie agent' risk, undocumented |
| 83 | `KB_GAP` | high | `2.1.139` | docs/28-routines.md | API-key auth silently forecloses Routines/schedule — docs/28 never says so |
| 84 | `KB_GAP` | high | `2.1.183` | docs/28-routines.md | A security-relevant Routines-trigger bug is not disclosed in the Routines doc |
| 85 | `KB_GAP` | high | `1.0.71` | docs/29-background-agents.md | Ctrl+B interactive backgrounding is entirely absent from doc29 |
| 86 | `KB_GAP` | high | `2.1.98` | docs/29-background-agents.md | Monitor tool used but never introduced — internal KB inconsistency |
| 87 | `KB_GAP` | high | `2.1.142` | docs/29-background-agents.md | claude agents dispatch-configuration flags are undocumented |
| 88 | `KB_GAP` | high | `2.1.141` | docs/29-background-agents.md | Background-session permission-mode inheritance, later refined |
| 89 | `KB_GAP` | high | `2.1.143` | docs/29-background-agents.md | claude-agents dispatches used to force auto mode regardless of settings |
| 90 | `KB_GAP` | high | `2.1.143` | docs/29-background-agents.md | claude-agents skip-permissions flag used to default to bypass, not just offer it |
| 91 | `KB_GAP` | high | `2.1.160` | docs/29-background-agents.md | Background/resumed sessions have repeatedly re-run the original prompt from scratch, losing history — a recurring class, not a one-off |
| 92 | `KB_GAP` | high | `2.1.193` | docs/29-background-agents.md | Interactive backgrounding (←←) is an undocumented surface, and its correctness bug with it |
| 93 | `KB_GAP` | high | `v2.1.198 → v2.1.221 (superseded)` | docs/29-background-agents.md | Background-agent draft-PR behavior changed again after 2.1.198 — bullet itself is stale |
| 94 | `KB_GAP` | high | `v2.1.38` | docs/33-agent-security-hardening.md | A named command-smuggling security fix is missing from the agent-security-hardening doc |
| 95 | `KB_GAP` | high | `v2.1.69` | docs/33-agent-security-hardening.md | Skill discovery could load skills from gitignored node_modules — a third instance of the repo-config-can't-escalate-itself pattern doc33 already track |
| 96 | `KB_GAP` | high | `2.1.83` | docs/33-agent-security-hardening.md | A native fifth credential-isolation disposition is missing from doc 33's table |
| 97 | `KB_GAP` | high | `2.1.78` | docs/33-agent-security-hardening.md | The sandbox's own 'default that means success' bug, and its fail-closed fix, are absent |
| 98 | `KB_GAP` | high | `2.1.113` | docs/33-agent-security-hardening.md | Sandbox network denylist and a sandbox-bypass fix are missing from doc 33's own sandbox history |
| 99 | `KB_GAP` | high | `2.1.126` | docs/33-agent-security-hardening.md | Same settings-precedence sandbox-bypass class as the v2.1.232 ripgrep gap, six versions earlier |
| 100 | `KB_GAP` | high | `2.1.193` | docs/33-agent-security-hardening.md | A silent-default-drift privacy risk on OTel upgrade is completely absent from the KB |
| 101 | `KB_GAP` | high | `2.1.77` | docs/37-session-architecture.md | /fork, /branch, /subtask — KB is completely silent on all three |
| 102 | `KB_GAP` | high | `2.1.129 / 2.1.211 / 2.1.221` | docs/37-session-architecture.md | OAuth wake-from-sleep logout race is a recurring bug across at least three versions, not a one-time fix |
| 103 | `KB_GAP` | high | `2.1.141` | docs/37-session-architecture.md | /model used to leak autocompact-threshold state across sessions |
| 104 | `KB_GAP` | high | `2.1.144` | docs/37-session-architecture.md | /model is now explicitly session-scoped, resolving the earlier cross-session bleed |
| 105 | `KB_GAP` | high | `2.1.166` | docs/37-session-architecture.md | SendMessage relayed-authority hardening absent from Session Architecture |
| 106 | `KB_GAP` | high | `2.1.119` | docs/38-agent-teams.md | Task tools (TaskCreate/TaskList/TaskUpdate/TodoWrite) are opt-in on current default models |
| 107 | `KB_GAP` | medium | `2.1.183` | docs/02-agent-loop-cycle.md | Thinking-only silent-turn bug is a gap in the Loop Termination signal list |
| 108 | `KB_GAP` | medium | `v2.1.30` | docs/03-building-blocks.md | Connectors section documents `claude mcp add` but not the non-DCR auth path (Slack is the named example) |
| 109 | `KB_GAP` | medium | `v2.1.69` | docs/03-building-blocks.md | Plugin-sourced WorktreeCreate/WorktreeRemove hooks silently ignored — critical because doc03 marks these hooks load-bearing for non-git VCS |
| 110 | `KB_GAP` | medium | `v2.1.89` | docs/03-building-blocks.md | cleanupPeriodDays: 0 footgun (silent-disable, now a validation error) is missing next to the KB's own cleanup discussion |
| 111 | `KB_GAP` | medium | `2.1.133` | docs/03-building-blocks.md | worktree.baseRef default flip (origin/<default> vs local HEAD) undocumented |
| 112 | `KB_GAP` | medium | `2.1.141` | docs/03-building-blocks.md | Hook transcript_path went stale after EnterWorktree |
| 113 | `KB_GAP` | medium | `2.1.143` | docs/03-building-blocks.md | Worktree cleanup dropped its destructive rm -rf fallback |
| 114 | `KB_GAP` | medium | `1.0.94` | docs/05-claude-md.md | /memory's original job — editing CLAUDE.md and its @-imports — is undocumented in doc05; doc16 only covers its later auto-memory-toggle job |
| 115 | `KB_GAP` | medium | `v2.1.20` | docs/05-claude-md.md | CLAUDE.md doc never mentions --add-dir loading, gated behind an opt-in env var |
| 116 | `KB_GAP` | medium | `1.0.30` | docs/06-skills.md | `.claude/commands/` custom slash commands are a distinct, still-current mechanism never mentioned alongside Skills |
| 117 | `KB_GAP` | medium | `1.0.45` | docs/06-skills.md | Slash-command subdirectory namespacing is entirely undocumented in doc06 |
| 118 | `KB_GAP` | medium | `1.0.57` | docs/06-skills.md | model: frontmatter for slash commands is undocumented in doc06 |
| 119 | `KB_GAP` | medium | `2.0.74` | docs/06-skills.md | Skill frontmatter mechanics (allowed-tools et al.) entirely absent from docs/06 |
| 120 | `KB_GAP` | medium | `2.1.0` | docs/06-skills.md | Skill hot-reload absent from docs/06 |
| 121 | `KB_GAP` | medium | `2.1.0` | docs/06-skills.md | `context: fork` skill frontmatter — a distinct mechanism from doc07's subagent `fork`, undocumented, and its default already changed |
| 122 | `KB_GAP` | medium | `v2.1.19` | docs/06-skills.md | Skills doc never covers the permission/approval mechanics of running a skill |
| 123 | `KB_GAP` | medium | `v2.1.32` | docs/06-skills.md | KB never says `--add-dir` directories' skills load automatically |
| 124 | `KB_GAP` | medium | `v2.1.32` | docs/06-skills.md | KB's skill-compression discussion never states the actual description-budget formula |
| 125 | `KB_GAP` | medium | `2.1.91` | docs/06-skills.md | disableSkillShellExecution — unattended-skill lockdown setting, undocumented |
| 126 | `KB_GAP` | medium | `2.1.152` | docs/06-skills.md | New skill-scoped tool-restriction frontmatter field, absent from docs/06 |
| 127 | `KB_GAP` | medium | `2.1.145` | docs/06-skills.md | A context: fork skill could infinite-loop before v2.1.145 — undocumented in docs/06 |
| 128 | `KB_GAP` | medium | `2.1.157` | docs/06-skills.md | Doc 6 never mentions plugins at all, despite owning 'skill bundles' in the topic map |
| 129 | `KB_GAP` | medium | `2.1.169` | docs/06-skills.md | `disableBundledSkills` entirely absent from the Skills doc |
| 130 | `KB_GAP` | medium | `2.1.0` | docs/07-subagents.md | Permission-denial-as-stop-condition assumption is stale for subagents |
| 131 | `KB_GAP` | medium | `v2.1.16 / v2.1.19 / v2.1.20` | docs/07-subagents.md | No doc covers the base TaskCreate/TaskUpdate task system outside the agent-teams context |
| 132 | `KB_GAP` | medium | `v2.1.33` | docs/07-subagents.md | A distinct spawn-restriction mechanism (an agent's own `tools` field) is undocumented, and its syntax name changed |
| 133 | `KB_GAP` | medium | `v2.1.70` | docs/07-subagents.md | ToolSearch — the deferred-tool-loading mechanism this very review used — is completely undocumented in the KB, and had a silent-stop bug |
| 134 | `KB_GAP` | medium | `2.1.73` | docs/07-subagents.md | modelOverrides — real, current, enterprise-routing setting, entirely absent from the KB |
| 135 | `KB_GAP` | medium | `2.1.97` | docs/07-subagents.md | Worktree isolation leaked back to the parent session's Bash tool |
| 136 | `KB_GAP` | medium | `2.1.98` | docs/07-subagents.md | Worktree cleanup could destroy untracked work — data-loss risk |
| 137 | `KB_GAP` | medium | `2.1.116` | docs/07-subagents.md | Built-in gh-rate-limit backoff hint, and its false-positive fix, are undocumented |
| 138 | `KB_GAP` | medium | `2.1.126` | docs/07-subagents.md | An unrecoverable SDK hang on one malformed tool name inside a parallel batch — undocumented, and this KB's own fan-out/subagent docs assume parallel t |
| 139 | `KB_GAP` | medium | `2.1.133` | docs/07-subagents.md | Subagent + Skill composition is entirely undocumented in docs/07 |
| 140 | `KB_GAP` | medium | `2.1.178` | docs/07-subagents.md | Three subagent-monitoring reliability bugs are undocumented |
| 141 | `KB_GAP` | medium | `2.1.186` | docs/07-subagents.md | Deny-rule example (`Agent(model:opus)`) shown with no note that it was unenforced pre-v2.1.186 |
| 142 | `KB_GAP` | medium | `2.1.187` | docs/07-subagents.md | Depth-cap accounting bug for resumed/forked subagents not in the limits section |
| 143 | `KB_GAP` | medium | `0.2.74` | docs/08-permissions.md | apiKeyHelper (CI/headless credential refresh) is entirely unmentioned in the KB |
| 144 | `KB_GAP` | medium | `2.1.0` | docs/08-permissions.md | The changelog's own wording (`Task(AgentName)`) is wrong — current syntax is `Agent(AgentName)` |
| 145 | `KB_GAP` | medium | `v2.1.38` | docs/08-permissions.md | A sandbox write-restriction on skill files (relevant to any loop that self-authors skills) is undocumented |
| 146 | `KB_GAP` | medium | `2.1.51` | docs/08-permissions.md | Bash tool no longer sources login shell files by default, and the KB doesn't say so |
| 147 | `KB_GAP` | medium | `2.1.59` | docs/08-permissions.md | "Always allow" on compound bash commands has a long, still-unfinished bug history the KB never mentions |
| 148 | `KB_GAP` | medium | `v2.1.69` | docs/08-permissions.md | --setting-sources user failed to block project skills (fixed v2.1.69) — related bugs recur in the same area at other versions |
| 149 | `KB_GAP` | medium | `v2.1.70` | docs/08-permissions.md | defaultMode had yet another environment-specific silent-override — this is the fourth such gotcha doc08 tracks for this exact setting |
| 150 | `KB_GAP` | medium | `2.1.83` | docs/08-permissions.md | Doc 08's settings-precedence list predates the drop-in policy directory |
| 151 | `KB_GAP` | medium | `2.1.78` | docs/08-permissions.md | Doc 08's pattern-syntax examples never show the mcp__ deny namespace |
| 152 | `KB_GAP` | medium | `2.1.77` | docs/08-permissions.md | Sandbox filesystem allow/deny settings are absent from doc 08 |
| 153 | `KB_GAP` | medium | `2.1.97` | docs/08-permissions.md | Unattended --dangerously-skip-permissions could silently stop being unattended |
| 154 | `KB_GAP` | medium | `2.1.98` | docs/08-permissions.md | Bash read-only-flag RCE bypass — fixed, worth a version floor |
| 155 | `KB_GAP` | medium | `2.1.97` | docs/08-permissions.md | Managed-settings revocations didn't take effect until restart |
| 156 | `KB_GAP` | medium | `2.1.118` | docs/08-permissions.md | Custom auto-mode rules silently replace the built-in safety list without `$defaults` |
| 157 | `KB_GAP` | medium | `2.1.119` | docs/08-permissions.md | The settings-precedence list doesn't say `/config`-set values are covered, and only since v2.1.119 |
| 158 | `KB_GAP` | medium | `2.1.129` | docs/08-permissions.md | A documented allow-rule syntax silently didn't work for in-project paths — undocumented in the KB's own worked allow-rule example |
| 159 | `KB_GAP` | medium | `2.1.139` | docs/08-permissions.md | docs/08 has no Skill(...) permission-rule syntax at all |
| 160 | `KB_GAP` | medium | `2.1.136` | docs/08-permissions.md | auto mode's hard_deny — an unconditional-block tier beyond deny/ask — is missing from the exhaustive auto-mode changelog table |
| 161 | `KB_GAP` | medium | `2.1.143` | docs/08-permissions.md | PowerShell tool default-on for enterprise gateways is undocumented |
| 162 | `KB_GAP` | medium | `2.1.152` | docs/08-permissions.md | docs/08's auto-mode timeline table starts at v2.1.205, skipping the v2.1.152 general opt-in-consent removal |
| 163 | `KB_GAP` | medium | `2.1.149` | docs/08-permissions.md | docs/08's permission-bypass history is entirely Bash-centric; two PowerShell-specific bypasses are undocumented |
| 164 | `KB_GAP` | medium | `2.1.145` | docs/08-permissions.md | A bare env-var assignment permission bypass, absent from docs/08's bypass table |
| 165 | `KB_GAP` | medium | `2.1.163` | docs/08-permissions.md | Version-pinning managed settings absent from Permissions doc |
| 166 | `KB_GAP` | medium | `2.1.163` | docs/08-permissions.md | $HOME deny-rule bypass is undocumented in the Safety Path Denylist |
| 167 | `KB_GAP` | medium | `2.1.172` | docs/08-permissions.md | WebFetch domain-wildcard and mid-pattern-glob bugs are undocumented |
| 168 | `KB_GAP` | medium | `2.1.193` | docs/08-permissions.md | autoMode.classifyAllShell setting absent from the auto-mode reference |
| 169 | `KB_GAP` | medium | `2.1.191` | docs/08-permissions.md | Sandbox network-permission persistence behavior is undocumented |
| 170 | `KB_GAP` | medium | `1.0.59` | docs/09-headless-mode.md | SDK canUseTool permission callback is undocumented in doc09 |
| 171 | `KB_GAP` | medium | `2.0.64` | docs/09-headless-mode.md | Named-session addressing (`/rename`, `--resume <name>`) is undocumented |
| 172 | `KB_GAP` | medium | `2.0.62` | docs/09-headless-mode.md | Commit/PR attribution setting is undocumented |
| 173 | `KB_GAP` | medium | `v2.1.2` | docs/09-headless-mode.md | Headless-mode doc doesn't mention that large tool output now persists to disk rather than being cut off |
| 174 | `KB_GAP` | medium | `v2.1.27` | docs/09-headless-mode.md | Headless-mode doc's session-continuation section never mentions `--from-pr` |
| 175 | `KB_GAP` | medium | `v2.1.41` | docs/09-headless-mode.md | No KB doc documents scripted auth management for headless/CI setup |
| 176 | `KB_GAP` | medium | `v2.1.69` | docs/09-headless-mode.md | Resuming a session interrupted mid-tool-batch could hard-fail with API 400 (fixed v2.1.69) — undermines doc09's crash-recovery promise |
| 177 | `KB_GAP` | medium | `v2.1.69` | docs/09-headless-mode.md | Resuming with an orphaned tool result could throw a resumption-breaking error (fixed v2.1.69) — folded into the finding above |
| 178 | `KB_GAP` | medium | `2.1.81` | docs/09-headless-mode.md | Doc 09 describes what --bare skips correctly but omits its auth constraint |
| 179 | `KB_GAP` | medium | `v2.1.90` | docs/09-headless-mode.md | Interactive --resume picker silently excludes headless/SDK sessions — undocumented |
| 180 | `KB_GAP` | medium | `2.1.118` | docs/09-headless-mode.md | A stricter update-block env var than the one this repo's own pipeline uses |
| 181 | `KB_GAP` | medium | `2.1.132` | docs/09-headless-mode.md | Plan-mode + --permission-mode could silently drop on headless resume, pre-2.1.132 |
| 182 | `KB_GAP` | medium | `2.1.144` | docs/09-headless-mode.md | Skill tool briefly broken in headless mode between v2.1.141 and v2.1.144 |
| 183 | `KB_GAP` | medium | `2.1.162` | docs/09-headless-mode.md | An early SDK/stream-json interrupt could be silently dropped, leaving the turn running unseen |
| 184 | `KB_GAP` | medium | `2.1.170` | docs/09-headless-mode.md | A silent transcript-loss mode for --resume is undocumented |
| 185 | `KB_GAP` | medium | `2.1.178` | docs/09-headless-mode.md | Nested-skills headless bug and the nested-skills feature itself are both undocumented |
| 186 | `KB_GAP` | medium | `2.1.166` | docs/09-headless-mode.md | `--fallback-model` shown but unstamped; the persistent `fallbackModel` setting and its resilience behavior are missing |
| 187 | `KB_GAP` | medium | `2.1.128` | docs/10-fan-out.md | Fan-out reliability: one failing read-only command used to cancel the whole parallel batch — undocumented in the KB's fan-out doc |
| 188 | `KB_GAP` | medium | `2.0.17` | docs/11-cost-control.md | Mode-dependent default model switching (plan vs. execution) is undocumented in the pricing/model-routing doc |
| 189 | `KB_GAP` | medium | `2.1.0` | docs/11-cost-control.md | Auto-continue on output-token-limit cutoff changes what 'hit the output cap' means for a loop |
| 190 | `KB_GAP` | medium | `2.1.80` | docs/11-cost-control.md | Doc 11 covers /usage extensively but never mentions the statusline rate_limits field |
| 191 | `KB_GAP` | medium | `2.1.128` | docs/11-cost-control.md | Subagent progress-summary generation was tripling cache-creation cost and re-firing on idle transcripts — a concrete, undocumented cost driver in docs |
| 192 | `KB_GAP` | medium | `2.1.154` | docs/11-cost-control.md | Doc 11's model timeline references Opus 4.8 five times but never gives it its own entry |
| 193 | `KB_GAP` | medium | `2.1.166` | docs/11-cost-control.md | Thinking-token disable controls absent from Cost & Turn Control |
| 194 | `KB_GAP` | medium | `2.1.176` | docs/11-cost-control.md | A silent model-switch bug via Remote Control is undocumented |
| 195 | `KB_GAP` | medium | `2.1.0` | docs/12-hooks.md | `once: true` hook option undocumented |
| 196 | `KB_GAP` | medium | `v2.1.10` | docs/12-hooks.md | The Setup hook row exists but omits the CLI flags that fire it |
| 197 | `KB_GAP` | medium | `v2.1.89` | docs/12-hooks.md | `PermissionDenied` hook type missing from the lifecycle-events table |
| 198 | `KB_GAP` | medium | `v2.1.89` | docs/12-hooks.md | file_path-is-always-absolute contract, and its Windows gotcha, are undocumented |
| 199 | `KB_GAP` | medium | `v2.1.89` | docs/12-hooks.md | Hook output size cap is undocumented, and the changelog's own number (50K) is now stale |
| 200 | `KB_GAP` | medium | `v2.1.89` | docs/12-hooks.md | `if` field's pattern-matching against real (compound/env-prefixed) Bash commands is unstated |
| 201 | `KB_GAP` | medium | `2.1.101` | docs/12-hooks.md | docs/12/08 describe the PermissionRequest/PreToolUse hooks but never state hooks can't loosen a static deny |
| 202 | `KB_GAP` | medium | `2.1.139` | docs/12-hooks.md | Hooks losing terminal access is a capability change docs/12 never states |
| 203 | `KB_GAP` | medium | `2.1.139` | docs/12-hooks.md | Exec-form hook `args` field, avoiding shell quoting, is undocumented |
| 204 | `KB_GAP` | medium | `2.1.139` | docs/12-hooks.md | PostToolUse's decision:"block" mechanism (distinct from exit-code blocking) is undocumented |
| 205 | `KB_GAP` | medium | `2.1.141` | docs/12-hooks.md | New terminalSequence hook JSON output field is undocumented |
| 206 | `KB_GAP` | medium | `2.1.143` | docs/12-hooks.md | Stop-hook 8-block cap is documented but missing version + override env var |
| 207 | `KB_GAP` | medium | `2.1.145` | docs/12-hooks.md | docs/12 documents Stop/SubagentStop hook output but not this v2.1.145 input-field addition |
| 208 | `KB_GAP` | medium | `2.1.191` | docs/12-hooks.md | Multi-tool matcher syntax is undocumented, so its historical bug is invisible too |
| 209 | `KB_GAP` | medium | `v2.1.195` | docs/12-hooks.md | Hook matcher exact-match-vs-substring semantics never documented |
| 210 | `KB_GAP` | medium | `2.0.70` | docs/13-context-management.md | Status-line context-window fields are undocumented — and the candidate's own mechanism is superseded |
| 211 | `KB_GAP` | medium | `v2.1.7 / v2.1.9` | docs/13-context-management.md | MCP tool search is mentioned as a mitigation but its default-on status and threshold are undocumented |
| 212 | `KB_GAP` | medium | `v2.1.30` | docs/13-context-management.md | Context-management doc is entirely silent on PDF handling |
| 213 | `KB_GAP` | medium | `v2.1.31` | docs/13-context-management.md | The 100-page/20MB PDF limit is a citable fact the KB has nowhere |
| 214 | `KB_GAP` | medium | `2.1.51` | docs/13-context-management.md | Tool-result disk-persistence threshold (50K chars) is undocumented |
| 215 | `KB_GAP` | medium | `2.1.72` | docs/13-context-management.md | Tool Search (ToolSearch/deferred tools) is a real, current mechanism entirely absent from the KB |
| 216 | `KB_GAP` | medium | `2.1.91` | docs/13-context-management.md | MCP maxResultSizeChars annotation — undocumented context/MCP feature |
| 217 | `KB_GAP` | medium | `2.1.129` | docs/13-context-management.md | The `/context` command is entirely unmentioned in the KB's context-management doc, and this is a concrete, undocumented ~1.6k-token-per-call cost bug  |
| 218 | `KB_GAP` | medium | `2.1.132` | docs/13-context-management.md | Statusline context_window field was reporting cumulative, not current, usage before 2.1.132 |
| 219 | `KB_GAP` | medium | `2.1.141` | docs/13-context-management.md | Rewind's manual partial-compaction control is undocumented |
| 220 | `KB_GAP` | medium | `2.1.145` | docs/13-context-management.md | Read tool changed from hard error to silent partial read on oversized files — undocumented in docs/13 |
| 221 | `KB_GAP` | medium | `2.1.178` | docs/13-context-management.md | Compaction's fallback-model interaction is undocumented |
| 222 | `KB_GAP` | medium | `2.1.172` | docs/13-context-management.md | 1M-context-without-credits stuck state is undocumented |
| 223 | `KB_GAP` | medium | `v2.1.261` | docs/13-context-management.md | New context-budget levers for bash/task output entirely undocumented |
| 224 | `KB_GAP` | medium | `2.0.0` | docs/14-human-in-the-loop.md | /rewind (checkpoint undo) is essentially undocumented — doc14's Checkpoints section never names the actual undo mechanism |
| 225 | `KB_GAP` | medium | `2.1.110` | docs/14-human-in-the-loop.md | docs/14 covers passive timeout escalation but not the active push-notification escalation channel |
| 226 | `KB_GAP` | medium | `2.1.147` | docs/14-human-in-the-loop.md | A second, distinct AskUserQuestion escalation-suppression bug, not covered by docs/14's auto-continue saga |
| 227 | `KB_GAP` | medium | `2.1.181` | docs/14-human-in-the-loop.md | Another AskUserQuestion answer-loss bug missing from the human-in-the-loop reliability narrative |
| 228 | `KB_GAP` | medium | `2.1.120` | docs/17-failure-patterns.md | A Bash-tool `find` on a large tree could crash the whole host before v2.1.120 — an undocumented severe reliability bug for exactly the kind of filesys |
| 229 | `KB_GAP` | medium | `2.0.74` | docs/18-quick-reference.md | LSP tool absent from the KB's tool inventory |
| 230 | `KB_GAP` | medium | `2.1.0` | docs/18-quick-reference.md | File-read token-limit env var undocumented in cost-control doc |
| 231 | `KB_GAP` | medium | `2.1.162` | docs/18-quick-reference.md | Naming Grep/Glob in --tools used to silently no-op on native builds |
| 232 | `KB_GAP` | medium | `1.0.110` | docs/19-mcp-security.md | MCP OAuth token lifecycle is a long-running reliability hazard for unattended sessions, and doc19 (MCP security) never mentions OAuth at all |
| 233 | `KB_GAP` | medium | `2.0.22` | docs/19-mcp-security.md | Enterprise-managed MCP allow/deny list (allowedMcpServers/deniedMcpServers) is undocumented in the MCP security doc |
| 234 | `KB_GAP` | medium | `2.1.0` | docs/19-mcp-security.md | Dynamic MCP tool updates broaden the AgentJacking threat surface docs/19 already names |
| 235 | `KB_GAP` | medium | `v2.1.85` | docs/19-mcp-security.md | deniedMcpServers/allowedMcpServers denylist mechanism is entirely absent from MCP security doc, and its enforcement history is rockier than one fix su |
| 236 | `KB_GAP` | medium | `2.1.121 / 2.1.126` | docs/19-mcp-security.md | The ToolSearch tool-deferral mechanism — which governs whether MCP/built-in tools are visible at all — is completely absent from the KB, despite two i |
| 237 | `KB_GAP` | medium | `2.1.162` | docs/19-mcp-security.md | Sub-1000ms MCP per-server timeout used to abort every tool call |
| 238 | `KB_GAP` | medium | `v2.1.196` | docs/19-mcp-security.md | A repo-committed settings.json could self-approve its own MCP servers — undocumented trust-boundary fix |
| 239 | `KB_GAP` | medium | `2.1.59` | docs/23-fleet-engineering.md | MCP OAuth refresh races under concurrency are a recurring family, not one fixed bug — and the KB is silent |
| 240 | `KB_GAP` | medium | `2.1.117` | docs/24-harness-patterns.md | Doc 24 frames the 'advisor loop' as purely an external community pattern; Claude Code now ships one natively |
| 241 | `KB_GAP` | medium | `2.1.97` | docs/25-long-running-agents.md | MCP HTTP/SSE reconnects leaked ~50MB/hr — long-run reliability |
| 242 | `KB_GAP` | medium | `2.1.126 (recurring through 2.1.139/2.1.222/2.1.232)` | docs/25-long-running-agents.md | Stream idle timeout has been a recurring false-abort bug across at least 4 releases spanning this whole slice and beyond — exactly the failure class d |
| 243 | `KB_GAP` | medium | `2.1.140` | docs/28-routines.md | /loop no longer polls background tasks that already notify |
| 244 | `KB_GAP` | medium | `0.2.108` | docs/29-background-agents.md | Bash timeout behavior changed from kill to auto-background; Ctrl-B backgrounding never mentioned |
| 245 | `KB_GAP` | medium | `2.1.0` | docs/29-background-agents.md | 30K-char background-output truncation limit undocumented |
| 246 | `KB_GAP` | medium | `2.1.47` | docs/29-background-agents.md | Kill-all-background-agents keybinding is now Ctrl+X Ctrl+K, not Ctrl+F — and the KB says neither |
| 247 | `KB_GAP` | medium | `2.1.72` | docs/29-background-agents.md | /clear preserving background tasks is a real, current, undocumented behavior a loop author needs |
| 248 | `KB_GAP` | medium | `2.1.83` | docs/29-background-agents.md | Deprecation of a subagent output-reading tool is undocumented |
| 249 | `KB_GAP` | medium | `2.1.141` | docs/29-background-agents.md | /tui used to silently drop running background work |
| 250 | `KB_GAP` | medium | `2.1.153` | docs/29-background-agents.md | EnterWorktree/background-session interaction bug, absent from docs/29 |
| 251 | `KB_GAP` | medium | `2.1.153` | docs/29-background-agents.md | A background session's own temp files could stall it on an unattended permission prompt |
| 252 | `KB_GAP` | medium | `2.1.147` | docs/29-background-agents.md | Pinning has a multi-version bug tail (v2.1.147→v2.1.257) entirely absent from docs/29 |
| 253 | `KB_GAP` | medium | `2.1.157` | docs/29-background-agents.md | The IDE Stop button used to not actually stop a running background subagent |
| 254 | `KB_GAP` | medium | `2.1.157` | docs/29-background-agents.md | Doc 29 documents --model/--effort for --bg dispatch but not the settings.json `agent` field or its --agent override |
| 255 | `KB_GAP` | medium | `2.1.191` | docs/29-background-agents.md | `claude stop` reliability history missing near its own documentation |
| 256 | `KB_GAP` | medium | `2.1.193` | docs/29-background-agents.md | Orchestrator-continues-after-launch behavior change absent from the background-agents doc |
| 257 | `KB_GAP` | medium | `2.1.140` | docs/30-goal-engineering.md | /goal used to hang silently under hook lockdown settings |
| 258 | `KB_GAP` | medium | `2.1.143` | docs/30-goal-engineering.md | /goal's completion evaluator used to race running work |
| 259 | `KB_GAP` | medium | `v2.1.89` | docs/33-agent-security-hardening.md | Permission path-rules didn't resolve symlinks before v2.1.89 — undocumented |
| 260 | `KB_GAP` | medium | `2.1.98` | docs/33-agent-security-hardening.md | CLAUDE_CODE_SUBPROCESS_ENV_SCRUB grew a second job; SCRIPT_CAPS is new and undocumented |
| 261 | `KB_GAP` | medium | `2.1.153` | docs/33-agent-security-hardening.md | A concrete failure of the Broker credential pattern docs/33 describes abstractly |
| 262 | `KB_GAP` | medium | `2.1.169` | docs/33-agent-security-hardening.md | A trust-confirmation bypass via project settings is undocumented |
| 263 | `KB_GAP` | medium | `2.1.186` | docs/33-agent-security-hardening.md | `!` bash-mode auto-respond default change is undocumented |
| 264 | `KB_GAP` | medium | `2.1.113` | docs/34-loop-patterns.md | Esc-cancels-wakeup landed in two parts; doc 34 cites neither |
| 265 | `KB_GAP` | medium | `2.1.172` | docs/34-loop-patterns.md | `/loop`'s remote/cloud-session limitation is undocumented |
| 266 | `KB_GAP` | medium | `2.1.71` | docs/35-choosing-your-mode.md | Session-scoped CronCreate/CronList/CronDelete tools are a distinct, undocumented primitive |
| 267 | `KB_GAP` | medium | `2.1.147` | docs/36-development-workflow.md | docs/36 documents /code-review's later history but skips its origin as a rename of /simplify |
| 268 | `KB_GAP` | medium | `2.0.73` | docs/37-session-architecture.md | Session forking primitive (--fork-session / --session-id) — missing from Session Architecture |
| 269 | `KB_GAP` | medium | `v2.1.32` | docs/37-session-architecture.md | Resume-then-keep-the-same-agent default behavior is undocumented |
| 270 | `KB_GAP` | medium | `2.1.162` | docs/37-session-architecture.md | SendMessage could silently stop working under a deep TMPDIR, and failed agents-view replies used to be lost outright |
| 271 | `KB_GAP` | medium | `v2.1.199` | docs/37-session-architecture.md | SendMessage name-reuse misrouting fix undocumented in the cross-session messaging section |
| 272 | `KB_GAP` | medium | `v2.1.261` | docs/37-session-architecture.md | Cross-machine SendMessage previously reported false delivery to an offline session |
| 273 | `KB_GAP` | medium | `2.1.147` | docs/38-agent-teams.md | docs/38's SUBAGENT_MODEL precedence history omits the pre-v2.1.147 teammate bug |
| 274 | `KB_GAP` | medium | `2.1.183` | docs/38-agent-teams.md | Background-task lifecycle bug for agent-teams teammates is undocumented |
| 275 | `KB_GAP` | medium | `v2.1.261` | docs/38-agent-teams.md | Agent-teams prompt-cache-break bug missing from the cost comparison |
| 276 | `KB_GAP` | medium | `2.1.161` | docs/39-dynamic-workflows.md | Doc 39 documents the workflow script API in depth but never mentions the `isolation` parameter to `agent()` at all |
| 277 | `KB_GAP` | low | `2.1.76` | docs/03-building-blocks.md | worktree.sparsePaths — monorepo scaling setting, undocumented |
| 278 | `KB_GAP` | low | `2.1.157` | docs/03-building-blocks.md | Doc 3 documents Exit + cleanup for worktrees but not direct mid-session switching between them |
| 279 | `KB_GAP` | low | `0.2.107` | docs/05-claude-md.md | Import syntax is documented correctly but carries no version marker (Part II promise) |
| 280 | `KB_GAP` | low | `2.1.72` | docs/05-claude-md.md | HTML-comment-stripping section is correct but carries no version marker |
| 281 | `KB_GAP` | low | `v2.1.89` | docs/05-claude-md.md | Nested/path-scoped CLAUDE.md re-injection cost bug — minor gap next to the KB's lazy-loading description |
| 282 | `KB_GAP` | low | `2.1.0` | docs/06-skills.md | `agent:` skill frontmatter field undocumented |
| 283 | `KB_GAP` | low | `2.1.0` | docs/06-skills.md | `user-invocable` frontmatter field undocumented |
| 284 | `KB_GAP` | low | `v2.1.45` | docs/06-skills.md | Second `--add-dir` config-discovery extension is also undocumented |
| 285 | `KB_GAP` | low | `2.1.120 / 2.1.133` | docs/06-skills.md | SKILL.md content-substitution of `${CLAUDE_EFFORT}` is a distinct feature from the hooks env var docs/12 already documents, and is entirely unmentione |
| 286 | `KB_GAP` | low | `2.1.152` | docs/06-skills.md | Skill hot-reload command and its SessionStart-hook equivalent, absent from docs/06 |
| 287 | `KB_GAP` | low | `v2.1.261` | docs/06-skills.md | New skill-auditing command undocumented in the skills doc |
| 288 | `KB_GAP` | low | `2.1.47` | docs/07-subagents.md | SubagentStop hook payload description omits last_assistant_message |
| 289 | `KB_GAP` | low | `2.1.92` | docs/07-subagents.md | tmux-based subagent spawning could permanently fail in long sessions |
| 290 | `KB_GAP` | low | `2.1.98` | docs/07-subagents.md | Failed background subagents used to lose their partial progress |
| 291 | `KB_GAP` | low | `2.1.139` | docs/07-subagents.md | No doc in the whole KB covers Claude Code's own OpenTelemetry export |
| 292 | `KB_GAP` | low | `2.1.140` | docs/07-subagents.md | Subagent name matching is now forgiving of case/separators |
| 293 | `KB_GAP` | low | `1.0.97` | docs/08-permissions.md | /doctor's permission-rule diagnostics are undocumented in doc08 |
| 294 | `KB_GAP` | low | `v2.1.20` | docs/08-permissions.md | Permission-rule syntax section doesn't cover the Bash(*) / Bash equivalence |
| 295 | `KB_GAP` | low | `v2.1.31` | docs/08-permissions.md | A false-failure sandbox bug (successful command reported as failed) is undocumented |
| 296 | `KB_GAP` | low | `2.1.51` | docs/08-permissions.md | Managed-settings delivery via plist/Registry, and its fail-closed hardening, is undocumented |
| 297 | `KB_GAP` | low | `2.1.92` | docs/08-permissions.md | forceRemoteSettingsRefresh — fail-closed managed-settings gate, undocumented |
| 298 | `KB_GAP` | low | `2.1.97` | docs/08-permissions.md | additionalDirectories / --add-dir mid-session reliability, undocumented |
| 299 | `KB_GAP` | low | `2.1.111` | docs/08-permissions.md | docs/08's allowlist section could point at the now-built-in transcript-based allowlist generator |
| 300 | `KB_GAP` | low | `2.1.149` | docs/08-permissions.md | New enterprise MCP-connector managed setting, absent from docs/08 |
| 301 | `KB_GAP` | low | `0.2.100` | docs/09-headless-mode.md | Undocumented dependency: --continue/--resume can silently be unavailable without a db backend |
| 302 | `KB_GAP` | low | `2.0.35` | docs/09-headless-mode.md | Undocumented SDK-mode idle-exit env var — verification incomplete |
| 303 | `KB_GAP` | low | `v2.1.27` | docs/09-headless-mode.md | The write-side of PR/session linkage (companion to `--from-pr`) is also undocumented |
| 304 | `KB_GAP` | low | `2.1.152` | docs/09-headless-mode.md | docs/09 shows --fallback-model as a bare example with no version-stamped behavior explanation |
| 305 | `KB_GAP` | low | `v2.1.196` | docs/09-headless-mode.md | Streaming idle-watchdog default-on behavior undocumented, but the exact numeric default is entangled across many versions — flag for verification, don |
| 306 | `KB_GAP` | low | `v2.1.6` | docs/11-cost-control.md | Cost-control doc never states the rate-limit-warning threshold |
| 307 | `KB_GAP` | low | `v2.1.45` | docs/11-cost-control.md | Cost-control doc's SDK/budget coverage doesn't mention programmatic rate-limit telemetry |
| 308 | `KB_GAP` | low | `2.1.0` | docs/12-hooks.md | Scope hierarchy names 'skill' hooks but never slash-command frontmatter hooks |
| 309 | `KB_GAP` | low | `2.1.50` | docs/12-hooks.md | Hooks doc's lifecycle-events table omits WorktreeCreate/WorktreeRemove entirely |
| 310 | `KB_GAP` | low | `2.1.49` | docs/12-hooks.md | ConfigChange hook event is missing from the hooks lifecycle table |
| 311 | `KB_GAP` | low | `v2.1.69` | docs/12-hooks.md | Plugin lifecycle hooks silently stopped firing after any /plugin op (fixed v2.1.69) — narrow, now-fixed edge case |
| 312 | `KB_GAP` | low | `v2.1.69` | docs/12-hooks.md | Two plugins sharing a command template silently dropped one plugin's hook (fixed v2.1.69) — folded into the note above |
| 313 | `KB_GAP` | low | `2.1.76` | docs/12-hooks.md | Same elicitation gap as above — folded into one fix |
| 314 | `KB_GAP` | low | `v2.1.84` | docs/12-hooks.md | WorktreeCreate hook (already used for non-git VCS in doc03) is absent from doc12's own hook catalog, including this HTTP-output detail |
| 315 | `KB_GAP` | low | `2.1.121` | docs/12-hooks.md | updatedToolOutput's scope expansion from MCP-only to all tools is presented in docs/12 as though it always applied to all tools |
| 316 | `KB_GAP` | low | `2.1.133` | docs/12-hooks.md | CLAUDE_EFFORT is documented as a hook env var only, not as also readable from Bash tool commands |
| 317 | `KB_GAP` | low | `2.1.50` | docs/13-context-management.md | CLAUDE_CODE_DISABLE_1M_CONTEXT env var is undocumented and its behavior was refined later |
| 318 | `KB_GAP` | low | `v2.1.63` | docs/13-context-management.md | /clear had a stale-skill-cache gap (fixed v2.1.63) |
| 319 | `KB_GAP` | low | `v2.1.69` | docs/13-context-management.md | /clear left residual session caches (fixed v2.1.69) |
| 320 | `KB_GAP` | low | `2.1.76` | docs/13-context-management.md | Same ToolSearch gap as above — folded into one fix |
| 321 | `KB_GAP` | low | `v2.1.84` | docs/13-context-management.md | MCP tool/server-description context cap absent from context-cost docs |
| 322 | `KB_GAP` | low | `2.1.136` | docs/14-human-in-the-loop.md | AskUserQuestion's programmatic-answer array bug is undocumented |
| 323 | `KB_GAP` | low | `2.1.72` | docs/15-explore-plan-implement.md | /plan's immediate-start nuance is implicit but unstamped in the KB |
| 324 | `KB_GAP` | low | `2.1.108` | docs/16-memory-patterns.md | docs/16 documents auto memory in depth but is silent on the separate, still-current session-recap feature |
| 325 | `KB_GAP` | low | `2.0.5` | docs/19-mcp-security.md | Companion bullet to the 1.0.110 OAuth-refresh gap above — same underlying KB silence |
| 326 | `KB_GAP` | low | `2.1.142` | docs/19-mcp-security.md | MCP_TOOL_TIMEOUT previously had no effect on remote MCP calls |
| 327 | `KB_GAP` | low | `2.1.0` | docs/28-routines.md | Cloud-session teleport/remote-env resumption undocumented |
| 328 | `KB_GAP` | low | `2.1.0` | docs/29-background-agents.md | Ctrl+B shortcut and CLAUDE_CODE_DISABLE_BACKGROUND_TASKS missing from background-agents doc |
| 329 | `KB_GAP` | low | `v2.1.4` | docs/29-background-agents.md | No documented way to fully disable background tasking |
| 330 | `KB_GAP` | low | `2.1.143` | docs/29-background-agents.md | bgIsolation setting is documented but missing its version stamp |
| 331 | `KB_GAP` | low | `2.1.144` | docs/29-background-agents.md | /resume-for-background-sessions is documented but missing its version stamp |
| 332 | `KB_GAP` | low | `2.1.153` | docs/29-background-agents.md | In-flight response could be dropped when backgrounding mid-response, before v2.1.153 |
| 333 | `KB_GAP` | low | `2.1.0` | docs/33-agent-security-hardening.md | Debug-log credential leak is a separate surface from the credential-broker isolation docs/33 already covers |
| 334 | `KB_GAP` | low | `2.1.72` | docs/35-choosing-your-mode.md | Cron kill-switch env var — same gap as CronCreate, folded into one fix |
| 335 | `KB_GAP` | low | `v2.1.70` | docs/37-session-architecture.md | Remote Control's polling latency is undocumented — a loop author monitoring via phone/browser should expect up to ~10min staleness |

---

**Coverage note.** These come from reading **3,774 of 3,774** previously-unswept bullets
across 24/24 chunks with zero count mismatches — the one claim this sweep makes without
hedging. What is *not* claimed: 245 of these 335 reached per-doc triage with no adversarial
refuter, because a cap of 90 was applied. The triage and the Opus adjudicator saw them all;
one adversarial refuter did not.
