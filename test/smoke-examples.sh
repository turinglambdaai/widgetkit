#!/usr/bin/env bash
# Launch every example briefly and check that it opens a window without
# erroring. This catches runtime bugs that `raco make` cannot: bad callback
# arities, missing methods, invalid init arguments, broken paint callbacks.
#
# Pass condition: the example is still running (window open) when the timeout
# fires (rc 124). Any other non-zero exit is a failure.
#
# Usage: bash test/smoke-examples.sh
# On headless Linux set RUNNER_OS=Linux (or have xvfb-run on PATH) so each
# launch is wrapped in a virtual display.
#
# Uses GNU timeout when available (it kills the whole process group, which
# matters under xvfb-run); falls back to a pure-bash watchdog for macOS,
# where no `timeout` ships and the child is plain racket.

set -u

TIMEOUT="${TIMEOUT:-8}"
fail=0

TIMEOUT_CMD=""
if command -v timeout >/dev/null 2>&1; then
  TIMEOUT_CMD=timeout
elif command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT_CMD=gtimeout
fi

# Unquoted $RACKET expansion is intentional: on Linux it becomes
# "xvfb-run -a racket", elsewhere just "racket".
RACKET="racket"
if [ "${RUNNER_OS:-}" = "Linux" ] && command -v xvfb-run >/dev/null 2>&1; then
  RACKET="xvfb-run -a racket"
fi

# run_with_timeout SECS CMD... -> kills the (single) command after SECS,
# returns 124 if it was killed, else its exit status. Only used when GNU
# timeout is unavailable.
run_with_timeout() {
  secs=$1
  shift
  "$@" &
  pid=$!
  # SIGKILL, not SIGTERM: Racket treats TERM as a user break and exits with
  # status 1, which we could not distinguish from a real failure.
  (sleep "$secs" && kill -KILL "$pid" 2>/dev/null) &
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
  if [ -n "$TIMEOUT_CMD" ]; then
    out=$($TIMEOUT_CMD "$TIMEOUT" $RACKET "$ex" 2>&1)
    rc=$?
  else
    out=$(run_with_timeout "$TIMEOUT" $RACKET "$ex" 2>&1)
    rc=$?
  fi
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
