#!/bin/bash
# Runs as a herdr [[build]] step during `herdr plugin install`, before the
# plugin is registered. Installs fzf/jq if missing so the user never has to
# do it by hand first. Idempotent: a no-op if both are already present.
set -euo pipefail

missing=()
command -v fzf >/dev/null 2>&1 || missing+=("fzf")
command -v jq >/dev/null 2>&1 || missing+=("jq")

if [[ ${#missing[@]} -eq 0 ]]; then
  exit 0
fi

echo "Plugins: installing missing dependencies: ${missing[*]}"

if command -v brew >/dev/null 2>&1; then
  brew install "${missing[@]}"
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y "${missing[@]}"
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y "${missing[@]}"
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --noconfirm "${missing[@]}"
else
  echo "Plugins: no known package manager (brew/apt/dnf/pacman) found." >&2
  echo "Install manually first: ${missing[*]}" >&2
  exit 1
fi
