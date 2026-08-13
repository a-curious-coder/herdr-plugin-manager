#!/bin/bash
# Plugins: advances the catalog sort order one step (stars -> updated ->
# newest -> name -> stars ...). Only meaningful in browse view — a no-op in
# installed view, same guard reasoning sort-select.sh had.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

[[ "$(current_mode)" == "catalog" ]] || exit 0

order=(stars updated newest name)
current=$([[ -f "$SORT_FILE" ]] && cat "$SORT_FILE" || echo "stars")

next="stars"
for i in "${!order[@]}"; do
  if [[ "${order[$i]}" == "$current" ]]; then
    next="${order[$(( (i + 1) % ${#order[@]} ))]}"
    break
  fi
done

echo "$next" > "$SORT_FILE"
