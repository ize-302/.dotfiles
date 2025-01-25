#!/bin/bash

stow --adopt -v -t $HOME -D .

# Reload shell once uninstalled
echo "[+] Reloading shell..."
exec $SHELL -l
