if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    # ls
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'

    #grep
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Desktop notification after long command
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

## Sudo
alias abeg="sudo"

## zellij
alias za="zellij attach"
alias zl="zellij list-sessions"

# neovim 
alias nv="nvim"

## Git
alias ga="git add"
alias gc="git commit" 

alias gco="git checkout" 
alias gdf="git diff" 

alias gca="gc --amend" # ammend previous commit message
alias gnb="gco -b" # create new branch
alias gst="git status --short" # git status
alias gps="git push" # push
alias gpl="git pull" # pull
alias gcp="git cherry-pick" # git cherry-pick

