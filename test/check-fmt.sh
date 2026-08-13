#!/usr/bin/env bash
# Fail if any Racket source file is not formatted with `raco fmt` (width 102).
# Run: bash test/check-fmt.sh
set -u

fail=0
files=(main.rkt info.rkt private/*.rkt examples/*.rkt test/*.rkt)

for f in "${files[@]}"; do
  if ! raco fmt --width 102 "$f" 2>/dev/null | diff -q - "$f" >/dev/null 2>&1; then
    echo "NOT FORMATTED: $f  (run: raco fmt -i --width 102 $f)"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "all files conform to raco fmt (--width 102)"
fi
exit "$fail"
