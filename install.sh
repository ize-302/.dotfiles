#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

# The desktop (sway, waybar, Quickshell, ...) is swarch (~/swarch), installed
# first: its ~/.config/sway is a real folder, and this adds
# config/sway/config.d (this machine's outputs) into it
if [ ! -e "$HOME/.config/sway/config" ]; then
  echo "[!] Install swarch first (~/swarch/install.sh): config/sway/config.d"
  echo "    here goes into its ~/.config/sway"
  exit 1
fi

mkdir -p "$HOME/.config"
stow --adopt -v -t "$HOME/.config" config
stow --adopt -v -t "$HOME" home

# This machine's login screen scales, beside swarch's SDDM config
if [ -d /etc/sddm.conf.d ]; then
  echo "[+] Installing SDDM screen scales..."
  sudo install -Dm644 etc/sddm.conf.d/scale.conf /etc/sddm.conf.d/scale.conf
fi

# Reload shell once installed
echo "[+] Reloading shell..."
exec $SHELL -l
