#!/bin/bash
# Plugins: uninstall the highlighted plugin. `herdr plugin uninstall` has no
# confirmation of its own, so this requires typing the plugin's id back
# (stronger than y/N — matches how GitHub gates deleting a repo) since
# there's no undo short of reinstalling from scratch.
set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"
id="${1:?usage: uninstall.sh <plugin_id>}"
herdr_bin="${HERDR_BIN_PATH:-herdr}"

plugin=$(plugin_json_by_id "$id")
if [[ -z "$plugin" ]]; then
  echo "$id is not installed."
  pause
  exit 0
fi

name=$(jq -r '.name' <<<"$plugin")

echo "Uninstall $name ($id)? This removes its files and config dir. No undo — you'd reinstall from scratch."
read -r -p "Type the plugin id to confirm ($id): " confirm
if [[ "$confirm" != "$id" ]]; then
  echo "Cancelled."
  pause
  exit 0
fi

output=$("$herdr_bin" plugin uninstall "$id" 2>&1)
status=$?
echo "$output"
echo

if [[ $status -eq 0 ]]; then
  echo "Uninstalled $id."
else
  echo "Uninstall failed (exit $status). See output above."
fi

pause
