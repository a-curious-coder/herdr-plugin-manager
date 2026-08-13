#!/bin/bash
# Plugins: flips a plugin between enabled/disabled. Re-reads current state
# from `herdr plugin list --json` rather than trusting the row fzf passed
# in — confirmed (herdr-plugin-manager-3e81) that enable/disable takes effect
# immediately, no server reload needed, so this is always accurate.
#
# On disable, also reaps the plugin's already-spawned daemons (see reap.sh —
# `herdr plugin disable` alone leaves them running).
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"
id="${1:?usage: toggle.sh <plugin_id>}"
herdr_bin="${HERDR_BIN_PATH:-herdr}"

enabled=$(plugin_json_by_id "$id" | jq -r '.enabled')

if [[ "$enabled" == "true" ]]; then
  "$herdr_bin" plugin disable "$id" >/dev/null
  bash "$script_dir/reap.sh" "$id"
else
  "$herdr_bin" plugin enable "$id" >/dev/null
fi
