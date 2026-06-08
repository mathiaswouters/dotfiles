#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"

# Verify that the dotfiles directory actually exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: Dotfiles directory not found at $DOTFILES_DIR" >&2
    echo "Please ensure the repository is cloned to ~/dotfiles before running this script." >&2
    exit 1
fi

echo "Starting dotfiles deployment..."

# Ensure config directories exist
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/alacritty"
mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/.config/lf"

# Helper function to safely symlink files or directories without nesting bugs
symlink_item() {
    local src="$1"
    local dest="$2"

    # If the destination already exists (as a file, symlink, or dir), remove it safely
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        rm -rf "$dest"
    fi

    ln -s "$src" "$dest"
    echo "Linked: $dest"
}

# --- Deploy Individual Files ---
symlink_item "$DOTFILES_DIR/zsh/.zshrc"         "$HOME/.zshrc"
symlink_item "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
symlink_item "$DOTFILES_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
symlink_item "$DOTFILES_DIR/ghostty/config"     "$HOME/.config/ghostty/config"
symlink_item "$DOTFILES_DIR/lf/lfrc"           "$HOME/.config/lf/lfrc"

# --- Deploy Whole Directories ---
symlink_item "$DOTFILES_DIR/nvim"               "$HOME/.config/nvim"
symlink_item "$DOTFILES_DIR/tmux"               "$HOME/.config/tmux"

echo "All dotfiles have been successfully linked!"
echo "Note: If you are setting up Zsh for the first time, restart your terminal or run: source ~/.zshrc"