#!/bin/bash
# Plugins: footer hint driven by fzf's `result` event (fires whenever the
# filtered list settles, including after a reload) — the exact moment
# someone searches the installed view for a plugin that isn't installed is
# also the exact moment they need to know 'tab' searches the public
# registry too. Silent (empty footer) otherwise; self-clears on its own
# next firing once the query changes, the mode switches, or matches appear.
set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

if [[ "$(current_mode)" == "installed" && "${FZF_MATCH_COUNT:-0}" -eq 0 && -n "${FZF_QUERY:-}" ]]; then
  printf '\033[33mNo installed plugin matches "%s" — press tab to search the public registry instead\033[0m\n' "$FZF_QUERY"
fi
