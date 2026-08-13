#!/bin/bash
# Plugins: after a successful install, print how to configure and use the
# plugin — actions, panes, config dir, and a link to the repo's own README.
# "Installed $spec" alone is a dead end: there's no built-in way to discover
# what a plugin does or where its settings live short of reading its repo.
set -euo pipefail

id="${1:?usage: post-install-summary.sh <plugin_id>}"
herdr_bin="${HERDR_BIN_PATH:-herdr}"

plugin=$("$herdr_bin" plugin list --json | jq -c --arg id "$id" '
  .result.plugins[] | select(.plugin_id == $id)
')
[[ -n "$plugin" ]] || exit 0

config_dir=$("$herdr_bin" plugin config-dir "$id" 2>/dev/null || echo "n/a")

echo
echo "--- Set up & use $id ---"

jq -r '
  if .source.kind == "github" then
    "README: https://github.com/\(.source.owner)/\(.source.repo)#readme"
  else empty end
' <<<"$plugin"

echo "Config dir: $config_dir"

jq -r '
  (.actions // []) as $a
  | if ($a | length) > 0 then
      "",
      "Actions (no keybinding yet — run via jt.command-palette, or bind one in dotfiles/herdr/.config/herdr/config.toml):",
      ($a[] | "  \(.id): \(.title)" + (if .description then " — \(.description)" else "" end))
    else empty end
' <<<"$plugin"

jq -r '
  (.panes // []) as $p
  | if ($p | length) > 0 then
      "",
      "Panes (opened by one of the actions above, not directly):",
      ($p[] | "  \(.id): \(.title)")
    else empty end
' <<<"$plugin"

echo
