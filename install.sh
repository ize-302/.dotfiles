#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

# The desktop (mango, waybar, Quickshell, ...) is mangifera (~/mangifera),
# installed first: its ~/.config/mango is a real folder, and this adds
# config/mango/local.conf (this machine's displays) into it
if [ ! -e "$HOME/.config/mango/config.conf" ]; then
  echo "[!] Install mangifera first (~/mangifera/install.sh): config/mango/local.conf"
  echo "    here goes into its ~/.config/mango"
  exit 1
fi

mkdir -p "$HOME/.config"
stow --adopt -v -t "$HOME/.config" config
stow --adopt -v -t "$HOME" home

# This machine's login screen scales, beside mangifera's SDDM config
if [ -d /etc/sddm.conf.d ]; then
  echo "[+] Installing SDDM screen scales..."
  sudo install -Dm644 etc/sddm.conf.d/scale.conf /etc/sddm.conf.d/scale.conf
fi

# Reload shell once installed
echo "[+] Reloading shell..."
exec $SHELL -l
