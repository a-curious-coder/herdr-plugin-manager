#!/bin/bash
# Plugins: pure row-building logic, used by assemble-rows.sh (both the cheap
# and --network paths) so they produce identical TSV shape. No top-level
# side effects — safe to source anywhere.
#
# Row fields: sort_key state plugin_id name source_kind. state is one of
# s(pinner, update in flight) / d(isabled) / u(pdate available) / e(nabled,
# current). Sorted by what needs attention first.

plugin_rows() { # $1 json envelope  $2 updates map {plugin_id: bool}  $3 updating ids json array
  jq -r --argjson updates "$2" --argjson updating "$3" '
    .result.plugins
    | map(. + {
        update_available: ($updates[.plugin_id] // false),
        is_updating: ((.plugin_id as $pid | $updating | index($pid)) != null)
      })
    | sort_by(
        if .is_updating then 0
        elif (.enabled | not) then 1
        elif .update_available then 2
        else 3 end
      )
    | .[]
    | [
        (if .is_updating then "0" elif (.enabled | not) then "1" elif .update_available then "2" else "3" end),
        (if .is_updating then "s" elif (.enabled | not) then "d" elif .update_available then "u" else "e" end),
        .plugin_id,
        .name,
        .source.kind
      ]
    | @tsv
  ' <<<"$1"
}

updating_ids_json() { # $1 updating marker dir
  local dir="$1" files=() ids=()
  if [[ -d "$dir" ]]; then
    shopt -s nullglob
    files=("$dir"/*)
    shopt -u nullglob
  fi
  if [[ ${#files[@]} -eq 0 ]]; then
    printf '[]'
    return
  fi
  for f in "${files[@]}"; do ids+=("$(basename "$f")"); done
  printf '%s\n' "${ids[@]}" | jq -c -R -s 'split("\n") | map(select(length > 0))'
}
