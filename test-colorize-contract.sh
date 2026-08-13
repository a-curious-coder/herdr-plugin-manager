#!/usr/bin/env bash
# Contract test, not a unit test: enter-dispatcher.sh and preview-dispatcher.sh
# both call fzf with {2} and assume it's plugin_id — true only because
# colorize.sh and colorize-catalog.sh both happen to put it at token 2 of
# their output. Nothing enforces that agreement; a column reorder in either
# file breaks dispatch silently (wrong plugin acted on, or "no such plugin"
# errors) with no error at the point of the actual mistake. This test is the
# assertion that invariant relies on — it fails loudly, at the source, the
# moment either script's column order drifts. (Design by Contract: an
# implicit assumption two files silently share should be a checked
# assertion, not a comment hoping nobody drifts — The Pragmatic Programmer.)
set -uo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

failures=0
plugin_id="contract.test.plugin-id"

# colorize.sh row shape: sort_key state plugin_id name source_kind
installed_row=$(printf '1\te\t%s\tSome Plugin\tgithub\n' "$plugin_id")
token2=$(bash "$script_dir/colorize.sh" <<<"$installed_row" | awk '{print $2}')
if [[ "$token2" != "$plugin_id" ]]; then
  echo "FAIL: colorize.sh token 2 is '$token2', expected plugin_id '$plugin_id'"
  failures=$((failures + 1))
fi

# colorize-catalog.sh row shape: installed plugin_id name full_name subdir stars updated_at
catalog_row=$(printf '0\t%s\tSome Plugin\towner/repo\t\t42\t2026-01-01T00:00:00Z\n' "$plugin_id")
token2=$(bash "$script_dir/colorize-catalog.sh" <<<"$catalog_row" | awk '{print $2}')
if [[ "$token2" != "$plugin_id" ]]; then
  echo "FAIL: colorize-catalog.sh token 2 is '$token2', expected plugin_id '$plugin_id'"
  failures=$((failures + 1))
fi

if [[ "$failures" -eq 0 ]]; then
  echo "test-colorize-contract.sh: all checks passed"
  exit 0
else
  echo "test-colorize-contract.sh: $failures failure(s)"
  exit 1
fi
