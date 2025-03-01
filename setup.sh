#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

# Color codes for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root and exit if true
if [ "$(id -u)" -eq 0 ]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Set repository URL
DOTFILES_REPO_URL="https://github.com/mathiaswouters/dotfiles.git"

# Set directory
DOTFILES_DIR="$HOME/dotfiles"

# Install stow if not already installed
print_step "Checking for GNU Stow..."
if ! command_exists stow; then
    print_step "Installing GNU Stow..."
    sudo nix-env -iA nixos.gnustow
fi

# Step 1: Clone or pull the dotfiles repository
print_step "Setting up dotfiles..."
if [ -d "$DOTFILES_DIR" ]; then
    cd "$DOTFILES_DIR"
    git pull
    print_step "Updated existing dotfiles repository"
else
    git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
    print_step "Cloned dotfiles repository from $DOTFILES_REPO_URL"
fi

# Step 2: Create necessary directories
print_step "Creating necessary config directories..."
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/waybar"
mkdir -p "$HOME/.config/mako"
mkdir -p "$HOME/.config/rofi"
mkdir -p "$HOME/Pictures/Wallpapers"

# Step 3: Use stow to create symlinks for each configuration
print_step "Applying dotfiles with stow..."

# Stow each directory individually
for config_dir in hypr mako rofi waybar; do
    if [ -d "$DOTFILES_DIR/$config_dir" ]; then
        print_step "Stowing $config_dir configuration..."
        stow -d "$DOTFILES_DIR" -t "$HOME" -R "$config_dir"
        echo "✓ $config_dir configurations linked"
    else
        print_error "Directory $config_dir not found in dotfiles repository"
    fi
done

# Make scripts executable
print_step "Making scripts executable..."
if [ -f "$HOME/.config/hypr/scripts/start.sh" ]; then
    chmod +x "$HOME/.config/hypr/scripts/start.sh"
    echo "✓ Made start.sh executable"
fi

if [ -f "$HOME/.config/hypr/scripts/set-wallpaper.sh" ]; then
    chmod +x "$HOME/.config/hypr/scripts/set-wallpaper.sh"
    echo "✓ Made set-wallpaper.sh executable"
fi

print_step "Dotfiles setup complete!"
