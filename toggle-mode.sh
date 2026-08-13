#!/bin/bash
# Plugins: flips the pane between installed and browse (catalog) view.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

flip_value "$MODE_FILE" installed catalog
