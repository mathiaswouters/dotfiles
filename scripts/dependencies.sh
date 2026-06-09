#!/bin/bash
set -e

# =========================================================
# OS Detection
# =========================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS="${ID:-unknown}"

    if [[ "$OS" == "ubuntu" || "$OS" == "debian" || "${ID_LIKE:-}" =~ (debian|ubuntu) ]]; then
        OS="ubuntu"
    fi
else
    echo "Error: Unsupported or unidentified operating system."
    exit 1
fi

# =========================================================
# MacOS
# =========================================================

if [[ "$OS" == "macos" ]]; then
    echo "Installing dependencies for macOS..."

    if ! command -v brew >/dev/null 2>&1; then
        echo "Error: Homebrew is not installed. Install Homebrew first."
        exit 1
    fi

    brew install zsh starship neovim tmux fzf zoxide fd bat eza ripgrep lf
fi


# =========================================================
# Fedora
# =========================================================
if [[ "$OS" == "fedora" ]]; then
    echo "Installing dependencies for Fedora..."

    sudo dnf install -y zsh neovim tmux fzf zoxide bat eza ripgrep
    sudo dnf install -y fd-find || sudo dnf install -y fd

    if ! command -v starship >/dev/null 2>&1; then
        sudo dnf copr enable -y atim/starship
        sudo dnf install -y starship
    fi

    if ! command -v lf >/dev/null 2>&1; then
        sudo dnf copr enable -y pennbauman/ports
        sudo dnf install -y lf || echo "Warning: lf could not be installed."
    fi
fi

# =========================================================
# Arch
# =========================================================
if [[ "$OS" == "arch" ]]; then
    echo "Installing dependencies for Arch Linux..."
    sudo pacman -S --noconfirm zsh starship neovim tmux fzf zoxide fd bat eza ripgrep lf
fi

# =========================================================
# Ubuntu / Debian
# =========================================================
if [[ "$OS" == "ubuntu" ]]; then
    echo "Installing dependencies for Ubuntu / Debian..."

    sudo apt-get update
    sudo apt-get install -y curl zsh neovim tmux fzf fd-find bat ripgrep

    if ! command -v starship >/dev/null 2>&1; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    if apt-cache show zoxide >/dev/null 2>&1; then
        sudo apt-get install -y zoxide
    else
        echo "Warning: zoxide not available in apt repositories. Skipping."
    fi

    if apt-cache show eza >/dev/null 2>&1; then
        sudo apt-get install -y eza
    elif apt-cache show eza-cli >/dev/null 2>&1; then
        sudo apt-get install -y eza-cli
    else
        echo "Warning: eza not available in apt repositories. Skipping."
    fi

    if apt-cache show lf >/dev/null 2>&1; then
        sudo apt-get install -y lf
    else
        echo "Warning: lf not available in apt repositories. Skipping."
    fi
fi

echo "Done."
