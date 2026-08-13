#!/bin/bash
# Plugins: the shared "run herdr plugin install, report, summarize" core for
# install.sh (typed spec) and install-from-catalog.sh (looked-up spec) —
# they only differ in how they get to a spec + whether they already know
# the resulting plugin_id, so everything after that lives here once.
set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"
spec="${1:?usage: do-install.sh <owner/repo[/subdir]> [known_plugin_id]}"
known_id="${2:-}"
herdr_bin="${HERDR_BIN_PATH:-herdr}"

output=$("$herdr_bin" plugin install "$spec" -y 2>&1)
status=$?
echo "$output"
echo

if [[ $status -eq 0 ]]; then
  commit=$(awk '/^ *commit:/ {print $2; exit}' <<<"$output")
  id="$known_id"
  [[ -n "$id" ]] || id=$(awk '/^ *id:/ {print $2; exit}' <<<"$output")
  echo "Installed ${spec}. Resolved commit: ${commit:-unknown}"
  [[ -n "$id" ]] && bash "$script_dir/post-install-summary.sh" "$id"
else
  echo "Install failed (exit $status). See output above."
fi
