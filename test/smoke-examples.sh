#!/usr/bin/env bash
# Launch every example briefly and check that it opens a window without
# erroring. This catches runtime bugs that `raco make` cannot: bad callback
# arities, missing methods, invalid init arguments, broken paint callbacks.
#
# Pass condition: the example is still running (window open) when the timeout
# fires (watchdog kills it -> rc 124). Any other non-zero exit is a failure.
#
# Usage: bash test/smoke-examples.sh
# On headless Linux set RUNNER_OS=Linux (or have xvfb-run on PATH) so each
# launch is wrapped in a virtual display.
#
# No external `timeout` command and no arrays: macOS ships bash 3.2 without
# GNU coreutils, where `timeout` is missing and expanding an empty array
# under `set -u` is an error.

set -u

TIMEOUT="${TIMEOUT:-8}"
fail=0

# Unquoted expansion is intentional: on Linux this becomes
# "xvfb-run -a racket", elsewhere just "racket".
RACKET="racket"
if [ "${RUNNER_OS:-}" = "Linux" ] && command -v xvfb-run >/dev/null 2>&1; then
  RACKET="xvfb-run -a racket"
fi

# run_with_timeout SECS CMD... -> runs CMD, kills it after SECS, returns 124
# if it was killed, else the command's exit status.
run_with_timeout() {
  secs=$1
  shift
  "$@" &
  pid=$!
  (sleep "$secs" && kill -TERM "$pid" 2>/dev/null) &
  watchdog=$!
  wait "$pid"
  rc=$?
  kill -KILL "$watchdog" 2>/dev/null
  wait "$watchdog" 2>/dev/null
  if [ "$rc" -ge 128 ]; then
    return 124
  fi
  return "$rc"
}

for ex in examples/*.rkt; do
  out=$(run_with_timeout "$TIMEOUT" $RACKET "$ex" 2>&1)
  rc=$?
  if [ "$rc" -eq 124 ]; then
    echo "OK   $ex"
  else
    echo "FAIL $ex (rc=$rc)"
    echo "$out" | head -20
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "all examples launched cleanly"
fi
exit "$fail"
