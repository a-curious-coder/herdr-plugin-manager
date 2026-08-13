#!/bin/bash
# Plugins: preview source depends on mode — help legend if '?' toggled it
# on, otherwise whichever view the pane is currently in (same dispatch idea
# as enter-dispatcher.sh).
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

id="${1:?usage: preview-dispatcher.sh <plugin_id>}"

if [[ -f "$HELP_FILE" ]]; then
  bash "$script_dir/help.sh"
elif [[ "$(current_mode)" == "catalog" ]]; then
  bash "$script_dir/preview-catalog.sh" "$id"
else
  bash "$script_dir/preview.sh" "$id"
fi
