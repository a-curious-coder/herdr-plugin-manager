#!/bin/bash
# Plugins: flips whether the preview pane shows the full keybinding legend
# (help.sh) or the normal per-row detail — bound to '?', paired with fzf's
# refresh-preview action to force the preview to redraw immediately.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

if [[ -f "$HELP_FILE" ]]; then
  rm -f "$HELP_FILE"
else
  touch "$HELP_FILE"
fi
