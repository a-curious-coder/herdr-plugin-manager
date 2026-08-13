#!/bin/bash
# Plugins: shared temp-file locations and small helpers used across nearly
# every script here. Sourced (never executed).
CACHE_FILE="${TMPDIR:-/tmp}/herdr-plugins-updates-cache.json"
UPDATING_DIR="${TMPDIR:-/tmp}/herdr-plugins-updating"
CATALOG_CACHE_FILE="${TMPDIR:-/tmp}/herdr-plugins-catalog-cache.json"
MODE_FILE="${TMPDIR:-/tmp}/herdr-plugins-mode"
SORT_FILE="${TMPDIR:-/tmp}/herdr-plugins-catalog-sort"
HELP_FILE="${TMPDIR:-/tmp}/herdr-plugins-help-shown"

file_value() { # $1 file $2 default — read a state file, or its default if unset
  [[ -f "$1" ]] && cat "$1" || echo "$2"
}

flip_value() { # $1 file $2 value-a $3 value-b — toggles a state file between two fixed values
  if [[ "$(file_value "$1" "$2")" == "$2" ]]; then
    echo "$3" > "$1"
  else
    echo "$2" > "$1"
  fi
}

current_mode() { file_value "$MODE_FILE" "installed"; }   # one pane, two views
help_shown() { [[ "$(file_value "$HELP_FILE" "off")" == "on" ]]; }

pause() { read -r -p "Press enter to continue..." _; }

plugin_json_by_id() { # $1 plugin_id -> installed plugin's full JSON, or empty if not installed
  local herdr_bin="${HERDR_BIN_PATH:-herdr}"
  "$herdr_bin" plugin list --json | jq -c --arg id "$1" '
    .result.plugins[] | select(.plugin_id == $id)
  '
}
