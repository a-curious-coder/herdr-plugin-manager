#!/bin/bash
# Plugins: prompts for an owner/repo[/subdir] spec and installs it. Bound
# via fzf's execute() (not execute-silent) — install needs a real prompt,
# and execute() suspends fzf and hands over the terminal, then resumes it
# once this exits.
set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
herdr_bin="${HERDR_BIN_PATH:-herdr}"

read -r -p "Install plugin (owner/repo[/subdir]): " spec
if [[ -z "$spec" ]]; then
  echo "Cancelled."
  read -r -p "Press enter to continue..." _
  exit 0
fi

output=$("$herdr_bin" plugin install "$spec" -y 2>&1)
status=$?
echo "$output"
echo

if [[ $status -eq 0 ]]; then
  commit=$(awk '/^ *commit:/ {print $2; exit}' <<<"$output")
  id=$(awk '/^ *id:/ {print $2; exit}' <<<"$output")
  echo "Installed ${spec}. Resolved commit: ${commit:-unknown}"
  [[ -n "$id" ]] && bash "$script_dir/post-install-summary.sh" "$id"
else
  echo "Install failed (exit $status). See output above."
fi

read -r -p "Press enter to continue..." _
