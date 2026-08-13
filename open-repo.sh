#!/bin/bash
# Plugins: opens the highlighted plugin's GitHub repo in the browser. Looks
# up owner/repo by mode — installed view via plugin_json_by_id (source.kind
# == "github"), browse view via the cached catalog (same self-lookup
# pattern install-from-catalog.sh uses). Local plugins have no repo page, so
# this is a silent no-op for them rather than an error.
set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"
id="${1:?usage: open-repo.sh <plugin_id>}"

full_name=""
if [[ "$(current_mode)" == "catalog" ]]; then
  [[ -f "$CATALOG_CACHE_FILE" ]] && full_name=$(jq -r --arg id "$id" '
    [.plugins[] as $repo | $repo.manifests[] as $m | select($m.id == $id) | $repo.fullName] | .[0] // empty
  ' "$CATALOG_CACHE_FILE")
else
  full_name=$(plugin_json_by_id "$id" | jq -r '
    if .source.kind == "github" then "\(.source.owner)/\(.source.repo)" else empty end
  ')
fi

[[ -n "$full_name" ]] || exit 0

url="https://github.com/$full_name"
if command -v open >/dev/null 2>&1; then
  open "$url"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$url"
fi
