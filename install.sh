#!/bin/bash
# Plugins: prompts for an owner/repo[/subdir] spec, then delegates the
# actual install + report to do-install.sh (shared with
# install-from-catalog.sh, which does its own catalog lookup + confirm
# instead of a free-text prompt). Bound via fzf's execute() (not
# execute-silent) — needs a real prompt, and execute() suspends fzf and
# hands over the terminal, then resumes it once this exits.
set -uo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

read -r -p "Install plugin (owner/repo[/subdir]): " spec
if [[ -z "$spec" ]]; then
  echo "Cancelled."
  pause
  exit 0
fi

bash "$script_dir/do-install.sh" "$spec"
pause
