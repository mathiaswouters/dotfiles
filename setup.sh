#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BOOTSTRAP_DIR="$SCRIPT_DIR/bootstrap"

MODE="full"
DRY_RUN=false
MODE_SELECTED=false

usage() {
  cat <<'EOF'
Usage: ./setup.sh [OPTION]

Run the complete workstation setup by default: bootstrap the OS, then deploy
the dotfiles with GNU Stow.

Options:
  --bootstrap-only  Run OS-specific installation and configuration only.
  --dotfiles-only   Deploy dotfiles with GNU Stow only.
  --dry-run         Preview actions without changing the system.
  -h, --help        Show this help message.

Examples:
  ./setup.sh
  ./setup.sh --dry-run
  ./setup.sh --bootstrap-only
  ./setup.sh --dotfiles-only
EOF
}

log() {
  printf '\n==> %s\n' "$*"
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    --bootstrap-only)
      [[ "$MODE_SELECTED" == false ]] || die "Choose only one setup mode."
      MODE="bootstrap"
      MODE_SELECTED=true
      ;;
    --dotfiles-only)
      [[ "$MODE_SELECTED" == false ]] || die "Choose only one setup mode."
      MODE="dotfiles"
      MODE_SELECTED=true
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1 (use --help for usage)."
      ;;
  esac
  shift
done

detect_os() {
  if [[ "$OSTYPE" == darwin* ]]; then
    OS_TYPE="macos"
    return
  fi

  if [[ ! -r /etc/os-release ]]; then
    OS_TYPE="unknown"
    return
  fi

  # shellcheck disable=SC1091
  . /etc/os-release

  case "${ID:-}" in
    arch|manjaro|endeavouros)
      OS_TYPE="arch"
      ;;
    debian|ubuntu|pop|linuxmint)
      OS_TYPE="debian"
      ;;
    fedora|rhel|centos|rocky|almalinux)
      OS_TYPE="fedora"
      ;;
    *)
      case " ${ID_LIKE:-} " in
        *" arch "*)
          OS_TYPE="arch"
          ;;
        *" debian "*|*" ubuntu "*)
          OS_TYPE="debian"
          ;;
        *" fedora "*|*" rhel "*)
          OS_TYPE="fedora"
          ;;
        *)
          OS_TYPE="unknown"
          ;;
      esac
      ;;
  esac
}

run_bootstrap() {
  local script=""

  case "$OS_TYPE" in
    macos)  script="$BOOTSTRAP_DIR/macos.sh" ;;
    arch)   script="$BOOTSTRAP_DIR/arch.sh" ;;
    debian) script="$BOOTSTRAP_DIR/debian.sh" ;;
    fedora) script="$BOOTSTRAP_DIR/fedora.sh" ;;
    *)      die "Unsupported or unrecognized operating system." ;;
  esac

  [[ -f "$script" ]] || die "Bootstrap script not found: $script"

  log "Running $OS_TYPE bootstrap"
  if [[ "$DRY_RUN" == true ]]; then
    bash "$script" --dry-run
  else
    bash "$script"
  fi
}

deploy_dotfiles() {
  local packages=()
  local package

  # AeroSpace is a macOS window manager; the other packages are cross-platform.
  packages=(zsh ghostty starship)
  if [[ "$OS_TYPE" == "macos" ]]; then
    packages+=(aerospace)
  fi

  local available_packages=()
  for package in "${packages[@]}"; do
    [[ -d "$SCRIPT_DIR/$package" ]] && available_packages+=("$package")
  done

  (("${#available_packages[@]}")) || die "No Stow packages were found."

  if ! command -v stow >/dev/null 2>&1; then
    if [[ "$DRY_RUN" == true ]]; then
      log "GNU Stow is not installed; cannot preview link operations."
      printf 'Would stow: %s\n' "${available_packages[*]}"
      return
    fi
    die "GNU Stow is required. Install it, then rerun ./setup.sh --dotfiles-only."
  fi

  log "Deploying dotfiles with GNU Stow"
  local stow_args=(--dir="$SCRIPT_DIR" --target="$HOME" --restow --verbose)
  if [[ "$DRY_RUN" == true ]]; then
    stow_args+=(--simulate)
    printf 'Dry run: '
  fi

  stow "${stow_args[@]}" "${available_packages[@]}"
}

if [[ "$DRY_RUN" == true ]]; then
  log "Dry-run mode enabled; no changes will be made."
fi

detect_os
log "Detected operating system: $OS_TYPE"

if [[ "$MODE" != "dotfiles" ]]; then
  run_bootstrap
fi

if [[ "$MODE" != "bootstrap" ]]; then
  deploy_dotfiles
fi

log "Setup complete."
