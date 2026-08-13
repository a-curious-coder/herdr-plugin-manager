#!/bin/bash
# Plugins: header text for the current mode — two lines: what you're
# looking at, then the keys. Full descriptions live behind '?' (help.sh).
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

if [[ "$(current_mode)" == "catalog" ]]; then
  echo "Plugins — BROWSE REGISTRY (tab: back to installed) · green check = already installed"
  sort_mode=$([[ -f "$SORT_FILE" ]] && cat "$SORT_FILE" || echo "stars")
  echo "/ search (esc cancels) · enter install · a run/bind action · s sort [${sort_mode}] · d uninstall · r re-fetch · z zoom preview · o open repo · ? help · q quit"
else
  echo "Plugins — INSTALLED (tab: browse registry) · green enabled · yellow update · gray disabled · spinner updating"
  echo "/ search (esc cancels) · enter toggle · a run/bind action · u update · i install by name · d uninstall · r refresh · z zoom preview · o open repo · ? help · q quit"
fi
