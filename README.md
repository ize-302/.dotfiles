# My .dotfiles configuration

This directory contains the .dotfiles for my computer, a Wayland / **Sway** setup.

The old Xorg/i3 configs are kept as a frozen backup in [.dotfiles-i3](https://github.com/ize-302/.dotfiles-i3) (tag `pre-wayland-only` here marks the last commit that carried them).

> NOTE: For easy 'stowing', each top-level directory is a separate GNU Stow package whose contents mirror my $HOME directory.

## Layout

- `common/` — shell, nvim, tmux, terminal, rofi, dunst, waybar, etc.
- `sway/` — Sway and the Quickshell lock screen

Stow both packages together.

## Requirements

Ensure you have the following installed on your computer

### Git

Using Arch 

```
pacman -S git
```

OR

Using homebrew

```
brew install git
```

OR

Debian / Ubuntu


```
apt install git
```

### GNU Stow

Using Arch 

```sh
pacman -S stow
```

OR

Using homebrew 

```sh
brew install stow
```

OR

Debian / Ubuntu 

```sh
apt install stow
```

## Setup

### Clone and check into the repo 

First, clone the .dotfiles repository into your $HOME directory using git

```sh
git clone git@github.com:ize-302/.dotfiles.git
cd .dotfiles
```

### How to install / uninstall

#### Method 1 (Manual setup)

Then use GNU stow to create symlinks:

```sh
stow --adopt -v -t $HOME common sway # to install
```

```sh
stow -v -t $HOME -D common sway # to uninstall
```

#### Method 2 (Using .sh script)

Step i. Make the install.sh and uninstall.sh to be executables by running:

```sh
chmod +x install.sh uninstall.sh
```

Step ii. Run:

```sh
./install.sh
```

```sh
./uninstall.sh
```

