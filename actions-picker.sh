#!/bin/bash
# Plugins: lists the highlighted plugin's own actions and lets you invoke
# one right now, or bind it to a key. herdr has no built-in action browser —
# without this, "how do I use this plugin" means reading its herdr-plugin.toml
# or `herdr plugin list --json` by hand.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
id="${1:?usage: actions-picker.sh <plugin_id>}"
herdr_bin="${HERDR_BIN_PATH:-herdr}"

plugin=$("$herdr_bin" plugin list --json | jq -c --arg id "$id" '
  .result.plugins[] | select(.plugin_id == $id)
')
if [[ -z "$plugin" ]]; then
  echo "$id is not installed — nothing to invoke yet."
  read -r -p "Press enter to continue..." _
  exit 0
fi

actions=$(jq -c '.actions // []' <<<"$plugin")
if [[ "$(jq 'length' <<<"$actions")" -eq 0 ]]; then
  echo "$id declares no actions."
  read -r -p "Press enter to continue..." _
  exit 0
fi

rows=$(jq -r '.[] | [.id, .title, (.description // "")] | @tsv' <<<"$actions")

if command -v fzf >/dev/null 2>&1; then
  sel=$(printf '%s\n' "$rows" \
    | awk -F'\t' '{printf "%-24s  %-32s  %s\n", $1, $2, $3}' \
    | fzf --prompt="${id} action> " --no-sort --exact --layout=reverse-list \
          --header="enter: invoke now · ctrl-o: bind to a key · esc: back" \
          --bind="ctrl-o:execute(bash '$script_dir/bind-action.sh' '$id' {1})" \
    ) || true
  [[ -n "${sel:-}" ]] || exit 0

  action_id=$(awk '{print $1}' <<<"$sel")
  output=$("$herdr_bin" plugin action invoke "$action_id" --plugin "$id" 2>&1)
  echo "$output"
  echo
  echo "Invoked ${id}.${action_id}."
  read -r -p "Press enter to continue..." _
else
  printf '%s\n' "$rows" | awk -F'\t' '{printf "%-24s  %-32s  %s\n", $1, $2, $3}'
  read -r -p "Press enter to continue..." _
fi
