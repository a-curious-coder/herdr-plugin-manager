#!/bin/bash
# Plugins: advances the catalog sort order one step (stars -> updated ->
# newest -> name -> stars ...). Only meaningful in browse view — a no-op in
# installed view.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

[[ "$(current_mode)" == "catalog" ]] || exit 0

current=$(file_value "$SORT_FILE" "stars")
case "$current" in
  stars)   next=updated ;;
  updated) next=newest ;;
  newest)  next=name ;;
  *)       next=stars ;;
esac

echo "$next" > "$SORT_FILE"
