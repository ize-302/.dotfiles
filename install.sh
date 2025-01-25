#!/bin/bash
set -e

stow --adopt -v -t $HOME .

# Reload shell once installed
echo "[+] Reloading shell..."
exec $SHELL -l
