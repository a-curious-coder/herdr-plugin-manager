#!/bin/bash
# Plugins: reads catalog-rows.sh's TSV from stdin, renders one display line
# per catalog entry. plugin_id stays token 2 — same position/meaning as
# colorize.sh's installed rows — so enter-dispatcher.sh and
# preview-dispatcher.sh work off one universal {2} regardless of which mode
# the pane is currently in.
set -euo pipefail

awk -F'\t' '
function marker(inst) {
  if (inst == "1") return "\033[32m✓\033[0m"
  return "\033[90m·\033[0m"
}
{
  ref = $4
  if ($5 != "") ref = ref "/" $5
  printf "%s  %-32s  %-24s  %-32s  ★%-6s  updated %s\n", marker($1), $2, $3, ref, $6, substr($7, 1, 10)
}
'
