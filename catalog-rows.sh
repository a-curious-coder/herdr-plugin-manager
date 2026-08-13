#!/bin/bash
# Plugins: flattens the cached registry into one row per installable plugin
# (a repo can declare more than one manifest — multiple plugins in one repo —
# so rows are per-manifest, not per-repo), sorted by the requested key.
# Cross-references currently-installed plugin_ids so already-installed rows
# can be marked instead of offered again as if new.
#
# owner/repo isn't in the row — it's a lookup detail (install-from-catalog.sh
# and preview-catalog.sh both re-derive it from the cache by plugin_id when
# they actually need it), not something worth a column: the name + a real
# description tells you more about whether you want a plugin than its
# GitHub path does.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

sort_mode="${1:-stars}"   # stars | updated | newest | name
herdr_bin="${HERDR_BIN_PATH:-herdr}"

[[ -f "$CATALOG_CACHE_FILE" ]] || { echo "catalog-rows: no cached catalog — run fetch-catalog.sh first" >&2; exit 1; }

installed_ids=$("$herdr_bin" plugin list --json | jq -c '[.result.plugins[].plugin_id]')

jq -r --argjson installed "$installed_ids" --arg mode "$sort_mode" '
  def keyfn:
    if $mode == "updated" then .updated_at
    elif $mode == "newest" then .created_at
    elif $mode == "name" then (.name | ascii_downcase)
    else .stars end;

  [ .plugins[] as $repo
    | $repo.manifests[] as $m
    | {
        plugin_id: $m.id,
        name: $m.name,
        description: (($m.description // $repo.description // "no description") | gsub("[\t\n\r]"; " ")),
        stars: $repo.stars,
        updated_at: $repo.pushedAt,
        created_at: $repo.createdAt,
        installed: (([$m.id] | inside($installed)))
      }
  ]
  | sort_by(keyfn)
  | (if $mode == "name" then . else reverse end)
  | .[]
  | [
      (if .installed then "1" else "0" end),
      .plugin_id,
      .name,
      .description,
      (.stars | tostring),
      .updated_at
    ]
  | @tsv
' "$CATALOG_CACHE_FILE"
