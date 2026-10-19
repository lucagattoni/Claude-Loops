#!/usr/bin/env bash
# Prove the X-login gate (backlog A19) fires when Chrome is not logged in to X — and only then.
#
# THREE SUBJECTS, each exercised AS SHIPPED, none pasted into this file:
#   1. scripts/assert-x-login.sh  — the decision, run on fixture artifacts (cases 1-18)
#   2. scripts/run-loop-news.sh   — the wrapper path, RUN END TO END in a scratch repo against a
#                                   stubbed `claude`, `script` and `osascript` (cases W0-W8). This is
#                                   the part that proves "the wrapper surfaces it": exit 8, Stage B
#                                   never started, nothing on origin, the artifact kept and then
#                                   resumed once the login is fixed.
#   3. the preflight snippet in .claude/skills/fetch-loop-news/SKILL.md — extracted from the prose
#      and run under node against stubbed DOMs (cases J1-J6), so the classifier a model will paste
#      into Chrome is the one tested, not a re-typed copy.
# Then MUTANTS (M1-M4 break the wrapper, A1-A3 the decision script): each is broken on purpose and the cases must notice. A harness
# that cannot fail proves nothing — scripts/verify-digest-guard.sh's header records two earlier
# harnesses that leaked state and called a broken run healthy.
#
# WHAT THIS DOES NOT PROVE. That X really renders the markers the snippet reads: that was checked by
# hand against a live logged-in x.com/home on 2026-10-19 and the logged-out markers were NOT checked
# live (they only pick a label — every non-"logged-in" state blocks). And that a model following
# SKILL.md Phase 1 step 4 actually runs the snippet: that is prose, and the wrapper's defence is that
# a missing or malformed `x_login` fails the gate (case 4) rather than passing it.
#
# The stubs replace `claude` (so no model, no network), `script` (BSD syntax — util-linux differs,
# and the PTY is not the property under test) and `osascript` (so no desktop popups).
#
# Usage:  bash scripts/verify-x-login-guard.sh        (exit 0 = the gate behaves correctly)
#         Needs git, python3 and node. Takes a minute or so: each W case is a real wrapper run.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSERT="$HERE/assert-x-login.sh"
WRAPPER="$HERE/run-loop-news.sh"
PUBLISHED="$HERE/assert-published.sh"
SKILL="$HERE/../.claude/skills/fetch-loop-news/SKILL.md"
SCHED="$HERE/SCHEDULING.md"
for f in "$ASSERT" "$WRAPPER" "$PUBLISHED" "$SKILL" "$SCHED"; do
  [[ -f "$f" ]] || { echo "missing: $f" >&2; exit 2; }
done
for t in git python3; do
  command -v "$t" >/dev/null || { echo "missing tool: $t" >&2; exit 2; }
done

TMP="$(mktemp -d "${TMPDIR:-/tmp}/x-login-guard-XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
FAILURES=0
pass() { printf '  ok    %-62s %s\n' "$1" "${2:-}"; }
fail() { printf '  FAIL  %-62s %s\n' "$1" "${2:-}"; FAILURES=$((FAILURES + 1)); }

# ═══ 1. assert-x-login.sh on fixture artifacts ══════════════════════════════════════════════════
FIX="$TMP/fix"; mkdir -p "$FIX"

# mkart <out> [path=json ...] [del:path ...] — a today-stamped, logged-in, complete artifact with
# the named fields overridden. `x_login.state=...` reaches into the nested object.
mkart() {
  python3 - "$@" <<'PY'
import datetime, json, sys
out = sys.argv[1]
today = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d")
X = ["x:@a", "x:@b", "x-search:https://x.com/search?q=a", "phase-3:x-general-search"]
d = {"schema": 1, "today": today, "run_time": today + " 10:00 UTC", "last_run_date": "2026-01-01",
     "complete": True,
     "x_login": {"state": "logged-in", "checked": today + " 10:00 UTC",
                 "evidence": '{"path":"/home","switcher":1,"compose":1,"login":0,"state":"logged-in"}',
                 "override": False},
     "expected_keys": ["rss:https://example.invalid/feed"] + X,
     "sources_done": ["rss:https://example.invalid/feed"] + X,
     "findings": [], "coverage": [], "sources_to_consider": [], "source_updates": []}
BLOCKED = [{"source": k, "status": "partial", "passes": [],
            "gap": "blocked: x-login — logged-out: login wall"} for k in X]
for a in sys.argv[2:]:
    if a.startswith("del:"):
        d.pop(a[4:], None)
        continue
    k, v = a.split("=", 1)
    v = BLOCKED if v == "@BLOCKED" else json.loads(v)
    if "." in k:
        a1, a2 = k.split(".", 1)
        d[a1][a2] = v
    else:
        d[k] = v
json.dump(d, open(out, "w"))
PY
}

NOX='["rss:https://example.invalid/feed"]'   # sources_done of a run that swept nothing on X
# Fixture set shared by sections 1 and 2 — each is exactly what a Stage A of that kind would write.
mkart "$FIX/in.json"
mkart "$FIX/out.json"  'x_login.state="logged-out"' "sources_done=$NOX" coverage=@BLOCKED complete=false
mkart "$FIX/unk.json"  'x_login.state="unknown"'    "sources_done=$NOX" coverage=@BLOCKED complete=false
mkart "$FIX/nox.json"  del:x_login
mkart "$FIX/ovr.json"  'x_login.state="logged-out"' 'x_login.override=true' "sources_done=$NOX" coverage=@BLOCKED

# a_case <label> <expect-rc> <substring-of-diagnostic> <file> [allow-value]
# Pins the DIAGNOSTIC as well as the code: several guards share rc 2, so a mutant that removes one is
# masked by the next unless the case says WHICH one fired (the lesson verify-publish-guard.sh paid for).
a_case() {
  local label="$1" erc="$2" esub="$3" f="$4" allow="${5:-}" out rc
  if [[ -n "$allow" ]]; then out="$(LOOP_ALLOW_X_LOGGED_OUT="$allow" bash "$ASSERT" "$f" 2>&1)"; rc=$?
  else                       out="$(env -u LOOP_ALLOW_X_LOGGED_OUT bash "$ASSERT" "$f" 2>&1)"; rc=$?; fi
  if [[ "$rc" -eq "$erc" && "$out" == *"$esub"* ]]; then pass "$label" "rc=$rc"
  else fail "$label" "expected rc=$erc + '$esub', got rc=$rc: ${out:0:110}"; fi
}

echo "assert-x-login.sh — decision on fixture artifacts"
echo
a_case "0 SANITY logged-out must be blocked (rc 1)"                 1 "BLOCKED"            "$FIX/out.json"
a_case "1 logged-in proceeds"                                       0 "logged in"          "$FIX/in.json"
a_case "2 logged-out, no override: blocked"                         1 "BLOCKED"            "$FIX/out.json"
a_case "3 unknown, no override: blocked (cannot tell != logged in)" 1 "state=unknown"      "$FIX/unk.json"
a_case "4 no x_login at all: cannot tell (preflight never ran)"     2 "no \`x_login\`"       "$FIX/nox.json"
mkart "$FIX/t.json" 'x_login.state="yes"'
a_case "5 state outside the enum: cannot tell"                      2 "not logged-in / logged-out / unknown" "$FIX/t.json"
mkart "$FIX/t.json" 'x_login.evidence="  "'
a_case "6 logged-in with empty evidence: cannot tell"               2 "evidence"           "$FIX/t.json"
mkart "$FIX/t.json" 'x_login.checked="2020-01-01 00:00 UTC"'
a_case "7 logged-in stamped with another day: cannot tell"          2 "not stamped with today" "$FIX/t.json"
mkart "$FIX/t.json" coverage=@BLOCKED
a_case "8 logged-in but records say blocked: self-contradiction"    2 "contradicts itself" "$FIX/t.json"
printf 'not json{' > "$FIX/t.json"
a_case "9a unparseable artifact: cannot tell"                       2 "cannot read"        "$FIX/t.json"
a_case "9b absent artifact: cannot tell"                            2 "cannot read"        "$FIX/does-not-exist.json"
a_case "10 override honoured in full: degraded run permitted (rc 3)" 3 "DEGRADED BY OPERATOR OVERRIDE" "$FIX/ovr.json" 1
a_case "11 override set, artifact stopped (complete false): blocked" 1 "is not true"        "$FIX/out.json" 1
mkart "$FIX/t.json" 'x_login.state="logged-out"' "sources_done=$NOX" coverage=@BLOCKED
a_case "12 override set, artifact never recorded it: blocked"       1 "override\` is not true" "$FIX/t.json" 1
mkart "$FIX/t.json" 'x_login.state="logged-out"' 'x_login.override=true' "sources_done=$NOX"
a_case "13 override set, no blocked records (digest would be silent)" 1 "no \`blocked: x-login\` record" "$FIX/t.json" 1
a_case "14 override set, state missing: cannot tell — never excused" 2 "no \`x_login\`"      "$FIX/nox.json" 1
a_case "15 artifact claims override, operator did not: blocked"     1 "BLOCKED"            "$FIX/ovr.json"
a_case "16 override must be the literal 1, not 'true'"               1 "BLOCKED"            "$FIX/ovr.json" true
mkart "$FIX/t.json" 'expected_keys=["rss:https://example.invalid/feed"]'
a_case "17 no X-bound key in expected_keys: cannot tell"            2 "names no X-bound source" "$FIX/t.json"
# A resumed run: @a was swept while logged in, so only the other three keys are unswept and blocked.
mkart "$FIX/t.json" 'x_login.state="logged-out"' 'x_login.override=true' \
  'sources_done=["rss:https://example.invalid/feed","x:@a"]' \
  'coverage=[{"source":"x:@b","status":"partial","passes":[],"gap":"blocked: x-login — x"},{"source":"x-search:https://x.com/search?q=a","status":"partial","passes":[],"gap":"blocked: x-login — x"},{"source":"phase-3:x-general-search","status":"partial","passes":[],"gap":"blocked: x-login — x"}]'
a_case "18a resumed, 3 of 4 X keys unswept and blocked: override ok" 3 "3 of 4 X-bound sources unswept" "$FIX/t.json" 1
mkart "$FIX/t.json" 'x_login.state="logged-out"' 'x_login.override=true' \
  'sources_done=["rss:https://example.invalid/feed","x:@a"]' \
  'coverage=[{"source":"x:@b","status":"partial","passes":[],"gap":"blocked: x-login — x"}]'
a_case "18b resumed, two unswept keys have no record: blocked"       1 "2 unswept X-bound key(s)" "$FIX/t.json" 1

# ═══ 2. the wrapper, run end to end ═════════════════════════════════════════════════════════════
echo
echo "run-loop-news.sh — the real wrapper against stubbed sessions"
echo

W="$TMP/w"
STUBS="$W/stubs"

# world <wrapper-source> [assert-script: keep|drop] — a scratch repo with a bare origin, the three
# scripts the wrapper needs, and the three stubs. Rebuilt per scenario so nothing leaks between them.
world() {
  local wrapper_src="$1" keep_assert="${2:-keep}"
  rm -rf "$W"; mkdir -p "$STUBS" "$W/home" "$W/tmp"
  git init -q --bare "$W/origin.git"
  git clone -q "$W/origin.git" "$W/repo" 2>/dev/null
  git -C "$W/repo" config user.email harness@example.invalid
  git -C "$W/repo" config user.name  "x-login harness"
  git -C "$W/repo" checkout -q -b main
  mkdir -p "$W/repo/scripts"
  printf 'logs/\n.loop-news/\nscripts/run-loop-news.env\n' > "$W/repo/.gitignore"
  cp "$wrapper_src" "$W/repo/scripts/run-loop-news.sh"
  cp "$PUBLISHED"   "$W/repo/scripts/assert-published.sh"
  cp "$ASSERT"      "$W/repo/scripts/assert-x-login.sh"
  git -C "$W/repo" add -A && git -C "$W/repo" commit -q -m "base"
  git -C "$W/repo" push -q origin HEAD:main
  [[ "$keep_assert" == "drop" ]] && rm -f "$W/repo/scripts/assert-x-login.sh"

  cat > "$STUBS/claude" <<'STUB'
#!/usr/bin/env bash
# Stand-in for the claude CLI. Stage A writes the artifact the scenario chose; if the wrapper left
# .loop-news/x-login-override it writes the override-honouring one instead — which is how Stage A
# would behave, and the only way this file ever sees the override. Stage B commits and pushes.
if [[ "${1:-}" == "--version" ]]; then echo "9.9.9 (x-login harness stub)"; exit 0; fi
prompt=""
while [[ $# -gt 0 ]]; do case "$1" in -p) prompt="$2"; shift 2 ;; *) shift ;; esac; done
echo "$prompt" >> "$STUB_CALLS"
case "$prompt" in
  /fetch-loop-news)
    [[ -f .loop-news/findings.json ]] && echo "A-saw-seed" >> "$STUB_CALLS"
    [[ -f .loop-news/x-login-override ]] && echo "A-saw-override-file" >> "$STUB_CALLS"
    mkdir -p .loop-news
    if [[ -f .loop-news/x-login-override && -n "${STUB_ART_OVERRIDE:-}" ]]; then cp "$STUB_ART_OVERRIDE" .loop-news/findings.json
    else cp "$STUB_ART" .loop-news/findings.json; fi ;;
  /integrate-loop-news)
    git commit -q --allow-empty -m "feat: loop news run 2026-01-01 00:00 UTC — stub" && git push -q origin HEAD:main ;;
  *) echo "stub claude: unexpected prompt '$prompt'" >&2; exit 1 ;;
esac
exit 0
STUB
  cat > "$STUBS/script" <<'STUB'
#!/usr/bin/env bash
# BSD `script -q <file> cmd...` semantics: run cmd, copy its output to <file>, keep its exit code.
shift; f="$1"; shift
"$@" 2>&1 | tee "$f"
exit "${PIPESTATUS[0]}"
STUB
  cat > "$STUBS/osascript" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$STUB_POPUPS"
STUB
  chmod +x "$STUBS/claude" "$STUBS/script" "$STUBS/osascript"
}

# run_wrapper <wrapper-path-in-world> [wrapper args...] — sets WRC, WOUT. The artifact each Stage A
# writes comes from STUB_ART / STUB_ART_OVERRIDE, set by the caller.
STUB_ART=""; STUB_ART_OVERRIDE=""
run_wrapper() {
  : > "$W/calls"; : > "$W/popups"
  WOUT="$(cd "$W/repo" && env -i PATH="$STUBS:$PATH" HOME="$W/home" TMPDIR="$W/tmp" USER=harness LOGNAME=harness \
      GIT_AUTHOR_NAME=h GIT_AUTHOR_EMAIL=h@example.invalid GIT_COMMITTER_NAME=h GIT_COMMITTER_EMAIL=h@example.invalid \
      CLAUDE_BIN="$STUBS/claude" STUB_CALLS="$W/calls" STUB_POPUPS="$W/popups" \
      STUB_ART="$STUB_ART" STUB_ART_OVERRIDE="$STUB_ART_OVERRIDE" \
      bash "$W/repo/scripts/run-loop-news.sh" "$@" 2>&1)"
  WRC=$?
}
calls() { grep -c -x -- "$1" "$W/calls" 2>/dev/null || true; }
published_runs() { git -C "$W/origin.git" log main --format=%s 2>/dev/null | grep -c '^feat: loop news run ' || true; }

# w_expect <label> <rc> <stage-A-calls> <stage-B-calls> <published-commits> <log-substring>
# Returns 0 when the wrapper behaved as described; on a mismatch sets WHY. Sections 2 and the mutant
# pass both use it, so "the scenario passes" and "the mutant is caught" are the same judgement.
w_expect() {
  local label="$1" erc="$2" ea="$3" eb="$4" epub="$5" esub="$6"
  local a b pub; a="$(calls /fetch-loop-news)"; b="$(calls /integrate-loop-news)"; pub="$(published_runs)"
  WHY=""
  [[ "$WRC" -eq "$erc" ]]  || WHY+="exit $WRC (want $erc); "
  [[ "$a"   -eq "$ea"  ]]  || WHY+="Stage A ran ${a}x (want $ea); "
  [[ "$b"   -eq "$eb"  ]]  || WHY+="Stage B ran ${b}x (want $eb); "
  [[ "$pub" -eq "$epub" ]] || WHY+="origin has $pub run commit(s) (want $epub); "
  [[ "$WOUT" == *"$esub"* ]] || WHY+="output lacks '$esub'; "
  [[ -z "$WHY" ]]
}
w_report() { local label="$1"; if [[ -z "$WHY" ]]; then pass "$label" "exit $WRC"; else fail "$label" "$WHY"; fi; }

scenario_logged_in()  { world "$1"; STUB_ART="$FIX/in.json";  STUB_ART_OVERRIDE=""; run_wrapper
                        w_expect W0 0 1 1 1 "Run complete"; }
# Logged out: exit 8, ONE Stage A (no retry burn), Stage B never started, nothing published. The
# override-honouring artifact is on offer to Stage A throughout, so a wrapper that wrote the override
# file WITHOUT the flag would let it through — and this scenario would catch that.
scenario_blocked()    { world "$1"; STUB_ART="$FIX/${2:-out}.json"; STUB_ART_OVERRIDE="$FIX/ovr.json"; run_wrapper
                        w_expect W1 8 1 0 0 "STOPPED, exit 8"; }
scenario_assert_gone(){ world "$1" drop; STUB_ART="$FIX/in.json"; STUB_ART_OVERRIDE=""; run_wrapper
                        w_expect W8 8 1 0 0 "status 127"; }
# W1 plus "no override file reached Stage A" — the one property the exit code alone cannot show, since
# assert-x-login.sh would still refuse an override the operator never gave.
scenario_blocked_out(){ scenario_blocked "$1" out && ! grep -qx 'A-saw-override-file' "$W/calls"; }

echo "(each case below is a full wrapper run in a scratch repo)"
scenario_logged_in "$WRAPPER"; w_report "W0 SANITY logged-in: Stage B runs, one commit published"
scenario_blocked "$WRAPPER" out; w_report "W1 logged-out: exit 8, Stage B never started, nothing published"
if [[ "$(grep -c 'A-saw-override-file' "$W/calls")" -eq 0 ]]; then pass "W1b no flag, no override file reaches Stage A"
else fail "W1b no flag, no override file reaches Stage A" "the wrapper wrote .loop-news/x-login-override unasked"; fi
[[ -f "$W/repo/logs/findings-$(date -u +%Y%m%d).json" ]] \
  && pass "W1c blocked artifact is kept for the resumed run" \
  || fail "W1c blocked artifact is kept for the resumed run" "logs/findings-<today>.json missing"
case "$WOUT" in *"NOTIFY: STOPPED, exit 8"*) pass "W1d the operator is notified (log + popup path)";; *) fail "W1d the operator is notified (log + popup path)" "no NOTIFY line";; esac
[[ -s "$W/popups" ]] && pass "W1e osascript was invoked" || fail "W1e osascript was invoked" "popup stub saw nothing"

# The operator logs in and re-runs: Stage A must be handed the SAVED artifact, not start from nothing.
STUB_ART="$FIX/in.json"; STUB_ART_OVERRIDE=""; run_wrapper
if w_expect W2 0 1 1 1 "RESUME (partial)"; then pass "W2 re-run after logging in resumes the saved artifact and publishes"
else fail "W2 re-run after logging in resumes the saved artifact and publishes" "$WHY"; fi
grep -qx 'A-saw-seed' "$W/calls" && pass "W2b Stage A found the banked artifact on disk" || fail "W2b Stage A found the banked artifact on disk" "no seed"

scenario_blocked "$WRAPPER" unk; w_report "W3 state unknown: exit 8 (cannot tell is not logged in)"
scenario_blocked "$WRAPPER" nox; w_report "W4 no x_login (preflight skipped): exit 8"
scenario_assert_gone "$WRAPPER"; w_report "W5 assert-x-login.sh missing from disk: exit 8, fails closed"

# The override, honoured by Stage A: the flag creates the file, the stub honours it, the run publishes.
world "$WRAPPER"; STUB_ART="$FIX/out.json"; STUB_ART_OVERRIDE="$FIX/ovr.json"; run_wrapper --allow-x-logged-out
if w_expect W6 0 1 1 1 "Publishing with NO X coverage"; then pass "W6 --allow-x-logged-out: publishes, loudly, with the override honoured"
else fail "W6 --allow-x-logged-out: publishes, loudly, with the override honoured" "$WHY"; fi
grep -qx 'A-saw-override-file' "$W/calls" && pass "W6b the flag put the override file where Stage A reads it" || fail "W6b the flag put the override file where Stage A reads it" "Stage A never saw it"

# The flag does not make the wrapper trust a Stage A that ignored it.
world "$WRAPPER"; STUB_ART="$FIX/out.json"; STUB_ART_OVERRIDE=""; run_wrapper --allow-x-logged-out
w_expect W7 8 1 0 0 "does not honour it" && pass "W7 flag set but Stage A stopped anyway: exit 8, not a silent publish" || fail "W7 flag set but Stage A stopped anyway: exit 8, not a silent publish" "$WHY"
# An artifact cannot grant itself an override the operator never gave.
world "$WRAPPER"; STUB_ART="$FIX/ovr.json"; STUB_ART_OVERRIDE=""; run_wrapper
w_expect W7b 8 1 0 0 "STOPPED, exit 8" && pass "W7b artifact claims an override the operator did not give: exit 8" || fail "W7b artifact claims an override the operator did not give: exit 8" "$WHY"

# ═══ 3. the placement and the contract strings, statically ═════════════════════════════════════
echo
echo "static: where the gate sits, and that the three files agree on their contract"
echo
nA=$(grep -n 'run_claude "attempt .* A (search)"' "$WRAPPER" | head -1 | cut -d: -f1)
nG=$(grep -n 'assert-x-login.sh' "$WRAPPER" | grep -v '^[0-9]*:#' | grep -v 'echo\|notify' | head -1 | cut -d: -f1)
nP=$(grep -n 'published_state "\$WT_DIR"' "$WRAPPER" | head -1 | cut -d: -f1)
nB=$(grep -n 'run_claude "attempt .* B (integrate)"' "$WRAPPER" | head -1 | cut -d: -f1)
if [[ -n "$nA" && -n "$nG" && -n "$nP" && -n "$nB" ]] && (( nA < nG && nG < nP && nP < nB )); then
  pass "S1 gate is after Stage A and before the pre-Stage-B guard and Stage B" "lines A=$nA gate=$nG pre=$nP B=$nB"
else fail "S1 gate is after Stage A and before the pre-Stage-B guard and Stage B" "A=${nA:-?} gate=${nG:-?} pre=${nP:-?} B=${nB:-?}"; fi
[[ "$(grep -c '^[[:space:]]*exit 8$' "$WRAPPER")" -eq 2 ]] && pass "S2 exactly two exit 8 arms (blocked, cannot-tell)" || fail "S2 exactly two exit 8 arms (blocked, cannot-tell)" "found $(grep -c '^[[:space:]]*exit 8$' "$WRAPPER")"
[[ "$(grep -c 'bash "\$REPO_ROOT/scripts/assert-x-login.sh"' "$WRAPPER")" -eq 1 ]] && pass "S3 the wrapper calls assert-x-login.sh from one place" || fail "S3 the wrapper calls assert-x-login.sh from one place" ""
contract_ok=1
grep -q 'x-login-override' "$SKILL"   || { contract_ok=0; echo "    skill lacks x-login-override"; }
grep -q 'x-login-override' "$WRAPPER" || { contract_ok=0; echo "    wrapper lacks x-login-override"; }
grep -q 'blocked: x-login' "$SKILL"   || { contract_ok=0; echo "    skill lacks 'blocked: x-login'"; }
grep -q 'blocked: x-login' "$ASSERT"  || { contract_ok=0; echo "    assert-x-login.sh lacks 'blocked: x-login'"; }
grep -q 'x_login' "$SKILL"            || { contract_ok=0; echo "    skill lacks x_login"; }
grep -q -- '--allow-x-logged-out' "$SKILL" || { contract_ok=0; echo "    skill never names the flag"; }
(( contract_ok )) && pass "S4 skill, wrapper and assert script use the same field, file name and gap prefix" || fail "S4 skill, wrapper and assert script use the same field, file name and gap prefix" ""
grep -qE '"\$LN_ARG0" "\$LN_ARG1" "\$@"' "$HERE/run-loop-news-now.sh" && pass "S6 run-loop-news-now.sh forwards its arguments to the wrapper (read, not run: the real tracker is not run here)" || fail "S6 run-loop-news-now.sh forwards its arguments to the wrapper" "the exec line lost \"\$@\""
grep -qE '^\| `8` \|' "$SCHED" && pass "S5 exit 8 is in scripts/SCHEDULING.md's exit-code table" || fail "S5 exit 8 is in scripts/SCHEDULING.md's exit-code table" "row missing"

# ═══ 4. the preflight snippet, extracted from the skill and run under node ═══════════════════════
echo
echo "the Phase 1 step 4 snippet, as written in SKILL.md, against stubbed DOMs"
echo
if ! command -v node >/dev/null; then
  fail "J0 node is available to run the snippet" "node not found — the snippet cases cannot run, and a check that cannot run has not passed"
else
  awk '/X login preflight/ {on=1} on && /```javascript/ {grab=1; next} grab && /```/ {exit} grab {print}' "$SKILL" > "$TMP/snippet.js"
  if [[ ! -s "$TMP/snippet.js" ]]; then fail "J0 the snippet was found in SKILL.md" "extraction produced nothing"; else
    cat > "$TMP/run-snippet.js" <<'JS'
const fs = require('fs');
const [,, file, path, sw, co, lg] = process.argv;
// REPL semantics in javascript_tool return the last expression; an async function needs a return.
const src = fs.readFileSync(file, 'utf8').trim().replace(/JSON\.stringify\(o\)$/, 'return JSON.stringify(o)');
globalThis.setTimeout = (fn) => fn();   // the snippet's 3 s waits are not the property under test
const counts = {
  '[data-testid="SideNav_AccountSwitcher_Button"]': +sw,
  '[data-testid="SideNav_NewTweet_Button"]': +co,
  '[data-testid="loginButton"]': +lg,
};
globalThis.document = { querySelectorAll: (s) => ({ length: counts[s] || 0 }) };
globalThis.location = { pathname: path };
const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
new AsyncFunction(src)().then((r) => console.log(JSON.parse(r).state), (e) => { console.log('ERROR ' + e.message); process.exit(1); });
JS
    # j_case <label> <expected-state> <path> <switcher> <compose> <login>
    j_case() {
      local got; got="$(node "$TMP/run-snippet.js" "$TMP/snippet.js" "$3" "$4" "$5" "$6" 2>&1)"
      if [[ "$got" == "$2" ]]; then pass "$1" "$got"; else fail "$1" "expected $2, got: $got"; fi
    }
    j_case "J1 /home with account switcher and Post button: logged-in"   logged-in  /home 1 1 0
    j_case "J2 /home with only one of the two markers: unknown"          unknown    /home 1 0 0
    j_case "J3 /home, page not rendered yet (no markers): unknown"       unknown    /home 0 0 0
    j_case "J4 redirected to the login flow: logged-out"                 logged-out /i/flow/login 0 0 0
    j_case "J5 landing page with a Log in button: logged-out"            logged-out / 0 0 1
    j_case "J6 some other page entirely: unknown, never logged-in"       unknown    / 0 0 0
  fi
fi

# ═══ 5. mutants: break the wrapper on purpose; the scenarios must notice ═════════════════════════
echo
echo "mutants — each breaks the wrapper; the scenario that guards it must FAIL"
echo
# mutate <name> <old> <new> <scenario-fn> [args] — a mutant is KILLED when the guarding scenario
# reports a failure. Also fails if the mutation did not apply, which would make a survivor look dead.
mutate() {
  local name="$1" old="$2" new="$3"; shift 3
  python3 - "$WRAPPER" "$TMP/mutant.sh" "$old" "$new" <<'PY'
import sys
src, dst, old, new = sys.argv[1:5]
s = open(src).read()
if s.count(old) != 1 or s.count("BACKOFF_SECONDS=(30 90 180)") != 1:
    sys.exit(3)
# The mutant copy also gets no retry backoff: a broken gate sends the run into the wrapper's own
# 30s + 90s waits, and the harness has no reason to sit through them. Test-only; the shipped file is untouched.
open(dst, "w").write(s.replace(old, new).replace("BACKOFF_SECONDS=(30 90 180)", "BACKOFF_SECONDS=(0 0 0)"))
PY
  local prc=$?
  if [[ "$prc" -ne 0 ]]; then fail "$name" "mutation did not apply (anchor found $prc) — the wrapper text moved; update this harness"; return; fi
  if "$@" "$TMP/mutant.sh" >/dev/null 2>&1; then fail "$name" "SURVIVED — the scenarios cannot tell the gate is broken"
  else pass "$name" "killed"; fi
}
# The scenario functions print nothing themselves; they return w_expect's status.
mutate "M1 gate never runs"                    'if artifact_usable "$WT_DIR/.loop-news/findings.json"; then
    XL_OUT=' 'if false; then
    XL_OUT=' scenario_blocked_out
mutate "M2 blocked arm continues instead of exit 8" 'Log in to X in the Chrome the CLI drives, then re-run (Stage A resumes from the saved artifact), or re-run with --allow-x-logged-out to publish without X. See ${LOG_FILE}."
      exit 8' 'Log in to X in the Chrome the CLI drives, then re-run (Stage A resumes from the saved artifact), or re-run with --allow-x-logged-out to publish without X. See ${LOG_FILE}."
      :' scenario_blocked_out
mutate "M3 cannot-tell arm continues (a catch-all that means fine)" 'Nothing was published and Stage B did not run. ${XL_NOTE} See ${LOG_FILE}."
      exit 8' 'Nothing was published and Stage B did not run. ${XL_NOTE} See ${LOG_FILE}."
      :' scenario_assert_gone
mutate "M4 override file written without the flag" 'if [[ "$LOOP_ALLOW_X_LOGGED_OUT" == "1" ]]; then
  mkdir -p "$WT_DIR/.loop-news"' 'if true; then
  mkdir -p "$WT_DIR/.loop-news"' scenario_blocked_out

# assert_mutant <name> <old> <new> — the same idea one level down: break assert-x-login.sh and require
# at least one of the six verdicts below to change. Each pair is <fixture> <allow-env|-> <expected rc>.
assert_mutant() {
  local name="$1" old="$2" new="$3"
  python3 - "$ASSERT" "$TMP/mutant-assert.sh" "$old" "$new" <<'PY'
import sys
src, dst, old, new = sys.argv[1:5]
s = open(src).read()
if s.count(old) != 1:
    sys.exit(3)
open(dst, "w").write(s.replace(old, new))
PY
  local prc=$?
  if [[ "$prc" -ne 0 ]]; then fail "$name" "mutation did not apply — assert-x-login.sh text moved; update this harness"; return; fi
  local changed=0 spec f allow erc rc
  for spec in "out - 1" "unk - 1" "nox - 2" "in - 0" "ovr - 1" "ovr 1 3"; do
    read -r f allow erc <<<"$spec"
    if [[ "$allow" == "-" ]]; then env -u LOOP_ALLOW_X_LOGGED_OUT bash "$TMP/mutant-assert.sh" "$FIX/$f.json" >/dev/null 2>&1; rc=$?
    else LOOP_ALLOW_X_LOGGED_OUT="$allow" bash "$TMP/mutant-assert.sh" "$FIX/$f.json" >/dev/null 2>&1; rc=$?; fi
    [[ "$rc" -ne "$erc" ]] && changed=1
  done
  (( changed )) && pass "$name" "killed" || fail "$name" "SURVIVED — no fixture verdict changed"
}
assert_mutant "A1 unknown is read as logged-in"  'if state == "logged-in":' 'if state in ("logged-in", "unknown"):'
assert_mutant "A2 a missing x_login defaults to logged-in" 'xl = d.get("x_login")' 'xl = d.get("x_login") or {"state": "logged-in", "checked": d.get("today", ""), "evidence": "defaulted"}'
assert_mutant "A3 the artifact grants itself an override" 'if not allow:' 'if False:'

echo
if [[ "$FAILURES" -eq 0 ]]; then
  echo "PASS — the gate blocks logged-out, unknown and missing states, lets only a positive logged-in"
  echo "       (or an honoured override) through, stops the real wrapper before Stage B, keeps the"
  echo "       artifact for a resumed run, and every mutant of the wrapper was caught."
  exit 0
fi
echo "FAIL — $FAILURES case(s) behaved wrongly. The gate, the wrapper's use of it, or this harness is broken."
echo "       Do not trust a passing case from a harness whose sanity cases (0, W0, W1) did not hold."
exit 1
