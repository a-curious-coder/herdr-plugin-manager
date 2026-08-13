#!/bin/bash
# Plugins: for each github-sourced plugin, compares its pinned resolved_commit
# against the remote HEAD. Local plugins have no upstream, so they're not
# checked. Runs one `git ls-remote` per plugin in parallel with a timeout so
# a slow/offline network doesn't hang the pane open.
#
# ponytail: no caching — every pane open re-checks all plugins over the
# network. Add a TTL cache (e.g. ~/.cache/herdr-plugins/updates.json) if
# opening the pane starts to feel slow with many plugins installed.
set -uo pipefail

json="$1"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/plugins-updates.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT

check_one() { # $1 plugin_id $2 owner $3 repo $4 pinned_commit
  local id="$1" owner="$2" repo="$3" pinned="$4" remote available
  remote=$(timeout 3 git ls-remote "https://github.com/$owner/$repo" HEAD 2>/dev/null | awk '{print $1}')
  available=0
  [[ -n "$remote" && "$remote" != "$pinned" ]] && available=1
  printf '%s\t%s\n' "$id" "$available" > "$tmp_dir/$id.tsv"
}

while IFS=$'\t' read -r id owner repo pinned; do
  [[ -z "$id" ]] && continue
  check_one "$id" "$owner" "$repo" "$pinned" &
done < <(jq -r '
  .result.plugins[]
  | select(.source.kind == "github")
  | [.plugin_id, .source.owner, .source.repo, .source.resolved_commit]
  | @tsv
' <<<"$json")

wait
cat "$tmp_dir"/*.tsv 2>/dev/null || true
