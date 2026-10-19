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
| Permission prompts during run | Auto-denied | Auto-denied | None — full autonomous cloud session, no approval prompts of any kind |
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

Returns immediately with `{"type": "routine_fire", "claude_code_session_id": "...", "claude_code_session_url": "..."}` — the run
continues asynchronously in the cloud.

### GitHub
Trigger on repository events:
- **PR events**: opened / closed / assigned / labeled / synchronized, or any other PR update (docs describe the category as "opened, closed, assigned, labeled, synchronized, or otherwise updated" rather than an exhaustive action list; use the **Is draft** filter to scope specifically to ready-for-review PRs)
- **Release events**: created / published / edited / deleted

Pair with path filters to scope which changes invoke the Routine.

### Around the trigger: follow-ups and run visibility

Anthropic's [field guide to cloud sessions](https://claude.dev/blog/claude-code-in-the-cloud/) (Addy
Osmani, 6 Oct 2026) describes routines (research preview) as a prompt, repositories, connectors and an
environment, each run being a cloud session started by a schedule (hourly at most), an HTTP call to the
routine's own endpoint, or a GitHub event. Three adjacent pieces matter to a loop designer:

- **Queue a follow-up into a running session** from any logged-in machine, a CI job included:
  `claude -p "<follow-up>" --cloud <session-id>`.
- **`/autofix-pr`** (or the CI bar's Auto-fix toggle) lets a cloud session watch a pull request and push
  fixes for failing checks and review comments; the guide notes Claude is not notified of merge conflicts
  with the base branch, so ask it to rebase.
- **Separate caps.** Routines have their own hourly caps, and "projects" can start up to 200 new threads
  a day (the guide's figures at 6 Oct 2026); parallel sessions draw on plan limits in parallel.

Run visibility improved in the cloud UI: v2.1.286 made a routine's page read "Due" with the scheduled time
when a run is late and has not started, and v2.1.302 (16 Oct 2026) added a banner saying why the last run
did not start, for example the organization reaching its limit on concurrent cloud sessions
([changelog](https://code.claude.com/docs/en/changelog)). Both address the same failure: a routine that
silently does not run looks identical to one with nothing to do.

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

**A nightly loop that audits its own routine.** The [`ruvnet/dream-machine`](https://github.com/ruvnet/dream-machine)
[ADR-0011](https://github.com/ruvnet/dream-machine/blob/main/docs/adrs/ADR-0011-dream-cycle-v2-deep-research-and-routine-self-review.md)
(status **Proposed** in the document; the ADR landed on `main` on 18 Oct 2026; the tracker saw it on 19 Oct) describes a
nightly cloud-scheduled loop with three guards worth borrowing. (1) **Mode selection with backpressure:**
it picks CONSOLIDATE, RESEARCH-ONLY, IMPLEMENT or RESEARCH from the backlog, and switches mode when the
review queue exceeds a limit, so it stops producing PRs no one can review. (2) **Measuring its own
bottleneck:** the ADR reports ledger survivorship bias, a 0.969 merge rate on `main` versus 0.608 once 19
open draft PRs were counted (the ADR's own measurements, not independently checked). (3) **A
routine that reviews itself under a protected constitution:** every N days it scores its own routine
against frozen HIT/MISS forecasts, and a "routine constitution" the loop may not edit bounds what it can
change. The candidate session never merges; a PR goes ready only on ACCEPT, green checks and a clear
critic. Compare the maintenance fleet below, where the operator asks Claude to tune the routines: here the
review is scheduled, and the protected file is what keeps it from rewriting its own gate. See
[Learned Orchestration](22-learned-orchestration.md). Its consolidation mode is the same idea as the
"Dreaming" pass in [Memory Patterns, Pattern K](16-memory-patterns.md#pattern-k-git-backed-memory-with-a-consolidation-dreaming-pass).

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

### Anthropic's reference automation: six rules against silent failure

[*Building effective agent automations*](https://claude.dev/blog/building-effective-agent-automations/)
(Lance Martin and CJ Avilla, 8 Oct 2026) walks through a reference scheduled automation on Claude Managed
Agents (beta, not Routines, but the same trigger-and-run shape): it reads Slack channels and GitHub pull
requests on a cron schedule, tracks what changed since the last run, and posts a daily brief to Slack. Each
run starts in a fresh sandbox; state lives in memory stores the platform mounts into every run. The post
closes on six rules, each aimed at a failure that looks like success:

| Rule | The failure it prevents (per the post) |
|---|---|
| **Read each source from a bookmark, not a fixed window** | A late run leaves a gap and an early run repeats items. The agent writes the timestamp of the newest item read per source and the next run starts there |
| **Report a failed read as unreadable, never as a quiet day** | If an MCP server is down or a token expired, the run still starts without that server's tools and the agent reports "nothing new". On a failed source it keeps that bookmark, writes from the other sources, and ends the brief with a line naming what it could not read |
| **Re-check every item right before posting** | The world moves between read and post. Resolved: drop it; changed: fix the line; cannot confirm: drop it and list it in the run record. The post's stance is to assert an item's status or drop it, never hedge |
| **Count a post as sent only when the platform confirms** | Look for today's edition in the channel first; treat the post as sent only if Slack returns ok and a message timestamp; update ledger and bookmarks only after. An unclear result is marked "maybe posted" and nothing else changes |
| **Re-read preferences every run, from a store the agent cannot edit** | A copy baked into the prompt keeps applying rules you changed. If the agent cannot read the file, it stops and says so instead of running on defaults |
| **Read-only wherever it only reads; cap spend per run** | Start the cap at three to five times a normal run's cost. A run that hits it pauses rather than fails, so a cap set too low looks like a brief that went quiet |

Rules two, four and five are this KB's defining defect class, a default that means success, written as a
vendor recipe; see [Failure Patterns](17-failure-patterns.md) and [Verification](04-verification.md). The
post also names a prompt-injection limit: the agent reads text other people wrote, so the GitHub token and
the preferences store are read-only and the sandbox reaches only allowlisted hosts. A planted instruction
can still change what the brief says, including via the notes the agent keeps between runs, but cannot
write to GitHub or edit the rules.

**Trace what runs unattended.** Anthropic's [OpenTelemetry announcement](https://claude.com/resources/articles/agent-observability-on-the-claude-platform)
(14 Oct 2026, public beta) sends traces from Claude Managed Agents, the Messages API and Claude SDKs to any
OTLP-accepting tool (Managed Agents and the Messages API need a destination added in the Claude Console;
SDKs export automatically). The post's framing for loop designers: review an agent's traces of model calls,
tool use and MCP calls, then widen its access as it proves reliable. That is the "how do you know it is
done" question answered with a record you can read after the run, not the run's own report.

## Constraints to design around

- **No permission prompts during run** — Routines run as full autonomous cloud sessions with no permission-mode picker and no approval prompts of any kind; design the Routine's prompt, repositories, environment, and connectors so nothing needs mid-run approval, since none is possible once it starts
- **Branch policy** — Claude always pushes to `claude/`-prefixed branches, which are always
  accepted. A push to any other branch is checked automatically and rejected if the branch is
  protected on GitHub, someone else has an open PR from it, or it carries commits authored by
  someone other than you (mechanism as documented 2026-09-07; this is an account-side policy,
  not a CLI-version-gated one)
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

## For comparison: the same primitive outside Claude Code

Two other harnesses ship the same "persistent, laptop-independent, scheduled agent" shape:

- **NanoClaw** — a lightweight OpenClaw alternative built on Anthropic's own Claude Agent
  SDK, running scheduled/recurring agent routines in isolated Docker containers with
  per-agent memory. Closest direct match to a Routine's trigger/persistence model, but
  self-hosted rather than run on Anthropic's cloud infrastructure — the trade-off is local
  filesystem and container access (which Routines explicitly do not offer) against
  managing your own uptime and container isolation.
  ([nanocoai/nanoclaw](https://github.com/nanocoai/nanoclaw), undated.)
- **Durable scheduled automations in a mainstream desktop orchestrator.** A 12k★
  worktree-per-worker product added RFC 5545 recurrence plus cron scheduling with recovery
  for failed or expired spawns — a durable loop spawning agent sessions on a schedule with
  no human in it, shipped inside a product this KB already tracks for its worktree-per-task
  pattern (see [Fan-Out](10-fan-out.md)). Unlike a Routine, scheduling here is a feature of
  a desktop application managing local worktrees, not a cloud-hosted primitive — the
  constraints in this doc (no local filesystem, no Chrome) do not apply to it.
  ([Untrivial-ai/agent-orchestrator #4459](https://github.com/Untrivial-ai/agent-orchestrator/commit/078782d), Sep 2026.)

### Always-on agents from other vendors (Sep-Oct 2026)

The "agent that keeps working with the laptop closed" shape is now a product category. What each source
says, and how much of it is first-party:

- **OpenAI Dots.** [The New Stack](https://thenewstack.io/openai-dots-gpt6-agents/) (29 Sep 2026)
  describes persistent GPT-6 Astra agents on their own cloud computers that keep working unprompted,
  split read-only "proactive research" from acting, and gate actions through an auto-review step and
  Custom Rules; its worked example turns customer feedback into pull requests.
  [The Rundown AI](https://therundownai.beehiiv.com/p/openai-connects-the-dots-on-always-on-agents)
  reports they can be put on a schedule (a weekday brief, managed under "Scheduled"), and
  [Ben's Bites](https://www.bensbites.com/p/openai-devday-2026) describes a Dot as a never-ending
  proactive chat that orchestrates several Codex or ChatGPT Work chats and reports status back. OpenAI's
  own announcement ([Introducing dots](https://openai.com/index/introducing-dots)) returned HTTP 403 to
  the tracker, so none of this was checked against first-party text.
- **Two data points for stop conditions and cost.** Per
  [The New Stack](https://thenewstack.io/openai-dots-agent-permissions/) (30 Sep), citing the GPT-6 Astra
  system card appendix, boundary-problem flags rose from 8.6% to 19.7% when chained tasks doubled from five
  to ten, and a simulated hourly fix-tests-and-merge helper was granted broader permissions than the user
  asked for (secondary reporting of a vendor document). Per
  [The New Stack](https://thenewstack.io/openai-dots-codex-usage/) (1 Oct), a Dot's own work is included in
  the plan during the launch month but tasks it delegates to Codex are metered, so unreviewed routing
  decisions change cost. The lesson for [the Loop Contract](27-loop-contract.md) is the same either way:
  bound the chain length and the permission scope in the contract, not in the agent's judgement.
- **Event triggers via MCP.** [OpenAI's MCP Events doc](https://developers.openai.com/plugins/build/mcp-events)
  lets ChatGPT subscribe to MCP server events (for example `message.created`, `comment.created`) and run
  user-defined instructions when one arrives, such as opening draft PRs with fixes and tests from bug
  reports. Per the doc as read by the tracker: webhook delivery only, it requires MCP 2.0 (2026-07-28), and
  the draft spec's gap and terminated notifications are unsupported. This is a TRIGGER whose source is any
  MCP server rather than GitHub or an HTTP call to the routine.
- **Google.** [Gemini at Work 2026](https://cloud.google.com/blog/products/ai-machine-learning/welcome-to-gemini-at-work-2026)
  (8 Oct) is summarised by AI Breakfast as a cloud agent that runs for hours or days, responds to schedules
  and events, and spawns temporary sub-agents with their own identities under Agent Sandbox and Agent
  Gateway least-privilege controls; the tracker did not re-read the post.
- **Anthropic's own consumer surface.** The cloud-run Cowork keeps working when the laptop closes; see
  [Background Agents](29-background-agents.md#cloudmobile-background-execution).

## Related

- [The Loop Contract](27-loop-contract.md) — define TRIGGER/SCOPE/STOP before creating a Routine
- [Headless & Non-Interactive Mode](09-headless-mode.md) — local headless alternative when cloud is not needed
- [Background Agents](29-background-agents.md) — detached sessions within a single machine session
- [Hooks](12-hooks.md) — hook events available inside a Routine's cloud session
