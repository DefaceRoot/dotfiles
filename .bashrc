# ~/.bashrc - Bash configuration for DevPod containers

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -20'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# fzf configuration
if command -v fzf &> /dev/null; then
    # Use ripgrep for fzf if available
    if command -v rg &> /dev/null; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    fi
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

    # Source fzf keybindings if available
    [ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
    [ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

# Language-specific paths

# Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Node.js (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Python (pyenv)
export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv &> /dev/null && eval "$(pyenv init -)"

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# Load any local customizations
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
