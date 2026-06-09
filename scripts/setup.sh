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

# Ask which terminal the user is using
echo "Which terminal do you want to configure?"
echo "1) Ghostty"
echo "2) Alacritty"
echo "3) Other"
read -rp "Enter your choice [1-3]: " terminal_choice

# Ensure config directories exist
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/lf"
mkdir -p "$HOME/.config/starship"

# Only create terminal-specific config dir if needed
if [ "$terminal_choice" = "1" ]; then
    mkdir -p "$HOME/.config/ghostty"
elif [ "$terminal_choice" = "2" ]; then
    mkdir -p "$HOME/.config/alacritty"
fi

# Helper function to safely symlink files or directories with confirmation before removing existing destination
symlink_item() {
    local src="$1"
    local dest="$2"

    # If the destination already exists (as a file, symlink, or dir), ask before removing it
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        read -rp "Destination $dest already exists. Remove it and replace with symlink? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            rm -rf "$dest"
        else
            echo "Skipped: $dest"
            return
        fi
    fi

    ln -s "$src" "$dest"
    echo "Linked: $dest"
}

# --- Deploy Individual Files ---
symlink_item "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
symlink_item "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship/starship.toml"
symlink_item "$DOTFILES_DIR/lf/lfrc" "$HOME/.config/lf/lfrc"

# --- Deploy Terminal Config Based on Choice ---
if [ "$terminal_choice" = "1" ]; then
    symlink_item "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
elif [ "$terminal_choice" = "2" ]; then
    symlink_item "$DOTFILES_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
else
    echo "Skipping terminal config."
fi

# --- Deploy Whole Directories ---
symlink_item "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
symlink_item "$DOTFILES_DIR/tmux" "$HOME/.config/tmux"

echo "All dotfiles have been successfully linked!"
echo "Note: If you are setting up Zsh for the first time, restart your terminal or run: source ~/.zshrc"