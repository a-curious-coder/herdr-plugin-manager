#!/bin/bash
# Plugins: updates a github-sourced plugin to the latest commit on its
# default branch and applies it to the running server immediately — same as
# enable/disable, confirmed no `herdr server reload-config` needed.
#
# Meant to be run backgrounded via start-update.sh, which already touched
# UPDATING_DIR/$id before this started — always clean that marker up on
# exit (success, failure, or interruption) so a row doesn't spin forever.
# On success, also flips this plugin's entry in the cached update-check
# result to false, so the cheap tick-render (assemble-rows.sh) shows it as
# current immediately instead of waiting for the next full network refresh.
#
# ponytail: doesn't touch the pinned refs in
# dotfiles/herdr/scripts/install-herdr-plugins.sh — that file is a deliberate,
# manually-curated replay list (per its own header comment), so bumping it
# here would be a surprising side effect of a keypress. Update it by hand
# after confirming the plugin works.
set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

id="${1:?usage: update.sh <plugin_id>}"
herdr_bin="${HERDR_BIN_PATH:-herdr}"

trap 'rm -f "$UPDATING_DIR/$id"' EXIT

plugin=$(plugin_json_by_id "$id")
# Not installed (e.g. 'u' pressed on a browse-mode row) — nothing to update.
[[ -n "$plugin" ]] || exit 0
source_json=$(jq -c '.source' <<<"$plugin")

kind=$(jq -r '.kind // empty' <<<"$source_json")
[[ "$kind" == "github" ]] || exit 0

owner=$(jq -r '.owner' <<<"$source_json")
repo=$(jq -r '.repo' <<<"$source_json")

if "$herdr_bin" plugin install "$owner/$repo" -y >/dev/null 2>&1; then
  [[ -f "$CACHE_FILE" ]] || printf '{}' > "$CACHE_FILE"
  updated=$(jq --arg id "$id" '.[$id] = false' "$CACHE_FILE")
  printf '%s' "$updated" > "$CACHE_FILE"
fi
