#!/bin/bash
# Plugins: one pane, two views. `tab` flips between installed (manage what
# you have — toggle/update) and browse (discover from herdr.dev's public
# registry and install). MODE_FILE tracks which view is active;
# unified-render.sh, enter-dispatcher.sh, and preview-dispatcher.sh all read
# it so one set of key bindings works across both.
#
# Bare letters (q/u/i/s/r/d/a/z/o/?) are commands, not search — --no-input keeps
# typing inert until '/' is pressed (iris's list-skills.sh does the same).
# '/' unbind()s all of them so they fall through to fzf's real default
# (insert-character) and type normally into the query; 'esc' rebind()s them
# all back and returns to the full list (clear-query, then hide-input —
# disable-search was tried first and freezes the match set instead of
# resetting it, so it's deliberately left out).
#
# rebind(key) only works to undo that *same* key's unbind — confirmed
# empirically with a tmux-driven fzf test: calling rebind on a key that was
# never explicitly unbind()ed does nothing (its original --bind-flag action
# just keeps firing). So the pairing has to be exact: every key unbound on
# '/' must be rebound on 'esc'.
#
# '?' is a genuine help overlay: it flips HELP_FILE and forces the preview
# to redraw via refresh-preview, showing help.sh's full legend in place of
# the per-row detail until toggled off again.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/paths.sh"

echo "installed" > "$MODE_FILE"   # always start in installed view
echo "stars" > "$SORT_FILE"       # always start browse view sorted by stars
echo "off" > "$HELP_FILE"         # always start with the per-row preview, not help

rows=$(bash "$script_dir/unified-render.sh")

if [[ -z "$rows" ]]; then
  echo "No plugins installed."
  read -r -p "Press enter to close..." _
  exit 0
fi

if command -v fzf >/dev/null 2>&1; then
  printf '%s\n' "$rows" \
    | fzf --ansi \
          --header="$(bash "$script_dir/mode-header.sh")" \
          --prompt="/" --no-input --no-sort --exact --layout=reverse-list \
          --bind='q:abort' \
          --bind='/:show-input+enable-search+clear-query+unbind(q)+unbind(u)+unbind(i)+unbind(s)+unbind(r)+unbind(d)+unbind(a)+unbind(z)+unbind(o)+unbind(?)' \
          --bind='esc:clear-query+hide-input+rebind(q)+rebind(u)+rebind(i)+rebind(s)+rebind(r)+rebind(d)+rebind(a)+rebind(z)+rebind(o)+rebind(?)' \
          --bind="enter:execute(bash '$script_dir/enter-dispatcher.sh' {2})+reload(bash '$script_dir/unified-render.sh')" \
          --bind="u:execute-silent(bash '$script_dir/start-update.sh' {2})+reload(bash '$script_dir/unified-render.sh')" \
          --bind="i:execute(bash '$script_dir/install.sh')+reload(bash '$script_dir/unified-render.sh')" \
          --bind="d:execute(bash '$script_dir/uninstall.sh' {2})+reload(bash '$script_dir/unified-render.sh')" \
          --bind="a:execute(bash '$script_dir/actions-picker.sh' {2})+reload(bash '$script_dir/unified-render.sh')" \
          --bind="s:execute-silent(bash '$script_dir/cycle-sort.sh')+reload(bash '$script_dir/unified-render.sh')+transform-header(bash '$script_dir/mode-header.sh')" \
          --bind="r:execute-silent(bash '$script_dir/refresh.sh')+reload(bash '$script_dir/unified-render.sh')" \
          --bind="z:change-preview-window(right,90%|right,50%)" \
          --bind="o:execute-silent(bash '$script_dir/open-repo.sh' {2})" \
          --bind="?:execute-silent(bash '$script_dir/help-toggle.sh')+refresh-preview" \
          --bind="tab:execute-silent(bash '$script_dir/toggle-mode.sh')+reload(bash '$script_dir/unified-render.sh')+transform-header(bash '$script_dir/mode-header.sh')+first" \
          --bind="every(0.5):reload(bash '$script_dir/unified-render.sh')" \
          --preview="bash '$script_dir/preview-dispatcher.sh' {2}" \
          --preview-window='right:50%' \
    >/dev/null || true
else
  printf '%s\n' "$rows"
  read -r -p "Press enter to close..." _
fi
