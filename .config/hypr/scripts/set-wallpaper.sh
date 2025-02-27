#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Create the directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Default wallpaper in case no wallpapers are found
DEFAULT_WALLPAPER="/etc/nixos/wallpaper.jpg"

# If the default wallpaper exists, copy it to the wallpaper directory if it's empty
if [ -f "$DEFAULT_WALLPAPER" ] && [ -z "$(ls -A "$WALLPAPER_DIR")" ]; then
    cp "$DEFAULT_WALLPAPER" "$WALLPAPER_DIR"
fi

# Function to set wallpaper
set_wallpaper() {
    # Check if swww is installed
    if command -v swww >/dev/null 2>&1; then
        # Initialize swww if not already running
        swww query || swww init
        
        # Set the wallpaper with animation
        swww img "$1" --transition-type grow --transition-fps 60 --transition-duration 1
    else
        echo "swww is not installed. Please install it first."
        exit 1
    fi
}

# If a specific wallpaper is provided as an argument
if [ -n "$1" ] && [ -f "$1" ]; then
    set_wallpaper "$1"
    exit 0
fi

# Otherwise, pick a random wallpaper from the directory
if [ -d "$WALLPAPER_DIR" ] && [ "$(ls -A "$WALLPAPER_DIR")" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    set_wallpaper "$WALLPAPER"
else
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi