#!/bin/bash
set -uo pipefail

# =========================================================
# Colors
# =========================================================
if [[ -t 1 ]]; then
    RESET='\033[0m'
    BOLD='\033[1m'
    BLUE='\033[34m'
    GREEN='\033[32m'
    YELLOW='\033[33m'
    RED='\033[31m'
    CYAN='\033[36m'
else
    RESET=''
    BOLD=''
    BLUE=''
    GREEN=''
    YELLOW=''
    RED=''
    CYAN=''
fi

# =========================================================
# Summary tracking
# =========================================================
declare -a INSTALLED_NOW=()
declare -a ALREADY_INSTALLED=()
declare -a FAILED=()
declare -a SKIPPED=()

# =========================================================
# Logging helpers
# =========================================================
info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

ok() {
    echo -e "${GREEN}[OK]${RESET}   $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

fail() {
    echo -e "${RED}[FAIL]${RESET} $1"
}

section() {
    echo
    echo -e "${CYAN}${BOLD}=== $1 ===${RESET}"
}

# =========================================================
# Summary helpers
# =========================================================
mark_installed_now() {
    INSTALLED_NOW+=("$1")
}

mark_already_installed() {
    ALREADY_INSTALLED+=("$1")
}

mark_failed() {
    FAILED+=("$1")
}

mark_skipped() {
    SKIPPED+=("$1")
}

print_list() {
    local title="$1"
    shift
    local items=("$@")

    if [[ ${#items[@]} -gt 0 ]]; then
        echo -e "${BOLD}$title${RESET}"
        for item in "${items[@]}"; do
            echo "  - $item"
        done
    else
        echo -e "${BOLD}$title${RESET}"
        echo "  - none"
    fi
    echo
}

print_summary() {
    echo
    echo -e "${CYAN}${BOLD}========================================${RESET}"
    echo -e "${CYAN}${BOLD}Installation Summary${RESET}"
    echo -e "${CYAN}${BOLD}========================================${RESET}"
    echo

    print_list "Already installed:" "${ALREADY_INSTALLED[@]}"
    print_list "Installed successfully:" "${INSTALLED_NOW[@]}"
    print_list "Failed:" "${FAILED[@]}"
    print_list "Skipped:" "${SKIPPED[@]}"
}

# =========================================================
# Utility helpers
# =========================================================
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

install_brew_pkg() {
    local name="$1"
    local check_cmd="${2:-$1}"
    local pkg="${3:-$1}"

    if is_installed "$check_cmd"; then
        ok "$name already installed"
        mark_already_installed "$name"
        return 0
    fi

    info "Installing $name..."
    if brew install "$pkg"; then
        ok "$name installed successfully"
        mark_installed_now "$name"
    else
        fail "$name installation failed"
        mark_failed "$name"
    fi
}

install_dnf_pkg() {
    local name="$1"
    local check_cmd="$2"
    shift 2
    local pkgs=("$@")

    if is_installed "$check_cmd"; then
        ok "$name already installed"
        mark_already_installed "$name"
        return 0
    fi

    info "Installing $name..."
    if sudo dnf install -y "${pkgs[@]}"; then
        ok "$name installed successfully"
        mark_installed_now "$name"
    else
        fail "$name installation failed"
        mark_failed "$name"
    fi
}

install_pacman_pkg() {
    local name="$1"
    local check_cmd="${2:-$1}"
    local pkg="${3:-$1}"

    if is_installed "$check_cmd"; then
        ok "$name already installed"
        mark_already_installed "$name"
        return 0
    fi

    info "Installing $name..."
    if sudo pacman -S --noconfirm "$pkg"; then
        ok "$name installed successfully"
        mark_installed_now "$name"
    else
        fail "$name installation failed"
        mark_failed "$name"
    fi
}

install_apt_pkg() {
    local name="$1"
    local check_cmd="${2:-$1}"
    local pkg="${3:-$1}"

    if is_installed "$check_cmd"; then
        ok "$name already installed"
        mark_already_installed "$name"
        return 0
    fi

    info "Installing $name..."
    if sudo apt-get install -y "$pkg"; then
        ok "$name installed successfully"
        mark_installed_now "$name"
    else
        fail "$name installation failed"
        mark_failed "$name"
    fi
}

install_apt_pkg_if_available() {
    local name="$1"
    local check_cmd="$2"
    local pkg="$3"

    if is_installed "$check_cmd"; then
        ok "$name already installed"
        mark_already_installed "$name"
        return 0
    fi

    if apt-cache show "$pkg" >/dev/null 2>&1; then
        info "Installing $name..."
        if sudo apt-get install -y "$pkg"; then
            ok "$name installed successfully"
            mark_installed_now "$name"
        else
            fail "$name installation failed"
            mark_failed "$name"
        fi
    else
        warn "$name not available in apt repositories, skipping"
        mark_skipped "$name"
    fi
}

# =========================================================
# OS Detection
# =========================================================
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS="${ID:-unknown}"

        if [[ "$OS" == "ubuntu" || "$OS" == "debian" || "${ID_LIKE:-}" =~ (debian|ubuntu) ]]; then
            OS="ubuntu"
        fi
    else
        fail "Unsupported or unidentified operating system"
        exit 1
    fi

    info "Detected OS: $OS"
}

# =========================================================
# macOS
# =========================================================
install_macos() {
    section "Installing dependencies for macOS"

    if ! is_installed brew; then
        fail "Homebrew is not installed. Please install Homebrew first."
        mark_failed "homebrew"
        return
    fi

    install_brew_pkg "zsh"
    install_brew_pkg "starship"
    install_brew_pkg "neovim" "nvim" "neovim"
    install_brew_pkg "tmux"
    install_brew_pkg "fzf"
    install_brew_pkg "zoxide"
    install_brew_pkg "fd"
    # install_brew_pkg "bat"
    install_brew_pkg "ripgrep" "rg" "ripgrep"
    install_brew_pkg "lf"
}

# =========================================================
# Fedora
# =========================================================
install_fedora() {
    section "Installing dependencies for Fedora"

    install_dnf_pkg "zsh" "zsh" "zsh"
    install_dnf_pkg "neovim" "nvim" "neovim"
    install_dnf_pkg "tmux" "tmux" "tmux"
    install_dnf_pkg "fzf" "fzf" "fzf"
    install_dnf_pkg "zoxide" "zoxide" "zoxide"

    if is_installed fd; then
        ok "fd already installed"
        mark_already_installed "fd"
    else
        info "Installing fd..."
        if sudo dnf install -y fd-find || sudo dnf install -y fd; then
            ok "fd installed successfully"
            mark_installed_now "fd"
        else
            fail "fd installation failed"
            mark_failed "fd"
        fi
    fi

    # install_dnf_pkg "bat" "bat" "bat"
    install_dnf_pkg "ripgrep" "rg" "ripgrep"

    if is_installed starship; then
        ok "starship already installed"
        mark_already_installed "starship"
    else
        info "Installing starship..."
        if sudo dnf copr enable -y atim/starship && sudo dnf install -y starship; then
            ok "starship installed successfully"
            mark_installed_now "starship"
        else
            fail "starship installation failed"
            mark_failed "starship"
        fi
    fi

    if is_installed lf; then
        ok "lf already installed"
        mark_already_installed "lf"
    else
        info "Installing lf..."
        if sudo dnf copr enable -y pennbauman/ports && sudo dnf install -y lf; then
            ok "lf installed successfully"
            mark_installed_now "lf"
        else
            fail "lf installation failed"
            mark_failed "lf"
        fi
    fi
}

# =========================================================
# Arch
# =========================================================
install_arch() {
    section "Installing dependencies for Arch Linux"

    install_pacman_pkg "zsh" "zsh" "zsh"
    install_pacman_pkg "starship" "starship" "starship"
    install_pacman_pkg "neovim" "nvim" "neovim"
    install_pacman_pkg "tmux" "tmux" "tmux"
    install_pacman_pkg "fzf" "fzf" "fzf"
    install_pacman_pkg "zoxide" "zoxide" "zoxide"
    install_pacman_pkg "fd" "fd" "fd"
    # install_pacman_pkg "bat" "bat" "bat"
    install_pacman_pkg "ripgrep" "rg" "ripgrep"
    install_pacman_pkg "lf" "lf" "lf"
}

# =========================================================
# Ubuntu / Debian
# =========================================================
install_ubuntu() {
    section "Installing dependencies for Ubuntu / Debian"

    info "Updating apt package index..."
    if sudo apt-get update; then
        ok "apt package index updated"
    else
        fail "apt-get update failed"
        mark_failed "apt update"
        return
    fi

    install_apt_pkg "curl" "curl" "curl"
    install_apt_pkg "zsh" "zsh" "zsh"
    install_apt_pkg "neovim" "nvim" "neovim"
    install_apt_pkg "tmux" "tmux" "tmux"
    install_apt_pkg "fzf" "fzf" "fzf"

    # zoxide
    install_apt_pkg_if_available "zoxide" "zoxide" "zoxide"

    # fd package installs command as fdfind on Debian/Ubuntu
    install_apt_pkg "fd" "fdfind" "fd-find"

    # # bat package installs command as batcat on Debian/Ubuntu
    # install_apt_pkg "bat" "batcat" "bat"

    install_apt_pkg "ripgrep" "rg" "ripgrep"

    # starship
    if is_installed starship; then
        ok "starship already installed"
        mark_already_installed "starship"
    else
        info "Installing starship..."
        if curl -sS https://starship.rs/install.sh | sh -s -- -y; then
            ok "starship installed successfully"
            mark_installed_now "starship"
        else
            fail "starship installation failed"
            mark_failed "starship"
        fi
    fi

    # lf
    if is_installed lf; then
        ok "lf already installed"
        mark_already_installed "lf"
    else
        if apt-cache show lf >/dev/null 2>&1; then
            info "Installing lf..."
            if sudo apt-get install -y lf; then
                ok "lf installed successfully"
                mark_installed_now "lf"
            else
                fail "lf installation failed"
                mark_failed "lf"
            fi
        else
            warn "lf not available in apt repositories, skipping"
            mark_skipped "lf"
        fi
    fi
}

# =========================================================
# Main
# =========================================================
main() {
    detect_os

    case "$OS" in
        macos)
            install_macos
            ;;
        fedora)
            install_fedora
            ;;
        arch)
            install_arch
            ;;
        ubuntu|debian)
            install_ubuntu
            ;;
        *)
            fail "Unsupported OS: $OS"
            exit 1
            ;;
    esac

    print_summary
}

main "$@"
