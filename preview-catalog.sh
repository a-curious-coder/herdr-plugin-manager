#!/bin/bash
# Plugins: preview pane for a browse-mode row, looked up from the cached
# catalog by plugin_id — same join key preview.sh (installed mode) uses.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

id="${1:?usage: preview-catalog.sh <plugin_id>}"

[[ -f "$CATALOG_CACHE_FILE" ]] || { echo "no catalog cached"; exit 0; }

entry=$(jq -c --arg id "$id" '
  [ .plugins[] as $repo
    | $repo.manifests[] as $m
    | select($m.id == $id)
    | {
        name: $m.name,
        description: ($m.description // $repo.description // "no description"),
        full_name: $repo.fullName,
        subdir: ($m.path | if test("/") then sub("/[^/]+$"; "") else "" end),
        stars: $repo.stars,
        forks: $repo.forks,
        language: $repo.language,
        updated_at: $repo.pushedAt,
        created_at: $repo.createdAt,
        version: $m.version,
        min_herdr: $m.minHerdrVersion,
        url: $repo.url
      }
  ] | .[0]
' "$CATALOG_CACHE_FILE")

if [[ "$entry" == "null" || -z "$entry" ]]; then
  echo "no such catalog entry: $id"
  exit 0
fi

name=$(jq -r '.name' <<<"$entry")
description=$(jq -r '.description' <<<"$entry")
spec=$(jq -r 'if .subdir != "" then "\(.full_name)/\(.subdir)" else .full_name end' <<<"$entry")

echo "$name  ($spec)"
printf '%s' "$description" | fmt -w "${FZF_PREVIEW_COLUMNS:-60}"
echo

jq -r '
  "stars: \(.stars)  ·  forks: \(.forks)  ·  language: \(.language // "n/a")",
  "version: \(.version)  ·  min herdr: \(.min_herdr)",
  "updated: \(.updated_at)  ·  created: \(.created_at)",
  "url: \(.url)"
' <<<"$entry"
