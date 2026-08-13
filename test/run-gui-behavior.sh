#!/usr/bin/env bash
# Run the GUI behavioral tests (test/gui-behavior.rkt). Unlike test/run.rkt,
# these instantiate widgets and need a display; on headless Linux they are
# wrapped in Xvfb.
# (No arrays: macOS ships bash 3.2, where expanding an empty array under
# `set -u` is an error.)
#
# Usage: bash test/run-gui-behavior.sh
set -u

if [ "${RUNNER_OS:-}" = "Linux" ] && command -v xvfb-run >/dev/null 2>&1; then
  exec xvfb-run -a raco test test/gui-behavior.rkt
else
  exec raco test test/gui-behavior.rkt
fi
