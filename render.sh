#!/bin/bash
# Plugins: cheap re-render for fzf's every(0.5s) tick and post-toggle/update
# reloads — local plugin-list read + cached update-check results + in-flight
# update markers, no network call. The network pass lives in build-rows.sh,
# which writes the cache this reads.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/row-builder.sh"
source "$script_dir/paths.sh"

herdr_bin="${HERDR_BIN_PATH:-herdr}"
json=$("$herdr_bin" plugin list --json 2>/dev/null) || { echo "render: herdr plugin list failed" >&2; exit 1; }

updates_json='{}'
[[ -f "$CACHE_FILE" ]] && updates_json=$(cat "$CACHE_FILE")

plugin_rows "$json" "$updates_json" "$(updating_ids_json "$UPDATING_DIR")"
