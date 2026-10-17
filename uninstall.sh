#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

# Only these; the desktop is swarch's to remove (~/swarch/uninstall.sh)
stow --adopt -v -t "$HOME/.config" -D config
stow --adopt -v -t "$HOME" -D home

# Reload shell once uninstalled
echo "[+] Reloading shell..."
exec $SHELL -l
