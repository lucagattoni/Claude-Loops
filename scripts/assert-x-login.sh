#!/usr/bin/env bash
# Did Stage A positively establish that Chrome was logged in to X? (backlog A19)
#
#   usage: assert-x-login.sh <path to .loop-news/findings.json>
#   env:   LOOP_ALLOW_X_LOGGED_OUT=1   the operator accepts a run with no X coverage
#
# WHY THIS EXISTS. On 2026-10-19 Stage A swept all 11 `x` sources and both X searches with Chrome
# logged out of X. Every search hit a login wall, 12 coverage records were `partial`, Stage B
# published v3.7.7 and the wrapper exited 0. The only notice was a line inside the digest. Recovery
# was a ~50-minute logged-in re-sweep. fetch-loop-news Phase 1 step 4 now reads X's login state
# before dispatching anything and records it in the artifact as `x_login`; this script is the
# wrapper's reading of that field. Same shape as assert-published.sh: one question, answered by a
# script the verify harness can run as shipped.
#
# THE RULE (the repo's defining one): a check that cannot tell must fail. Only a positive
# `logged-in` passes. A missing field, a malformed one, an unreadable file, `unknown` and
# `logged-out` all stop the run — "no evidence of a login wall" is not evidence of a login.
#
# Exit codes — own namespace, like assert-published.sh; callers must enumerate 0 and 3 and treat
# EVERY other code (including 127, a missing script) as "do not proceed":
#   0  logged in — `x_login.state` is "logged-in", stamped with today's date, with evidence, and no
#      coverage record contradicts it
#   3  NOT logged in, but the operator set LOOP_ALLOW_X_LOGGED_OUT=1 AND the artifact honours it:
#      complete, `x_login.override` true, and every unswept X-bound key carries a
#      `blocked: x-login` record (so the digest says so). A degraded run chosen, not suffered.
#   1  NOT logged in (`logged-out` or `unknown`) and no valid override: a decision is needed
#   2  CANNOT TELL — unreadable artifact, missing or malformed `x_login`, a state that contradicts
#      the coverage records. Never an override case: an override accepts a known gap, not an
#      unknown one.
#
# One line of diagnostic goes to stdout. X-bound keys are `x:*`, `x-search:*` and
# `phase-3:x-general-search` — the same set fetch-loop-news calls browser-bound on X.

set -uo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: assert-x-login.sh <findings.json>" >&2
  exit 2
fi

exec python3 - "$1" <<'PY'
import json, os, sys

path = sys.argv[1]
allow = os.environ.get("LOOP_ALLOW_X_LOGGED_OUT", "") == "1"


def out(rc, msg):
    print(f"x-login: {msg}")
    sys.exit(rc)


try:
    with open(path) as f:
        d = json.load(f)
except Exception as e:  # unreadable or unparseable: cannot tell, never "fine"
    out(2, f"CANNOT TELL — cannot read {path}: {e}")
if not isinstance(d, dict):
    out(2, "CANNOT TELL — artifact is not a JSON object")

xl = d.get("x_login")
if not isinstance(xl, dict):
    out(2, "CANNOT TELL — artifact has no `x_login` object; Stage A did not run the X login "
           "preflight (fetch-loop-news Phase 1 step 4), so nothing says Chrome was logged in")
state = xl.get("state")
if state not in ("logged-in", "logged-out", "unknown"):
    out(2, f"CANNOT TELL — `x_login.state` is {state!r}, not logged-in / logged-out / unknown")

today = d.get("today")
checked = xl.get("checked")
evidence = xl.get("evidence")
if not (isinstance(today, str) and today and isinstance(checked, str) and checked.startswith(today)):
    out(2, f"CANNOT TELL — `x_login.checked` ({checked!r}) is not stamped with today ({today!r})")
if not (isinstance(evidence, str) and evidence.strip()):
    out(2, "CANNOT TELL — `x_login.evidence` is empty; a state with nothing read behind it is a guess")

expected = d.get("expected_keys")
if not isinstance(expected, list) or not all(isinstance(k, str) for k in expected):
    out(2, "CANNOT TELL — artifact has no usable `expected_keys`, so X-bound sources cannot be listed")
xkeys = [k for k in expected
         if k.startswith("x:") or k.startswith("x-search:") or k == "phase-3:x-general-search"]
if not xkeys:
    out(2, "CANNOT TELL — `expected_keys` names no X-bound source; the artifact is not this pipeline's")

coverage = d.get("coverage")
if not isinstance(coverage, list):
    out(2, "CANNOT TELL — `coverage` is not a list")
by_key = {}
for r in coverage:
    if isinstance(r, dict) and isinstance(r.get("source"), str):
        by_key[r["source"]] = r


def blocked(key):
    r = by_key.get(key)
    return bool(r) and isinstance(r.get("gap"), str) and r["gap"].startswith("blocked: x-login")


if state == "logged-in":
    stale = [k for k in by_key if blocked(k)]
    if stale:
        out(2, f"CANNOT TELL — state is logged-in yet {len(stale)} coverage record(s) say "
               f"`blocked: x-login` (e.g. {stale[0]}); the artifact contradicts itself")
    out(0, f"logged in (checked {checked}) — {evidence.strip()[:160]}")

# Not logged in. From here every path is a stop unless the override is honoured in full.
sources_done = d.get("sources_done")
done = set(sources_done) if isinstance(sources_done, list) else set()
unswept = [k for k in xkeys if k not in done]
missing = [k for k in unswept if not blocked(k)]
what = (f"Chrome is not logged in to X (state={state}, checked {checked}): "
        f"{evidence.strip()[:160]}. {len(unswept)} of {len(xkeys)} X-bound sources unswept")

if not allow:
    out(1, f"BLOCKED — {what}")

problems = []
if d.get("complete") is not True:
    problems.append(f"`complete` is {d.get('complete')!r}, not true (Stage A stopped instead of finishing)")
if xl.get("override") is not True:
    problems.append("`x_login.override` is not true (Stage A did not record the operator's decision)")
if missing:
    problems.append(f"{len(missing)} unswept X-bound key(s) have no `blocked: x-login` record "
                    f"(e.g. {missing[0]}), so the digest would not say they were skipped")
if problems:
    out(1, f"BLOCKED — LOOP_ALLOW_X_LOGGED_OUT=1 is set but the artifact does not honour it: "
           + "; ".join(problems) + f". {what}")
out(3, f"DEGRADED BY OPERATOR OVERRIDE — {what}; every one carries a `blocked: x-login` record")
PY
