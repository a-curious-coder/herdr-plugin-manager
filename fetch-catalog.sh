#!/bin/bash
# Plugins: fetches herdr.dev's public plugin registry (GitHub topic:herdr-plugin,
# aggregated server-side into a flat index) and caches it. A plain static
# JSON asset behind a CDN — no auth or browser-mimicking headers needed.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

curl -sf --compressed 'https://assets.herdr.dev/plugins/index.json' -o "$CATALOG_CACHE_FILE"
