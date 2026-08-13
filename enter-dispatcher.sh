#!/bin/bash
# Plugins: what Enter does depends on which view the pane is currently in —
# toggle enable/disabled for an installed row, or confirm+install for a
# browse row. Both scripts take the same plugin_id, since colorize.sh and
# colorize-catalog.sh both put it at the same token position.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

id="${1:?usage: enter-dispatcher.sh <plugin_id>}"

if [[ "$(current_mode)" == "catalog" ]]; then
  bash "$script_dir/install-from-catalog.sh" "$id"
else
  bash "$script_dir/toggle.sh" "$id"
fi
