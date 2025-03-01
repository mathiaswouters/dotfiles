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

# Install git if not already installed
print_step "Checking for Git..."
if ! command_exists git; then
    print_step "Installing Git..."
    sudo nix-env -iA nixos.git
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

# Step 2: Create necessary parent directory
print_step "Creating necessary parent directory..."
mkdir -p "$HOME/.config"

# Step 3: Link config directories to the appropriate locations
print_step "Setting up your dotfiles..."

# Create symbolic links for each configuration directory
for config_dir in hypr mako rofi waybar; do
    if [ -d "$DOTFILES_DIR/.config/$config_dir" ]; then
        print_step "Linking $config_dir configuration..."
        # Remove existing directory if it's there
        if [ -d "$HOME/.config/$config_dir" ]; then
            rm -rf "$HOME/.config/$config_dir"
        fi
        # Create the symbolic link
        ln -sf "$DOTFILES_DIR/.config/$config_dir" "$HOME/.config/$config_dir"
        echo "✓ $config_dir configuration linked"
    else
        print_error "Directory $config_dir not found in dotfiles repository"
    fi
done

# Make scripts executable
print_step "Making scripts executable..."
if [ -f "$HOME/.config/hypr/scripts/set-wallpaper.sh" ]; then
    chmod +x "$HOME/.config/hypr/scripts/set-wallpaper.sh"
    echo "✓ Made set-wallpaper.sh executable"
fi

# Create Wallpapers directory if it doesn't exist
mkdir -p "$HOME/Pictures/Wallpapers"

# Initialize swww and set wallpaper if available
if command_exists swww; then
    print_step "Initializing swww..."
    swww init
    
    if [ -x "$HOME/.config/hypr/scripts/set-wallpaper.sh" ]; then
        print_step "Setting wallpaper..."
        "$HOME/.config/hypr/scripts/set-wallpaper.sh"
    fi
fi

print_step "Dotfiles setup complete!"
