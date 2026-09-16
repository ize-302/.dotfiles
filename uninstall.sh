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

# Reload shell once uninstalled
echo "[+] Reloading shell..."
exec $SHELL -l
