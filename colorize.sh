#!/bin/bash
# Plugins: reads row-builder.sh's TSV from stdin, renders one colored display
# line per plugin. Shared by every reload path so they all draw identically.
set -euo pipefail

# Braille spinner, one frame per whole second — coarse, but this runs on
# every(0.5s) reload so it still visibly moves while a state="s" row exists.
frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧)
frame="${frames[$(( $(date +%s) % ${#frames[@]} ))]}"

awk -F'\t' -v spin="$frame" '
function bullet(s) {
  if (s == "s") return "\033[36m" spin "\033[0m"
  if (s == "d") return "\033[90m●\033[0m"
  if (s == "u") return "\033[33m●\033[0m"
  return "\033[32m●\033[0m"
}
{ printf "%s  %-28s  %-24s  %s\n", bullet($2), $3, $4, $5 }
'
