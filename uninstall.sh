#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

wm="$1"
if [ -z "$wm" ]; then
  echo "Which window manager? [i3/sway]"
  read -r wm
fi

case "$wm" in
  i3|sway) ;;
  *)
    echo "Usage: ./uninstall.sh [i3|sway]"
    exit 1
    ;;
esac

stow --adopt -v -t "$HOME" -D common "$wm"

# Remove the root-owned copy of the SDDM theme made by install.sh
if [ -d /usr/share/sddm/themes/custom ]; then
  echo "[+] Removing SDDM theme..."
  sudo rm -r /usr/share/sddm/themes/custom
  sudo rm -f /etc/sddm.conf.d/custom-theme.conf
fi

# Reload shell once uninstalled
echo "[+] Reloading shell..."
exec $SHELL -l
