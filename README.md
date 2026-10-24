# My .dotfiles configuration

This directory contains my personal .dotfiles: editor, shell, terminal and tool configs.

The desktop itself (mango, waybar, the Quickshell shell, GTK, the SDDM theme and their scripts) is its own project, **mangifera**, in `~/mangifera`. Install it first; this repo only adds this machine's settings on top (`config/mango/local.conf`).

The old Xorg/i3 configs are kept as a frozen backup in [.dotfiles-i3](https://github.com/ize-302/.dotfiles-i3) (tag `pre-wayland-only` here marks the last commit that carried them).

> NOTE: For easy 'stowing', the repo is split into two GNU Stow packages: `config/` mirrors `~/.config` and `home/` mirrors `$HOME`.

## Layout

- `config/` — everything that lands in `~/.config`: nvim, tmux, wezterm, yazi, opencode, hop, starship, auto-cpufreq, and `mango/local.conf` (this machine's displays, read last by mangifera's mango config)
- `home/` — everything that lands directly in `$HOME`: `.bashrc`, `.bash_aliases`, `.gitconfig`

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
mkdir -p $HOME/.config
stow --adopt -v -t $HOME/.config config # to install
stow --adopt -v -t $HOME home
```

```sh
stow -v -t $HOME/.config -D config # to uninstall
stow -v -t $HOME -D home
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

