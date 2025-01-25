# My .dotfiles configuration

This directory contains the .dotfiles for my computer

> NOTE: For easy 'stowing', I am making the file structure similar to that of my $HOME directory

## Requirements

Ensure you have the following installed on your computer

### Git

Using homebrew `$ brew install git`

OR

Debian / Ubuntu `$ apt install git`

### GNU Stow

Using homebrew `$ brew install stow`

OR

Debian / Ubuntu `$ apt install stow`

## Setup

### Clone and check into the repo 

First, clone the .dotfiles repository into your $HOME directory using git

```
$ git clone https://github.com/ize-302/.dotfiles
$ cd .dotfiles
```

### How to install / uninstall

#### Method 1 (Manual setup)

Then use GNU stow to create symlinks

```
$ stow --adopt -v -t $HOME . # to install
```

```
$ stow -v -t $HOME -D . # to uninstall
```

#### Method 2 (Using .sh script)

i. Make the install.sh and uninstall.sh to be executables by running:

```
$ chmod +x install.sh uninstall.sh
```

ii. run:

```
$ ./install.sh # to install
```

```
$ ./uninstall.sh # to uninstall
```

