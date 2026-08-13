#!/bin/bash
# Plugins: renders installed-view rows. Cheap by default (local plugin-list
# read + cached update-check results, no network) — pass --network to also
# re-run check-updates.sh and refresh CACHE_FILE first. Used by
# unified-render.sh (cheap, every tick) and refresh.sh (--network, ctrl-r).
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/row-builder.sh"
source "$script_dir/paths.sh"

herdr_bin="${HERDR_BIN_PATH:-herdr}"
json=$("$herdr_bin" plugin list --json 2>/dev/null) || { echo "assemble-rows: herdr plugin list failed" >&2; exit 1; }

if [[ "${1:-}" == "--network" ]]; then
  updates_tsv=$(bash "$script_dir/check-updates.sh" "$json")
  updates_json=$(printf '%s\n' "$updates_tsv" | jq -R -s '
    split("\n") | map(select(length > 0) | split("\t")) | map({(.[0]): (.[1] == "1")}) | add // {}
  ')
  printf '%s' "$updates_json" > "$CACHE_FILE"
else
  updates_json=$(file_value "$CACHE_FILE" "{}")
fi

plugin_rows "$json" "$updates_json" "$(updating_ids_json "$UPDATING_DIR")"
