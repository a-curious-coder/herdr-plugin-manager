#!/bin/bash
# Plugins: preview pane for the row under the cursor. Source is
# `herdr plugin list --json` (not `--format json`, which plugin list
# rejects). Two things aren't in that payload: the config dir (needs
# `herdr plugin config-dir <id>`), and resolved_commit only exists when
# source.kind == "github" — local sources carry just "kind".
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"
id="${1:?usage: preview.sh <plugin_id>}"
herdr_bin="${HERDR_BIN_PATH:-herdr}"

plugin=$(plugin_json_by_id "$id")
[[ -n "$plugin" ]] || { echo "no such plugin: $id"; exit 0; }

config_dir=$("$herdr_bin" plugin config-dir "$id" 2>/dev/null || echo "n/a")

name=$(jq -r '.name' <<<"$plugin")
description=$(jq -r '.description // "no description"' <<<"$plugin")

echo "$name  ($id)"
# fzf's --preview-window wrap is a character wrap, not a word wrap, and cuts
# words in half — wrap ourselves via `fmt` at the preview pane's actual
# width instead (same fix as iris's preview.sh).
printf '%s' "$description" | fmt -w "${FZF_PREVIEW_COLUMNS:-60}"
echo

jq -r --arg config_dir "$config_dir" '
  def source_line:
    if .source.kind == "github" then
      "source: github:\(.source.owner)/\(.source.repo)@\(.source.resolved_commit[0:12])"
    else
      "source: \(.source.kind)"
    end;

  "version: \(.version)  ·  min herdr: \(.min_herdr_version)",
  source_line,
  "root: \(.plugin_root)",
  "config: \($config_dir)",
  "",
  (if (.actions // []) | length > 0 then
    "Actions:", (.actions[] | "  \(.id): \(.title)  [\(.contexts // ["global"] | join(","))]"), ""
  else empty end),
  (if (.events // []) | length > 0 then
    "Events:", (.events[] | "  \(.on)"), ""
  else empty end),
  (if (.panes // []) | length > 0 then
    "Panes:", (.panes[] | "  \(.id): \(.title)  (\(.placement // "n/a"))")
  else empty end)
' <<<"$plugin"
