#!/usr/bin/env bash
# Run the logic/contract test suite. racket/gui initializes Gtk when required,
# so even this suite needs a display on Linux; wrap in Xvfb when headless.
#
# Usage: bash test/run-pure.sh
set -u

wrap=()
if [ "${RUNNER_OS:-}" = "Linux" ] && command -v xvfb-run >/dev/null 2>&1; then
  wrap=(xvfb-run -a)
fi

"${wrap[@]}" raco test test/run.rkt
