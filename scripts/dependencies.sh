#!/bin/bash

set -e

# =========================================================
# OS Detection
# =========================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    # Handle common Debian/Ubuntu derivatives seamlessly
    if [[ " $ID_LIKE " =~ "debian" || " $ID_LIKE " =~ "ubuntu" ]]; then
        OS="ubuntu"
    fi
else
    echo "Error: Unsupported or unidentified operating system."
    exit 1
fi

# =========================================================
# MacOS
# =========================================================
if [ "$OS" = "macos" ]; then
    echo "Installing dependencies for macOS..."

    # Zsh
    brew install zsh

    # Starship
    brew install starship

    # Neovim
    brew install neovim

    # Tmux
    brew install tmux

    # Fzf
    brew install fzf

    # Zoxide
    brew install zoxide

    # Fd
    brew install fd

    # Bat
    brew install bat

    # Eza
    brew install eza

    # Ripgrep
    brew install ripgrep

    # Lf
    brew install lf
fi

# =========================================================
# Fedora
# =========================================================
if [ "$OS" = "fedora" ]; then
    echo "Installing dependencies for Fedora..."

    # Zsh
    sudo dnf install -y zsh

    # Starship
    sudo dnf copr enable -y atim/starship
    sudo dnf install -y starship

    # Neovim
    sudo dnf install -y neovim

    # Tmux
    sudo dnf install -y tmux

    # Fzf
    sudo dnf install -y fzf

    # Zoxide
    sudo dnf install -y zoxide

    # Fd
    sudo dnf install -y fd-find

    # Bat
    sudo dnf install -y bat

    # Eza
    sudo dnf install -y eza

    # Ripgrep
    sudo dnf install -y ripgrep

    # Lf
    sudo dnf copr enable -y pennbauman/ports
    sudo dnf install -y lf
fi

# =========================================================
# Arch
# =========================================================
if [ "$OS" = "arch" ]; then
    echo "Installing dependencies for Arch Linux..."

    # Zsh
    sudo pacman -S --noconfirm zsh

    # Starship
    sudo pacman -S --noconfirm starship

    # Neovim
    sudo pacman -S --noconfirm neovim

    # Tmux
    sudo pacman -S --noconfirm tmux

    # Fzf
    sudo pacman -S --noconfirm fzf

    # Zoxide
    sudo pacman -S --noconfirm zoxide

    # Fd
    sudo pacman -S --noconfirm fd

    # Bat
    sudo pacman -S --noconfirm bat

    # Eza
    sudo pacman -S --noconfirm eza

    # Ripgrep
    sudo pacman -S --noconfirm ripgrep

    # Lf
    sudo pacman -S --noconfirm lf
fi

# =========================================================
# Ubuntu / Debian
# =========================================================
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    echo "Installing dependencies for Ubuntu / Debian..."
    sudo apt-get update

    # Zsh
    sudo apt-get install -y zsh

    # Starship
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Neovim
    sudo apt-get install -y neovim

    # Tmux
    sudo apt-get install -y tmux

    # Fzf
    sudo apt-get install -y fzf

    # Zoxide
    sudo apt-get install -y zoxide

    # Fd
    sudo apt-get install -y fd-find

    # Bat
    sudo apt-get install -y bat

    # Eza
    sudo apt-get install -y eza || sudo apt-get install -y eza-cli || true

    # Ripgrep
    sudo apt-get install -y ripgrep

    # Lf
    sudo apt-get install -y lf || sudo snap install lf-snap || true
fi
