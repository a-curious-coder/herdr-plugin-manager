#!/bin/bash
# Plugins: ctrl-r's network refresh, mode-dependent — re-runs the
# update-check for installed view, or re-fetches the registry for browse
# view. Output is discarded; the fzf reload that follows re-renders from
# whatever this just wrote to cache.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

if [[ "$(current_mode)" == "catalog" ]]; then
  bash "$script_dir/fetch-catalog.sh"
else
  bash "$script_dir/assemble-rows.sh" --network >/dev/null
fi
