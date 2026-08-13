#!/bin/bash
# Plugins: shared temp-file locations for the update-check cache and
# in-flight update markers. Sourced (never executed) by build-rows.sh,
# render.sh, update.sh, and start-update.sh so they agree on where to look.
CACHE_FILE="${TMPDIR:-/tmp}/herdr-plugins-updates-cache.json"
UPDATING_DIR="${TMPDIR:-/tmp}/herdr-plugins-updating"
CATALOG_CACHE_FILE="${TMPDIR:-/tmp}/herdr-plugins-catalog-cache.json"
MODE_FILE="${TMPDIR:-/tmp}/herdr-plugins-mode"
SORT_FILE="${TMPDIR:-/tmp}/herdr-plugins-catalog-sort"
HELP_FILE="${TMPDIR:-/tmp}/herdr-plugins-help-shown"

current_mode() { # one pane, two views — installed (default) or catalog
  [[ -f "$MODE_FILE" ]] && cat "$MODE_FILE" || echo "installed"
}
