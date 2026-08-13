#!/bin/bash
# Plugins: kicks off a background update for one plugin without blocking the
# fzf UI. Touches a marker file synchronously — so the very next reload
# (fired right after this by fzf's execute-silent+reload bind) already shows
# the spinner for this row — then backgrounds the real update and returns
# immediately.
set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

id="${1:?usage: start-update.sh <plugin_id>}"

mkdir -p "$UPDATING_DIR"
touch "$UPDATING_DIR/$id"

nohup bash "$script_dir/update.sh" "$id" >/dev/null 2>&1 &
disown
