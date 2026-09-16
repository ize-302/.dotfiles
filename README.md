# My .dotfiles configuration

This directory contains the .dotfiles for my computer, covering both **i3** and **Sway** setups.

> NOTE: For easy 'stowing', each top-level directory is a separate GNU Stow package whose contents mirror my $HOME directory.

## Layout

- `common/` — configs shared by both window managers (shell, nvim, tmux, terminal, rofi, dunst, i3blocks, etc.)
- `i3/` — i3-only configs (`i3`)
- `sway/` — Sway-only configs (`sway`)

Always stow `common` together with exactly one of `i3` or `sway`.

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

Then use GNU stow to create symlinks, picking exactly one of `i3` or `sway` alongside `common`:

```sh
stow --adopt -v -t $HOME common i3   # to install i3
stow --adopt -v -t $HOME common sway # to install Sway
```

```sh
stow -v -t $HOME -D common i3   # to uninstall i3
stow -v -t $HOME -D common sway # to uninstall Sway
```

#### Method 2 (Using .sh script)

Step i. Make the install.sh and uninstall.sh to be executables by running:

```sh
chmod +x install.sh uninstall.sh
```

Step ii. Run:

```sh
./install.sh i3    # or: ./install.sh sway
```

```sh
./uninstall.sh i3   # or: ./uninstall.sh sway
```

Running either script with no argument will prompt you to choose interactively.

