#!/usr/bin/env bash
# Run the GUI behavioral tests (test/gui-behavior.rkt). Unlike test/run.rkt,
# these instantiate widgets and need a display; on headless Linux they are
# wrapped in Xvfb.
#
# Usage: bash test/run-gui-behavior.sh
set -u

wrap=()
if [ "${RUNNER_OS:-}" = "Linux" ] && command -v xvfb-run >/dev/null 2>&1; then
  wrap=(xvfb-run -a)
fi

"${wrap[@]}" raco test test/gui-behavior.rkt
