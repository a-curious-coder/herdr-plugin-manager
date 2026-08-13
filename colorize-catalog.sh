#!/bin/bash
# Plugins: reads catalog-rows.sh's TSV from stdin, renders one tab-delimited
# display line per catalog entry. plugin_id is field 2 but never shown —
# list-plugins.sh's --with-nth hides it from view while {2} in its
# --bind/--preview commands still resolves to it, same as colorize.sh.
# owner/repo isn't shown either — name + description tells you more about
# whether you want a plugin than its GitHub path does.
set -euo pipefail

awk -F'\t' '
function marker(inst) {
  if (inst == "1") return "\033[32m✓\033[0m"
  return "\033[90m·\033[0m"
}
{
  desc = $4
  if (length(desc) > 58) desc = substr(desc, 1, 55) "..."
  printf "%s\t%s\t%-24s\t★%-6s\t%-10s\t%s\n", marker($1), $2, $3, $5, substr($6, 1, 10), desc
}
'
