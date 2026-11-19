#!/bin/bash
set -euo pipefail

# Prevent Homebrew and its installer from pausing for interactive prompts
export NONINTERACTIVE=1

# ------------------------------------------
# Post-Install Configuration (Customize Me)
# ------------------------------------------
DOTFILES_REPO="" # e.g., "https://github.com"
DOTFILES_DIR="$HOME/.dotfiles"
STOW_PACKAGES=("zsh" "ghostty" "tmux" "nvim" "starship" "aerospace")

# Used if your dotfiles don't already include a mise config or .tool-versions
MISE_RUNTIMES=(
  "node@lts"
  "python@latest"
  "go@latest"
)

echo "=========================================="
echo " Starting macOS bootstrap script..."
echo "=========================================="

# Ask for the administrator password upfront
echo "Please enter your macOS password once to allow installations..."
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Homebrew (also handles headless Xcode Command Line Tools installation)
if ! command -v brew &>/dev/null && ! [[ -x "/opt/homebrew/bin/brew" ]]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed"
fi

# Add Homebrew to PATH if not already in .zprofile
ZPROFILE="${ZDOTDIR:-$HOME}/.zprofile"
BREW_SHELLENV='eval "$(/opt/homebrew/bin/brew shellenv zsh)"'

if ! grep -qsF "$BREW_SHELLENV" "$ZPROFILE"; then
    echo >> "$ZPROFILE"
    echo "$BREW_SHELLENV" >> "$ZPROFILE"
fi
eval "$(/opt/homebrew/bin/brew shellenv zsh)"

brew analytics off

# Ensure Homebrew is up to date
echo -e "\n==> Updating Homebrew..."
brew update

# ------------------------------------------
# Package Lists
# ------------------------------------------

TAPS=(
  "hashicorp/tap"
  "nikitabobko/tap"
)

CASKS=(
  "brave-browser"
  "ghostty"
  "bitwarden"
  "obsidian"
  "nordvpn"
  "cap"
  "iina"
  "logi-options+"
  "notion"
  "raycast"
  "vorssaint"
  "macshot"
  "spotify"
  "visual-studio-code"
  "zed"
  "font-jetbrains-mono-nerd-font"
  "nikitabobko/tap/aerospace"
  "azure-cli"
  "gcloud-cli"
)

FORMULAE=(
  # Terminal - CLI utilities
  "zsh"
  "wget"
  "tree"
  "tmux"
  "starship"
  "neovim"
  "fastfetch"
  "stow"
  "jq"
  "yq"
  "ripgrep"
  "fd"
  "fzf"
  "atuin"
  "eza"
  "bat"
  "zoxide"
  "superfile"

  # Dev tools
  "git"
  "mise"
  "docker"
  "docker-compose"
  "podman"
  "podman-compose"
  "colima"
  "kubernetes-cli"
  "helm"
  "talosctl"
  "hashicorp/tap/terraform"
  "opentofu"
  "ansible"
  "awscli"
)

# ------------------------------------------
# Installation Loops
# ------------------------------------------

echo -e "\n==> Adding Taps..."
for tap in "${TAPS[@]}"; do
  echo "--> Tapping $tap..."
  brew tap "$tap"
done

echo -e "\n==> Installing CLI Formulae..."
for formula in "${FORMULAE[@]}"; do
  if brew list --formula "$formula" &>/dev/null; then
    echo "✓ $formula is already installed. Skipping..."
  else
    echo "--> Installing $formula..."
    brew install "$formula" || echo "⚠️ Failed to install $formula"
  fi
done

echo -e "\n==> Installing GUI Apps & Casks..."
for cask in "${CASKS[@]}"; do
  if brew list --cask "$cask" &>/dev/null; then
    echo "✓ $cask is already installed. Skipping..."
  else
    echo "--> Installing $cask..."
    brew install --cask "$cask" || echo "⚠️ Failed to install $cask"
  fi
done










# ------------------------------------------
# Post-Install: Dotfiles & Stow
# ------------------------------------------
echo -e "\n==> Setting up Dotfiles..."
if [[ -n "$DOTFILES_REPO" ]]; then
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "--> Cloning dotfiles from $DOTFILES_REPO..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  else
    echo "--> Updating existing dotfiles in $DOTFILES_DIR..."
    git -C "$DOTFILES_DIR" pull --ff-only || echo "⚠️ Could not fast-forward dotfiles"
  fi

  for pkg in "${STOW_PACKAGES[@]}"; do
    if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
      echo "--> Stowing $pkg..."
      stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg"
    else
      echo "⚠️ Stow package '$pkg' not found in $DOTFILES_DIR, skipping..."
    fi
  done
else
  echo "--> DOTFILES_REPO is empty. Skipping git clone and stow."
fi

# ------------------------------------------
# Post-Install: Zsh & CLI Tool Hooks
# ------------------------------------------
echo -e "\n==> Configuring Zsh..."
BREW_ZSH="/opt/homebrew/bin/zsh"

if [[ -x "$BREW_ZSH" ]]; then
  if ! grep -qsF "$BREW_ZSH" /etc/shells; then
    echo "--> Adding $BREW_ZSH to /etc/shells..."
    echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
  fi

  if [[ "$SHELL" != "$BREW_ZSH" ]]; then
    echo "--> Changing default shell to $BREW_ZSH..."
    sudo chsh -s "$BREW_ZSH" "$USER"
  fi
fi

ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
touch "$ZSHRC"

# Helper to append a line to .zshrc only if it isn't already there
add_to_zshrc() {
  local line="$1"
  if ! grep -qsF "$line" "$ZSHRC"; then
    echo "$line" >> "$ZSHRC"
  fi
}

echo "--> Ensuring CLI tool initializations exist in $ZSHRC..."
add_to_zshrc ''
add_to_zshrc '# Tool initializations'
add_to_zshrc 'eval "$(mise activate zsh)"'
add_to_zshrc 'eval "$(starship init zsh)"'
add_to_zshrc 'eval "$(zoxide init zsh)"'
add_to_zshrc 'eval "$(atuin init zsh)"'
add_to_zshrc 'source <(fzf --zsh)'

# ------------------------------------------
# Post-Install: Mise Runtimes
# ------------------------------------------
echo -e "\n==> Installing Runtimes via Mise..."
if [[ -f "$HOME/.config/mise/config.toml" || -f "$HOME/.tool-versions" ]]; then
  echo "--> Found existing mise config from dotfiles. Running mise install..."
  mise install
else
  for runtime in "${MISE_RUNTIMES[@]}"; do
    echo "--> Installing global runtime: $runtime..."
    mise use --global "$runtime"
  done
fi

echo -e "\n==> Cleaning up old versions..."
brew cleanup

echo "=========================================="
echo " All installations & setup complete!"
echo " Restart your terminal to apply changes."
echo "=========================================="
