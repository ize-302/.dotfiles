#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

# Quickshell only generates the QML language server config (for editors) where
# this file already exists. Not tracked, as it gets replaced by a link, which
# dangles while that shell isn't running.
for dir in config/quickshell/*/; do
  [ -e "$dir.qmlls.ini" ] || [ -L "$dir.qmlls.ini" ] || touch "$dir.qmlls.ini"
done

mkdir -p "$HOME/.config"
stow --adopt -v -t "$HOME/.config" config
stow --adopt -v -t "$HOME" home

# SDDM runs as its own user and can't read $HOME, so the theme needs a
# root-owned copy
if [ -d /usr/share/sddm/themes ]; then
  echo "[+] Installing SDDM theme..."
  sudo rsync -a --delete --chown=root:root config/sddm/themes/custom/ /usr/share/sddm/themes/custom/
  # Selects the theme. Settings in /etc/sddm.conf, if present, win over this
  sudo install -Dm644 etc/sddm.conf.d/custom-theme.conf /etc/sddm.conf.d/custom-theme.conf
  # Arranges the outputs for the greeter, needs xorg-xrandr
  sudo install -Dm755 etc/sddm/Xsetup /etc/sddm/Xsetup
fi

# Reload shell once installed
echo "[+] Reloading shell..."
exec $SHELL -l
