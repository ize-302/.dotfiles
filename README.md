# My .dotfiles configuration

This directory contains the .dotfiles for my computer

> NOTE: For easy 'stowing', I am making the file structure similar to that of my $HOME directory

## Requirements

Ensure you have the following installed on your computer

### Git

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

Then use GNU stow to create symlinks

```sh
stow --adopt -v -t $HOME . # to install
```

```sh
stow -v -t $HOME -D . # to uninstall
```

#### Method 2 (Using .sh script)

Step i. Make the install.sh and uninstall.sh to be executables by running:

```sh
chmod +x install.sh uninstall.sh
```

Step ii. Run:

```sh
./install.sh # to install
```

```sh
./uninstall.sh # to uninstall
```

