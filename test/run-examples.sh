#!/usr/bin/env bash
# Instantiate every example under `raco test`, which runs the module body but
# NOT the `main` submodule — exactly what the package catalog build (DrDr)
# does. Guards the convention that launch code (`(send f show #t)`, worker
# threads) lives in `(module+ main ...)`: top-level launch code, or
# constructing a date-text-field% (it arms a midnight timer), would time out
# both here and on the catalog build.
#
# Needs a display (examples require racket/gui, which initializes Gtk on
# Linux); wrap in Xvfb when headless.
#
# Usage: bash test/run-examples.sh
set -u

if [ "${RUNNER_OS:-}" = "Linux" ] && command -v xvfb-run >/dev/null 2>&1; then
  exec xvfb-run -a raco test examples/
else
  exec raco test examples/
fi
