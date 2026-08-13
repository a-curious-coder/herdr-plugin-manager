#!/usr/bin/env bash
# Self-check for row-builder.sh's plugin_rows() — the only non-trivial pure
# logic in this plugin (JSON -> sorted TSV). No framework: run this directly.
set -uo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/row-builder.sh"

failures=0

assert_eq() { # $1 expected $2 actual $3 case description
  if [[ "$1" != "$2" ]]; then
    echo "FAIL: $3"
    echo "  expected: [$1]"
    echo "  actual:   [$2]"
    failures=$((failures + 1))
  fi
}

fixture='{
  "result": {
    "plugins": [
      {"plugin_id": "zeta", "name": "Zeta", "enabled": true, "source": {"kind": "github"}},
      {"plugin_id": "alpha", "name": "Alpha", "enabled": false, "source": {"kind": "local"}},
      {"plugin_id": "beta", "name": "Beta", "enabled": true, "source": {"kind": "local"}},
      {"plugin_id": "gamma", "name": "Gamma", "enabled": true, "source": {"kind": "github"}},
      {"plugin_id": "delta", "name": "Delta", "enabled": true, "source": {"kind": "github"}}
    ]
  }
}'
updates='{"gamma": true, "delta": true}'
updating='["delta"]'

actual=$(plugin_rows "$fixture" "$updates" "$updating")
expected=$'0\ts\tdelta\tDelta\tgithub\n1\td\talpha\tAlpha\tlocal\n2\tu\tgamma\tGamma\tgithub\n3\te\tzeta\tZeta\tgithub\n3\te\tbeta\tBeta\tlocal'

assert_eq "$expected" "$actual" \
  "updating first (even with an update flag), then disabled, then update-available, then current, order preserved within group"

# updating_ids_json: empty dir -> [], populated dir -> sorted-by-readdir ids
empty_dir=$(mktemp -d)
assert_eq '[]' "$(updating_ids_json "$empty_dir")" "no marker dir contents -> empty array"
rmdir "$empty_dir"

assert_eq '[]' "$(updating_ids_json "${TMPDIR:-/tmp}/does-not-exist-herdr-plugins")" "missing marker dir -> empty array"

marker_dir=$(mktemp -d)
touch "$marker_dir/some.plugin"
assert_eq '["some.plugin"]' "$(updating_ids_json "$marker_dir")" "one marker file -> one-element array"
rm -rf "$marker_dir"

if [[ "$failures" -eq 0 ]]; then
  echo "test-build-rows.sh: all checks passed"
  exit 0
else
  echo "test-build-rows.sh: $failures failure(s)"
  exit 1
fi
