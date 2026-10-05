#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

stow --adopt -v -t "$HOME/.config" -D config
stow --adopt -v -t "$HOME" -D home

# Remove the root-owned copy of the SDDM theme made by install.sh
if [ -d /usr/share/sddm/themes/custom ]; then
  echo "[+] Removing SDDM theme..."
  sudo rm -r /usr/share/sddm/themes/custom
  sudo rm -f /etc/sddm.conf.d/custom-theme.conf
  sudo rm -f /etc/sddm/Xsetup
fi

# Reload shell once uninstalled
echo "[+] Reloading shell..."
exec $SHELL -l
