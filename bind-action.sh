#!/bin/bash
# Plugins: appends a [[keys.command]] block to your dotfiles config.toml for
# one plugin action, after showing the exact TOML and asking for confirm —
# editing your hand-maintained config as a keypress side effect without
# showing you first would be the wrong kind of automatic. Reloads herdr's
# config immediately on success so the new key works without restarting.
set -uo pipefail

id="${1:?usage: bind-action.sh <plugin_id> <action_id>}"
action_id="${2:?usage: bind-action.sh <plugin_id> <action_id>}"
herdr_bin="${HERDR_BIN_PATH:-herdr}"
config_path="$HOME/Projects/personal/dotfiles/herdr/.config/herdr/config.toml"

if [[ ! -f "$config_path" ]]; then
  echo "config.toml not found at $config_path — bind it by hand."
  read -r -p "Press enter to continue..." _
  exit 0
fi

title=$("$herdr_bin" plugin list --json | jq -r --arg id "$id" --arg aid "$action_id" '
  .result.plugins[] | select(.plugin_id == $id) | .actions[] | select(.id == $aid) | .title
')

echo "Binding ${id}.${action_id} (${title:-no title})"
read -r -p "Key (e.g. prefix+alt+m): " key
if [[ -z "$key" ]]; then
  echo "Cancelled."
  read -r -p "Press enter to continue..." _
  exit 0
fi

block=$(cat <<TOML

[[keys.command]]
key = "$key"
type = "plugin_action"
command = "${id}.${action_id}"
description = "${title:-$action_id}"
TOML
)

echo "Will append to $config_path:"
echo "$block"
read -r -p "Confirm? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Cancelled."
  read -r -p "Press enter to continue..." _
  exit 0
fi

printf '%s\n' "$block" >> "$config_path"

if "$herdr_bin" server reload-config >/dev/null 2>&1; then
  echo "Bound $key -> ${id}.${action_id} and reloaded config."
else
  echo "Bound $key -> ${id}.${action_id}. Reload config manually if it doesn't take effect."
fi

read -r -p "Press enter to continue..." _
