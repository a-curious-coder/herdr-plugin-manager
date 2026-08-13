#!/bin/bash
# Plugins: `herdr plugin disable` doesn't kill daemons the plugin already
# spawned (confirmed on 0.8.0 — three claude-auto-retry monitors survived a
# disable). Called right after disabling, this finds and kills any process
# whose argv contains the plugin's root path, then toasts how many it found.
#
# ponytail: matches on plugin_root as a plain substring via `pgrep -f` —
# no cgroup/process-group tracking, so a daemon that `exec`s into something
# with a different argv (no plugin_root string left) would be missed.
# Upgrade to tracking real PIDs/PGIDs at spawn time if that turns out to
# matter for a specific plugin.
set -uo pipefail

id="${1:?usage: reap.sh <plugin_id>}"
herdr_bin="${HERDR_BIN_PATH:-herdr}"

plugin=$("$herdr_bin" plugin list --json | jq -c --arg id "$id" '
  .result.plugins[] | select(.plugin_id == $id)
')
[[ -n "$plugin" ]] || exit 0

# Safety guard: only ever kill a plugin's processes once it's actually
# disabled. Without this, running reap.sh against a still-enabled plugin
# (a bug in the caller, a manual invocation, anything) kills its legitimate
# running daemons too — confirmed the hard way against real claude-auto-retry
# monitors during development.
enabled=$(jq -r '.enabled' <<<"$plugin")
if [[ "$enabled" != "false" ]]; then
  echo "reap: refusing — $id is still enabled" >&2
  exit 1
fi

plugin_root=$(jq -r '.plugin_root // empty' <<<"$plugin")
[[ -n "$plugin_root" ]] || exit 0

pids=$(pgrep -f -- "$plugin_root" 2>/dev/null || true)
[[ -n "$pids" ]] || exit 0

count=$(wc -l <<<"$pids" | tr -d ' ')
kill $pids 2>/dev/null || true
sleep 0.3
kill -9 $pids 2>/dev/null || true

"$herdr_bin" notification show "Plugins" \
  --body "Disabled $id: reaped $count leftover process(es)" \
  >/dev/null 2>&1 || true
