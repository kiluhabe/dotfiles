#!/usr/bin/env bash
set -euo pipefail

# Runs every fixtures/<filter>/<case>.input.json through lib/<filter>.jq and
# compares the result with <case>.expected.json. Pass case names as arguments
# to run only those.

DIR=$(cd "$(dirname "$0")" && pwd)
pass=0
fail=0

for input in "$DIR"/fixtures/*/*.input.json; do
  filter=$(basename "$(dirname "$input")")
  name=$(basename "$input" .input.json)
  if [ $# -gt 0 ] && ! printf '%s\n' "$@" | grep -qx "$name"; then
    continue
  fi
  expected=$(jq -cS . "${input%.input.json}.expected.json")
  if actual=$(jq -cS -f "$DIR/lib/$filter.jq" "$input" 2>&1) && [ "$actual" = "$expected" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FAIL $filter/$name"
    echo "  expected: $expected"
    echo "  actual:   $actual"
  fi
done

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
