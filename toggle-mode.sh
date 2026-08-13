#!/bin/bash
# Plugins: flips the pane between installed and browse (catalog) view.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

if [[ "$(current_mode)" == "catalog" ]]; then
  echo "installed" > "$MODE_FILE"
else
  echo "catalog" > "$MODE_FILE"
fi
