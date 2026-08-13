#!/bin/bash
# Plugins: the full keybinding legend, shown in the preview pane while
# HELP_FILE is set (toggled by '?'). One line per key, plain description —
# the header already gives the compact version, this is the expanded one.
set -euo pipefail

cat <<'EOF'
Keybindings

/     search — hidden until pressed; bare letters are shortcuts until then
esc   cancel search, back to the full list (does not close the pane)
q     quit — closes the pane (works once you've backed out of search)
tab   switch between Installed and Browse registry views
enter Installed: toggle enable/disabled  ·  Browse: confirm + install
r     refresh — re-check for updates (Installed) / re-fetch registry (Browse)
d     uninstall the highlighted plugin — asks you to type its id to confirm
a     list the highlighted plugin's own actions — enter runs one now,
      ctrl-o binds it to a key in config.toml (shown + confirmed first)
z     zoom the preview pane between 50% and 90% width
o     open the highlighted plugin's GitHub repo in your browser
      (no-op for local plugins — they have no repo page)
shift-up / shift-down   scroll the preview pane (built into fzf, no bind needed)
?     toggle this help / the per-row preview

Installed view only
  u   update the highlighted plugin (github-sourced only)
  i   install a new plugin by typing owner/repo[/subdir]

Browse view only
  s   cycle sort: stars -> updated -> newest -> name
EOF
