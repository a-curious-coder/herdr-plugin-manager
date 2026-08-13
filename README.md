# herdr-plugin-manager

<p align="center">
  <a href="https://github.com/a-curious-coder/herdr-plugin-manager/releases/latest"><img src="https://shieldcn.dev/github/release/a-curious-coder/herdr-plugin-manager.svg?variant=secondary" alt="release" /></a>
  <a href="https://github.com/a-curious-coder/herdr-plugin-manager/stargazers"><img src="https://shieldcn.dev/github/stars/a-curious-coder/herdr-plugin-manager.svg?variant=secondary" alt="GitHub stars" /></a>
  <a href="https://github.com/a-curious-coder/herdr-plugin-manager/commits/main"><img src="https://shieldcn.dev/github/last-commit/a-curious-coder/herdr-plugin-manager.svg?variant=secondary" alt="last commit" /></a>
  <a href="./LICENSE"><img src="https://shieldcn.dev/github/license/a-curious-coder/herdr-plugin-manager.svg?variant=secondary" alt="license" /></a>
</p>

A floating-pane TUI to manage [herdr](https://herdr.dev) plugins from inside
herdr: list what is installed, toggle enabled/disabled, inspect a plugin,
install/uninstall, update, run or bind its actions, and browse the public
plugin registry to discover new ones — all without leaving your terminal.

The repo is `herdr-plugin-manager` so it is findable by phrase on the
`herdr-plugin` topic. The plugin itself is `cmc.plugins`, titled "Plugins" —
that string appears in the command palette and keybind help, where "Manager"
adds nothing and the convention is plain nouns (Ports, Compose, Git Status).

herdr has no plugin browser of its own. `herdr plugin list|enable|disable|
install|uninstall` are CLI-only, and there's no way to discover new plugins
short of browsing GitHub by hand — so managing plugins otherwise means
dropping out of herdr to a shell.

## Install

```sh
herdr plugin install a-curious-coder/herdr-plugin-manager -y
```

Bind it to a key in your `config.toml`:

```toml
[[keys.command]]
key = "prefix+m"
type = "plugin_action"
command = "cmc.plugins.open"
description = "manage plugins"
```

## Usage

One pane, two views — `tab` flips between **Installed** (what you have) and
**Browse** (herdr.dev's public registry, backed by GitHub's `herdr-plugin`
topic). Search is hidden until you press `/`; every other key is a
single-letter shortcut, `esc` cancels a search back to the full list, `q`
quits. Press `?` any time for the full legend.

| Key | Installed view | Browse view |
|---|---|---|
| `enter` | toggle enabled/disabled | confirm + install |
| `u` | update to latest commit (async, spinner) | — |
| `i` | install a new plugin by typing `owner/repo[/subdir]` | — |
| `s` | — | cycle sort: stars → updated → newest → name |
| `d` | uninstall (typed confirm) | uninstall (typed confirm) |
| `a` | list the plugin's own actions — run one now, or bind it to a key | same |
| `r` | refresh (re-check for updates) | re-fetch the registry |
| `z` | zoom the preview pane (50% ↔ 90%) | same |
| `?` | toggle full keybinding help | same |
| `tab` | switch to Browse | switch to Installed |

## Stack

Bash + `fzf`, rendered in a `placement = "popup"` pane — the same shape as
`cmc.iris`. Reasons:

- `herdr plugin list --json` already returns everything needed. The work is
  rendering rows and wiring keys to `herdr plugin enable|disable|install|
  uninstall`, which is what fzf's `--bind`/`reload`/`execute` already do.
- The public registry (`assets.herdr.dev/plugins/index.json`) is a plain
  static JSON asset — no auth, no special headers, just `curl`.
- No build step, no runtime beyond `fzf`/`jq`, both already common in a herdr
  setup (`jt.command-palette` already depends on `fzf`).
- `placement = "popup"` is herdr's own floating pane. Nothing to implement.

<!-- ponytail: fzf is the whole TUI. Move to Go + Bubble Tea only if the list
     needs multi-column layout, inline editing, or async refresh that fzf's
     --bind reload cannot express. -->

## Why not

- Extending `jt.command-palette` — it runs plugin *actions*, and has no
  concept of plugin lifecycle state or a registry to browse.
- `herdr-plus` — projects and quick actions, not plugin management.

## Known herdr behaviour this handles

- `herdr plugin disable <id>` does not kill daemons the plugin already
  spawned. They keep running until killed or until herdr restarts. Disabling
  from this pane reaps the plugin's processes too (matched by `plugin_root`
  in their command line), only once the plugin is actually confirmed
  disabled — never on a still-enabled plugin.
- `herdr plugin enable|disable|install` all take effect immediately; no
  `herdr server reload-config` needed. Verified empirically, not assumed.
- fzf's `rebind(...)` only undoes a matching `unbind(...)` — it does *not*
  revert a key bound via a `--bind` flag back to "type normally". Bare-letter
  shortcuts are `unbind()`ed on `/` (enter search) and `rebind()`ed on `esc`
  (cancel search), verified with a tmux-driven fzf test after the first
  attempt (using `rebind` alone) silently did nothing.

## Issues

Tracked with [seeds](https://github.com/jayminwest/seeds): `sd ready`.
