#!/usr/bin/env bash
set -e

DEFAULT_TARGET="$HOME/.config"
HOME_PACKAGES=("zsh")
SPECIAL_PACKAGES=("atuin")

for pkg in */ ; do
  pkg="${pkg%/}"
  
  if [[ " ${HOME_PACKAGES[@]} " =~ " ${pkg} " ]]; then
    echo "→ Stowing $pkg into $HOME"
    stow --target="$HOME" "$pkg"

  elif [[ " ${SPECIAL_PACKAGES[@]} " =~ " ${pkg} " ]]; then
    TARGET="$DEFAULT_TARGET/$pkg"
    rm -rf "$TARGET"
    mkdir -p "$TARGET"
    echo "→ Stowing $pkg into $TARGET"
    stow --target="$TARGET" "$pkg"

  else
    # Force stow to create a subdirectory inside .config
    TARGET="$DEFAULT_TARGET/$pkg"
    mkdir -p "$TARGET"   # make sure the target exists
    echo "→ Stowing $pkg into $TARGET"
    stow --target="$TARGET" "$pkg"
  fi
done
