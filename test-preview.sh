#!/usr/bin/env bash
# Self-check for preview.sh — specifically the "mirror" bug: a plugin whose
# actions/panes omit optional fields (contexts, placement) crashed the whole
# jq pipeline with "Cannot iterate over null (null)", leaving Actions blank.
# Stubs herdr_bin's two calls (plugin list --json, plugin config-dir) with a
# fake binary so this runs without a live herdr server.
set -uo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

failures=0
tmp_bin=$(mktemp -d)
trap 'rm -rf "$tmp_bin"' EXIT

cat > "$tmp_bin/herdr" <<'STUB'
#!/bin/bash
if [[ "$1 $2" == "plugin list" ]]; then
  cat <<'JSON'
{"result":{"plugins":[{
  "plugin_id":"mirror","name":"Herdr Mirror","description":"test",
  "version":"0.2.1","min_herdr_version":"0.7.2",
  "plugin_root":"/tmp/mirror","source":{"kind":"github","owner":"x","repo":"y","resolved_commit":"abcdef1234567890"},
  "actions":[{"id":"once","title":"Mirror: sync once"}],
  "panes":[{"id":"main","title":"Mirror pane"}]
}]}}
JSON
elif [[ "$1 $2" == "plugin config-dir" ]]; then
  echo "/tmp/mirror-config"
fi
STUB
chmod +x "$tmp_bin/herdr"

output=$(HERDR_BIN_PATH="$tmp_bin/herdr" bash "$script_dir/preview.sh" mirror 2>&1)
status=$?

if [[ $status -ne 0 ]]; then
  echo "FAIL: preview.sh exited $status on actions/panes missing optional fields"
  echo "$output"
  failures=$((failures + 1))
fi

if ! grep -q "once: Mirror: sync once  \[global\]" <<<"$output"; then
  echo "FAIL: action missing 'contexts' didn't fall back to [global]"
  echo "$output"
  failures=$((failures + 1))
fi

if ! grep -q "main: Mirror pane  (n/a)" <<<"$output"; then
  echo "FAIL: pane missing 'placement' didn't fall back to (n/a)"
  echo "$output"
  failures=$((failures + 1))
fi

if [[ "$failures" -eq 0 ]]; then
  echo "test-preview.sh: all checks passed"
  exit 0
else
  echo "test-preview.sh: $failures failure(s)"
  exit 1
fi
