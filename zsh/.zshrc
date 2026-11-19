

# ------------------------------------------
# Tool initializations
# ------------------------------------------

# mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
  export STARSHIP_CONFIG=~/.config/starship/starship.toml
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# atuin
if command -v atuin >/dev/null 2>&1; then
  export ATUIN_HOME="$HOME/.config/atuin"
  eval "$(atuin init zsh)"
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi




##################################################################################################################

# Disable grep command to encourage using ripgrep (rg)
grep() {
  echo "Use rg instead" >&2
  return 1
}

# Disable cd command to encourage using zoxide (z)
cd() {
  echo "Use z instead" >&2
  return 1
}
