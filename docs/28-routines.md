# Routines — Cloud-Hosted Loop Execution

Routines are Claude Code's cloud execution primitive: a saved loop configuration
(prompt + repos + connectors) that runs on Anthropic infrastructure. Your laptop can
be closed — the loop keeps running until its stopping condition is met.

## Routines vs. local headless runs

| | Headless (`claude -p`) | macOS LaunchAgent | Routines |
|---|---|---|---|
| Runs on | Your machine or CI | Your machine | Anthropic cloud |
| Survives laptop close | No | No | Yes |
| Trigger types | Manual / cron / CI event | Schedule (launchd) | Schedule / API / GitHub event |
| Chrome browser automation | Yes (if Chrome open) | Yes (if Chrome open) | No — no local Chrome |
| Local filesystem / credentials | Yes | Yes | No — git + connectors only |
| Permission prompts during run | Auto-denied | Auto-denied | Routed to your main session |
| Setup | Shell script / CI YAML | plist + `launchctl load` | `/schedule` CLI command |

**Rule of thumb:** use Routines for laptop-independent runs where all tools are git/API-based.
Use a LaunchAgent when the loop needs Chrome, local credentials, or local filesystem access
that can't be served through an MCP connector. See [Headless Mode](09-headless-mode.md)
for LaunchAgent setup details.

## Three trigger types

### Schedule
Cron-style scheduling (minimum interval: 1 hour) or one-off timestamps:

```bash
# Set up a nightly schedule inside any Claude Code session
/schedule  # interactive setup → choose "Schedule" → enter cron expression
```

```
/schedule list          # view all active Routines and next run times
/schedule update        # edit an existing Routine
/schedule run           # trigger an immediate manual run
```

### API
Fire a Routine via HTTP POST — connect to webhooks, alerts, CI pipelines:

```bash
# Verify the exact endpoint, path, and beta header in the official Routines docs
# before using in production — this is an experimental API.
POST /v1/claude_code/routines/<routine-id>/fire
Authorization: Bearer <your-api-key>
anthropic-beta: experimental-cc-routine-2026-04-01

{ "text": "optional context injected into this run" }
```

Returns immediately with `{"session_id": "...", "session_url": "..."}` — the run
continues asynchronously in the cloud.

### GitHub
Trigger on repository events:
- **PR events**: opened / closed / labeled / synchronize / ready_for_review
- **Release events**: published / created / edited

Pair with path filters to scope which changes invoke the Routine.

## Loop engineering patterns

**Nightly quality gate:**
```
Trigger: schedule 0 2 * * *
Prompt: Run all tests. If any fail, open a GitHub issue listing the failures 
        with file paths and error messages.
STOP: issue opened or all tests pass
```

**PR review on every open:**
```
Trigger: GitHub PR opened
Prompt: Review the diff against the patterns in CLAUDE.md. Post a PR comment 
        with findings — blocking issues first, suggestions second.
STOP: PR comment posted
```

**Alert-driven investigation:**
```
Trigger: API (from PagerDuty webhook or monitoring alert)
Context: { "text": "OOM error on payment-service pod at 03:12 UTC" }
Prompt: Investigate the error described in the context. Check recent commits, 
        logs, and open a GitHub issue with findings and a reproduction hypothesis.
STOP: issue opened
```

## First-party production examples

### Marketing — a weekly unattended send

An Anthropic field marketer runs a weekly Routine that pulls account and event data via
BigQuery (MCP connector) every Monday morning and sends each account executive a
personalized Slack DM with three priority actions — field events, webinar registrants,
and follow-ups relevant to their own accounts. The Routine is unattended by design: *"I
still read what goes out, though the system no longer waits for my approval. When I went
on holiday a few weeks ago, the Monday send went off on its own, without a hitch."*
Reported business impact: doubled registrations for an executive dinner in a week,
attributed to the right reps seeing the right event at the right time. A concrete instance
of this doc's constraint that Routines have no local filesystem/credentials — everything
here goes through the BigQuery connector, and the output channel (Slack) requires no local
Chrome session either.
([Anthropic, "How an Anthropic field marketer uses Claude Code..."](https://claude.com/blog/how-an-anthropic-field-marketer-uses-claude-code-to-send-weekly-personalized-updates-to-every-sales-rep), Aug 2026.)

### Engineering — a maintenance fleet on Anthropic's own apps

Boris Cherny, who created Claude Code, ran a **fleet of daily Routines maintaining Anthropic's own
applications** — the clearest published example of Routines used as continuous maintenance rather
than as reporting, and one of the few sources anywhere that publishes a **merge rate**.

> A weird experiment I've been trying the last few weeks is having Claude take over day-to-day
> maintenance of our apps. […] we have a Slack channel called proj-claude-maintains-apps. In it,
> Claude Tag runs a bunch of daily routines across iOS, Android, Desktop, web, CLI, and Agent SDK:
>
> - Crash fuzzer: open the app in a simulator and tap around to find ways to crash it, then root
>   cause and fix the crashes
> - Dup unifier: scans the codebase for similar-yet-slightly-divergent abstractions, and puts up
>   PRs to unify them
> - Dead-code remover: removes statically unreachable code, and adds logging to suspected dead code
>   to check if it's really dead and if so, remove it the next day
> - Abstraction police: fixes leaky abstractions
> - a bunch more..
>
> Results have been surprisingly positive. Over the last few weeks, these routines have opened 388
> PRs across our repos, 180 of which we merged after Claude Code Review + human review. […] Claude
> generally gets these PRs right on the first shot, and if it doesn't, we ask Claude to tune its
> routines so it's better the next day. Sometimes it takes a few days of tuning.

— [Boris Cherny (@bcherny), 13 Aug 2026](https://x.com/bcherny/status/2088014489438621990).

Four design properties worth lifting out, because each is a pattern this KB documents abstractly
and rarely gets to show running in production:

| Property | What it looks like here |
|---|---|
| **Narrow, named routines — not one general "maintain the app" loop** | Each routine has a single SCOPE (crashes, duplicate abstractions, dead code, leaky abstractions). The fleet is composed of specialists, which is what makes a per-routine merge rate legible at all |
| **A merge rate, published** | **388 PRs opened, 180 merged** — a **46%** acceptance rate, gated on *"Claude Code Review + human review"*. The STOP condition is a human merge, not the agent's own verdict |
| **A two-day verifier** | The dead-code remover cannot decide on day 1. It **instruments** (adds logging), waits, and **decides on day 2** with evidence it did not have before. A loop whose verifier needs a night to produce its evidence is a legitimate shape — see [Loop Patterns](34-loop-patterns.md) |
| **The routine itself is the thing being tuned** | *"if it doesn't, we ask Claude to tune its routines so it's better the next day. Sometimes it takes a few days of tuning."* The outer loop edits the inner loop's prompt — [Learned Orchestration](22-learned-orchestration.md) |

The honest reading of 46%: a maintenance fleet at this maturity produces **roughly one mergeable PR
for every two it opens**, and the remainder is reviewer load. That is the number to plan review
capacity against — not a defect, but not free either. It is also why the merge gate is human: at a
46% base rate, an agent self-merging would land a rejected change every other PR.

**Provenance note.** This is a public post from a primary source, quoted verbatim and dated. The
thread promises *"A few of the actual prompts I used below"*; those replies did not render for a
logged-in reader on 20260906 and are **unretrieved, not absent**. No per-routine breakdown of the
388/180 split is published, so the 46% is a fleet-wide figure only.

## Constraints to design around

- **No permission prompts during run** — prompts route to your main session asynchronously;
  design the Routine to not need interruption, or accept that it may pause waiting for you
- **Branch policy** — by default Routines push only to `claude/`-prefixed branches;
  configure if you need direct pushes to feature branches
- **Network allowlist** — Anthropic-managed (package registries, cloud APIs, common dev
  domains); custom internal endpoints require a connector (MCP server)
- **Connectors** — MCP tools must be pre-configured in the Routine; local filesystem
  is not available (everything goes through git + connectors)

**MCP servers configured in Claude Code don't carry over.** As of **v2.1.251**, `/schedule`
says so directly instead of a bare error, verbatim: "Improved `/schedule` to explain that
MCP servers configured in Claude Code can't be attached to cloud routines, instead of a bare
\"No MCP connectors\" message." ([v2.1.251 release
notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.251).) Local MCP config
(`.mcp.json`, `claude mcp add` entries) doesn't travel to the cloud — a Routine that needs an
MCP tool needs a claude.ai-side connector attached in the `/schedule` setup flow, not just a
working local server.

**API-key auth disables Routines outright.** As of **v2.1.139**, Remote Control, `/schedule`, claude.ai MCP connectors, and notification preferences are all disabled when `ANTHROPIC_API_KEY`, `apiKeyHelper`, or `ANTHROPIC_AUTH_TOKEN` is set — even when a claude.ai login also exists, because these credentials take precedence over it. ([v2.1.139 release notes](https://github.com/anthropics/claude-code/releases/tag/v2.1.139).) A CI or headless session authenticated with a Console API key sees `/schedule` itself say *"available with Claude for Enterprise — ask your admin about migrating from API-key access"* rather than let you configure a Routine there. Two ways around it: unset the key for the shell where you run `/schedule`, or skip the CLI and manage Routines directly at [claude.ai/code/routines](https://claude.ai/code/routines) — that surface works regardless of local CLI auth, org policy permitting. ([Routines — Troubleshooting](https://code.claude.com/docs/en/routines), fetched 20260907.)

## Related

- [The Loop Contract](27-loop-contract.md) — define TRIGGER/SCOPE/STOP before creating a Routine
- [Headless & Non-Interactive Mode](09-headless-mode.md) — local headless alternative when cloud is not needed
- [Background Agents](29-background-agents.md) — detached sessions within a single machine session
- [Hooks](12-hooks.md) — hook events available inside a Routine's cloud session
