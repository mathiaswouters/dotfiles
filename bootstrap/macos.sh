#!/usr/bin/env bash
set -Eeuo pipefail

# Homebrew's installer supports NONINTERACTIVE=1. The installer itself may
# still require confirmation when run interactively.
export NONINTERACTIVE=1

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
  # Terminal and CLI utilities
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

  # Development tools
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

MISE_RUNTIMES=(
  "node@lts"
  "python@latest"
  "go@latest"
)

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
elif (($#)); then
  printf 'Error: unsupported argument: %s\n' "$1" >&2
  exit 1
fi

log() {
  printf '\n==> %s\n' "$*"
}

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    printf '%s\n' /opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    printf '%s\n' /usr/local/bin/brew
  else
    return 1
  fi
}

BREW_BIN=""
if ! BREW_BIN="$(find_brew)"; then
  if [[ "$DRY_RUN" == true ]]; then
    log "Homebrew is not installed."
    printf 'Would install Homebrew using the official installer.\n'
    printf 'Would install formulae: %s\n' "${FORMULAE[*]}"
    printf 'Would install casks: %s\n' "${CASKS[*]}"
    printf 'Would add taps: %s\n' "${TAPS[*]}"
    printf 'Would install mise runtimes: %s\n' "${MISE_RUNTIMES[*]}"
    exit 0
  fi

  command -v curl >/dev/null 2>&1 || {
    printf 'Error: curl is required to install Homebrew.\n' >&2
    exit 1
  }

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  BREW_BIN="$(find_brew)" || {
    printf 'Error: Homebrew installer finished, but brew was not found.\n' >&2
    exit 1
  }
fi

BREW_PREFIX="$("$BREW_BIN" --prefix)"
ZPROFILE="${ZDOTDIR:-$HOME}/.zprofile"
BREW_SHELLENV="eval \"\$($BREW_BIN shellenv zsh)\""

log "Configuring Homebrew shell environment"
if [[ "$DRY_RUN" == true ]]; then
  if [[ ! -f "$ZPROFILE" ]] || ! grep -Fqx "$BREW_SHELLENV" "$ZPROFILE"; then
    printf 'Would add Homebrew shell initialization to %s\n' "$ZPROFILE"
  fi
else
  mkdir -p "$(dirname "$ZPROFILE")"
  touch "$ZPROFILE"
  if ! grep -Fqx "$BREW_SHELLENV" "$ZPROFILE"; then
    printf '\n%s\n' "$BREW_SHELLENV" >> "$ZPROFILE"
  fi
fi

if [[ "$DRY_RUN" == false ]]; then
  # Make Homebrew available to the rest of this script immediately.
  eval "$("$BREW_BIN" shellenv zsh)"
fi

if [[ "$DRY_RUN" == false ]]; then
  log "Disabling Homebrew analytics"
  "$BREW_BIN" analytics off

  log "Updating Homebrew"
  "$BREW_BIN" update
else
  log "Would disable Homebrew analytics and update Homebrew"
fi

log "Adding Homebrew taps"
for tap in "${TAPS[@]}"; do
  if "$BREW_BIN" tap | grep -Fxq "$tap"; then
    printf 'Already tapped: %s\n' "$tap"
  elif [[ "$DRY_RUN" == true ]]; then
    printf 'Would tap: %s\n' "$tap"
  else
    "$BREW_BIN" tap "$tap"
  fi
done

log "Installing CLI formulae"
for formula in "${FORMULAE[@]}"; do
  if "$BREW_BIN" list --formula "$formula" >/dev/null 2>&1; then
    printf 'Already installed: %s\n' "$formula"
  elif [[ "$DRY_RUN" == true ]]; then
    printf 'Would install formula: %s\n' "$formula"
  else
    "$BREW_BIN" install "$formula"
  fi
done

log "Installing GUI applications"
for cask in "${CASKS[@]}"; do
  if "$BREW_BIN" list --cask "$cask" >/dev/null 2>&1; then
    printf 'Already installed: %s\n' "$cask"
  elif [[ "$DRY_RUN" == true ]]; then
    printf 'Would install cask: %s\n' "$cask"
  else
    "$BREW_BIN" install --cask "$cask"
  fi
done

log "Configuring the default Zsh shell"
BREW_ZSH="$BREW_PREFIX/bin/zsh"
if [[ -x "$BREW_ZSH" ]]; then
  if grep -Fqx "$BREW_ZSH" /etc/shells; then
    :
  elif [[ "$DRY_RUN" == true ]]; then
    printf 'Would add %s to /etc/shells (requires administrator privileges).\n' "$BREW_ZSH"
  else
    printf '%s\n' "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
  fi

  CURRENT_LOGIN_SHELL="$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}' || true)"
  if [[ "$CURRENT_LOGIN_SHELL" != "$BREW_ZSH" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      printf 'Would change the login shell to %s.\n' "$BREW_ZSH"
    else
      sudo chsh -s "$BREW_ZSH" "$(id -un)"
    fi
  else
    printf 'Default shell is already %s\n' "$BREW_ZSH"
  fi
else
  printf 'Warning: Homebrew Zsh was not found at %s; leaving the login shell unchanged.\n' "$BREW_ZSH" >&2
fi

log "Installing language runtimes with mise"
if [[ "$DRY_RUN" == true ]]; then
  printf 'Would install runtimes: %s\n' "${MISE_RUNTIMES[*]}"
elif command -v mise >/dev/null 2>&1; then
  for runtime in "${MISE_RUNTIMES[@]}"; do
    mise use --global "$runtime"
  done
else
  printf 'Warning: mise is not available; skipping runtime installation.\n' >&2
fi

log "macOS bootstrap complete."
printf 'Dotfiles will be deployed separately by setup.sh.\n'
