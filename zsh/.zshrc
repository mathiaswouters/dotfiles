###################
### compinstall ###
###################

zstyle :compinstall filename '/home/mathias/.zshrc'

##################
### Oh My Posh ###
##################

export PATH="$HOME/.local/bin:$PATH"
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/catppuccin_mocha.omp.json)"

#############
### Zinit ###
#############

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
#zinit light MichaelAquilina/zsh-you-should-use

# Snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::dnf
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

##########################
### Completion Styling ###
##########################

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

###############
### Aliases ###
###############

alias ls='ls --color'
alias vim='nvim'
alias vi='nvim'

##########################
### Shell Integrations ###
##########################

eval "$(fzf --zsh)"

###############
### History ###
###############

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
unsetopt beep

###################
### Keybindings ###
###################

bindkey -v

###############
### Exports ###
###############

export EDITOR=vim
export VISUAL=vim
export PATH=$PATH:/usr/local/go/bin

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
