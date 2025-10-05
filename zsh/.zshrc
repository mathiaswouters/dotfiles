setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit
source <(kubectl completion zsh)


source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# bindkey '^w' autosuggest-execute
# bindkey '^e' autosuggest-accept
# bindkey '^u' autosuggest-toggle
# bindkey '^L' vi-forward-word
# bindkey '^k' up-line-or-search
# bindkey '^j' down-line-or-search

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# You may need to manually set your language environment
export LANG=en_US.UTF-8

export EDITOR=/opt/homebrew/bin/nvim

alias cat=bat
alias ls='ls --color'
alias ll='ls -al'

# Git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias ga='git add'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'

# GO
export GOPATH='/Users/mathias/go'

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/mathias/.vimpkg/bin:${GOPATH}/bin:/Users/mathias/.cargo/bin

### FZF ###
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH=/opt/homebrew/bin:$PATH

export XDG_CONFIG_HOME="/Users/mathias/.config"

eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"