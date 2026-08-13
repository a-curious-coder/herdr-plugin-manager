#!/bin/bash
# Plugins: confirm + install a browse-mode row. Looks up owner/repo/subdir
# from the cached catalog by plugin_id (same self-lookup pattern as
# toggle.sh/update.sh use against the installed list) rather than trusting
# extra args — keeps enter-dispatcher.sh's call uniform across both modes.
# Bound via fzf's execute() (not execute-silent) — installing is a real,
# non-trivial side effect, so it prompts y/N rather than firing on Enter.
set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

id="${1:?usage: install-from-catalog.sh <plugin_id>}"
herdr_bin="${HERDR_BIN_PATH:-herdr}"

[[ -f "$CATALOG_CACHE_FILE" ]] || { echo "no catalog cached"; read -r -p "Press enter to continue..." _; exit 0; }

entry=$(jq -c --arg id "$id" '
  [.plugins[] as $repo | $repo.manifests[] as $m | select($m.id == $id) | {
    full_name: $repo.fullName,
    subdir: ($m.path | if test("/") then sub("/[^/]+$"; "") else "" end)
  }] | .[0]
' "$CATALOG_CACHE_FILE")

if [[ "$entry" == "null" || -z "$entry" ]]; then
  echo "no such catalog entry: $id"
  read -r -p "Press enter to continue..." _
  exit 0
fi

full_name=$(jq -r '.full_name' <<<"$entry")
subdir=$(jq -r '.subdir' <<<"$entry")
spec="$full_name"
[[ -n "$subdir" ]] && spec="$full_name/$subdir"

read -r -p "Install $spec ? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Cancelled."
  read -r -p "Press enter to continue..." _
  exit 0
fi

output=$("$herdr_bin" plugin install "$spec" -y 2>&1)
status=$?
echo "$output"
echo

if [[ $status -eq 0 ]]; then
  echo "Installed $spec."
  bash "$script_dir/post-install-summary.sh" "$id"
else
  echo "Install failed (exit $status). See output above."
fi

read -r -p "Press enter to continue..." _
