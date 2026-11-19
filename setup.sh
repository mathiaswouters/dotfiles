#!/bin/bash
set -euo pipefail


# Add docs folder in dotfiles repo --> this need to be ignored for stow

## Add option to setup.sh script to skip bootstrap part and just run dotfiles / stow part



# Detect the OS
OS_TYPE="unknown"

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
elif [[ -f /etc/os-release ]]; then
    # Source the file to load variables like $ID and $ID_LIKE
    . /etc/os-release
    OS_TYPE="$ID"
fi

echo "Detected system: $OS_TYPE"

# 2. Run OS-specific actions
case "$OS_TYPE" in
    macos)
        echo "Running macOS tasks..."
        # Example: brew update
        ;;
    debian|ubuntu|pop|linuxmint)
        echo "Running Debian/Ubuntu-based tasks..."
        # Example: sudo apt update
        ;;
    arch|manjaro|endeavouros)
        echo "Running Arch-based tasks..."
        # Example: sudo pacman -Syu
        ;;
    fedora|rhel|centos|rocky|almalinux)
        echo "Running Fedora/RHEL-based tasks..."
        # Example: sudo dnf check-update
        ;;
    *)
        echo "Unsupported or unrecognized OS: $OS_TYPE"
        exit 1
        ;;
esac

# 3. Run common tasks (runs on all supported systems)
echo "Running cross-platform tasks..."



# Dotfiles stow

cd "$(dirname "$0")"

stow --restow */