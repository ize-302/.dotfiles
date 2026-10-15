#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

# Quickshell only generates the QML language server config (for editors) where
# this file already exists. Not tracked, as it gets replaced by a link, which
# dangles while that shell isn't running.
for dir in config/quickshell/*/; do
  [ -e "$dir.qmlls.ini" ] || [ -L "$dir.qmlls.ini" ] || touch "$dir.qmlls.ini"
done

# GTK theme the palette in config/gtk-3.0 is built on (set in config/sway/config)
if ! pacman -Q adw-gtk-theme >/dev/null 2>&1; then
  echo "[+] Installing adw-gtk-theme..."
  sudo pacman -S --needed adw-gtk-theme
fi

# The launcher's bluetooth pairing agent (home/.local/bin/bluetooth-agent)
if ! pacman -Q python-dbus python-gobject >/dev/null 2>&1; then
  echo "[+] Installing python-dbus and python-gobject..."
  sudo pacman -S --needed python-dbus python-gobject
fi

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
