#!/usr/bin/env bash
# Run the logic/contract test suite. racket/gui initializes Gtk when required,
# so even this suite needs a display on Linux; wrap in Xvfb when headless.
# (No arrays: macOS ships bash 3.2, where expanding an empty array under
# `set -u` is an error.)
#
# Usage: bash test/run-pure.sh
set -u

if [ "${RUNNER_OS:-}" = "Linux" ] && command -v xvfb-run >/dev/null 2>&1; then
  exec xvfb-run -a raco test test/run.rkt
else
  exec raco test test/run.rkt
fi
