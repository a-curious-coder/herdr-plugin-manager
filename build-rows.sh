#!/bin/bash
# Plugins: full refresh — network update-check + row render. Used on initial
# pane open and ctrl-r. Writes the update-check result to CACHE_FILE so the
# cheap tick refresh (render.sh) doesn't have to hit the network itself.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/row-builder.sh"
source "$script_dir/paths.sh"

herdr_bin="${HERDR_BIN_PATH:-herdr}"
json=$("$herdr_bin" plugin list --json 2>/dev/null) || { echo "build-rows: herdr plugin list failed" >&2; exit 1; }

updates_tsv=$(bash "$script_dir/check-updates.sh" "$json")
updates_json=$(printf '%s\n' "$updates_tsv" | jq -R -s '
  split("\n") | map(select(length > 0) | split("\t")) | map({(.[0]): (.[1] == "1")}) | add // {}
')
printf '%s' "$updates_json" > "$CACHE_FILE"

plugin_rows "$json" "$updates_json" "$(updating_ids_json "$UPDATING_DIR")"
