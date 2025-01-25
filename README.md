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

## Installation

First, clone the .dotfiles repository into your $HOME directory using git

```
$ git clone https://github.com/ize-302/.dotfiles
$ cd dotfiles
```

Then use GNU stow to create symlinks

```
$ stow --adopt -v -t $HOME .
```

## Uninstallation

`$ stow -v -t $HOME -D .`

