#!/bin/bash
# Plugins: the one render dispatcher for the pane's two views. Reads
# MODE_FILE (installed by default) and renders accordingly — installed view
# reuses the existing cheap render.sh/colorize.sh path (no network); catalog
# view fetches the registry on first entry only, then re-renders from cache
# using whatever sort SORT_FILE currently holds.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

if [[ "$(current_mode)" == "catalog" ]]; then
  [[ -f "$CATALOG_CACHE_FILE" ]] || bash "$script_dir/fetch-catalog.sh"
  sort_mode=$([[ -f "$SORT_FILE" ]] && cat "$SORT_FILE" || echo "stars")
  bash "$script_dir/catalog-rows.sh" "$sort_mode" | bash "$script_dir/colorize-catalog.sh"
else
  bash "$script_dir/render.sh" | bash "$script_dir/colorize.sh"
fi
