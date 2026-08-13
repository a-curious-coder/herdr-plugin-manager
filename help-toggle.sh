#!/bin/bash
# Plugins: flips whether the preview pane shows the full keybinding legend
# (help.sh) or the normal per-row detail — bound to '?', paired with fzf's
# refresh-preview action to force the preview to redraw immediately.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

flip_value "$HELP_FILE" off on
