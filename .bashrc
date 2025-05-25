# ~/.bashrc: executed by bash for non-login interactive shells.

# Exit if not running interactively
case $- in
    *i*) ;;
    *) return;;
esac

##======================
## History Configuration
##======================
HISTCONTROL=ignoreboth       # Ignore duplicate lines and lines starting with space
shopt -s histappend          # Append to the history file
HISTSIZE=1000
HISTFILESIZE=2000

##==========================
## Terminal Behavior & Prompt
##==========================
shopt -s checkwinsize        # Auto-adjust terminal size

# Enable color prompt if supported
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Set terminal window title for xterm/rxvt
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac

##=============
## Aliases
##=============
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

##======================
## Autocompletion Support
##======================
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

##==================
## Custom Toolchains
##==================

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# The Fuck (command corrector)
eval "$(thefuck --alias)"

# Rust (Cargo)
. "$HOME/.cargo/env"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# fastfetch: Show system info on terminal launch
fastfetch

# Play sound on command failure (disabled by default)
error_sound() {
    local exit_status=$?
    if [ $exit_status -ne 0 ]; then
        ~/bin/error-sound.sh
    fi
}
PROMPT_COMMAND="error_sound${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

##===================
## Optional Features
##===================

# Starship
eval "$(starship init bash)"
# Execute the precmd to set initial PS1
starship_precmd
