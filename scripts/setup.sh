#!/bin/bash
# Link every config named in links.conf into $HOME.
#
# Safe to re-run: an already-correct symlink is left alone, and anything else
# occupying a destination is moved into a timestamped backup directory rather
# than deleted.
#
# Usage:
#   ./scripts/setup.sh                     interactive
#   ./scripts/setup.sh --terminal ghostty --yes
#   ./scripts/setup.sh --dry-run
#
# Options:
#   --terminal <ghostty|alacritty|none>  Which terminal config to link.
#   --wayland / --no-wayland             Override Wayland autodetection.
#   -y, --yes                            Never prompt; back up conflicts.
#   -n, --dry-run                        Print what would happen, change nothing.
#   -h, --help                           Show this help.
#
# Deliberately avoids associative arrays and array expansion under `set -u`,
# because macOS still ships bash 3.2 where both misbehave.

set -euo pipefail

# Resolve the repo root from this script's own location so the checkout can live
# anywhere — ~/dotfiles by hand, ~/.dotfiles under Ansible, or a worktree.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
MANIFEST="$DOTFILES_DIR/links.conf"

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
TPM_DIR="$HOME/.tmux/plugins/tpm"

TERMINAL_CHOICE=""
WAYLAND_OVERRIDE=""
ASSUME_YES=0
DRY_RUN=0

# Newline-separated report buckets.
LINKED=""
UNCHANGED=""
BACKED_UP=""
SKIPPED=""
MISSING=""

# =========================================================
# Colors
# =========================================================
if [[ -t 1 ]]; then
    RESET='\033[0m'; BOLD='\033[1m'; BLUE='\033[34m'
    GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; CYAN='\033[36m'
else
    RESET=''; BOLD=''; BLUE=''; GREEN=''; YELLOW=''; RED=''; CYAN=''
fi

info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
ok()   { echo -e "${GREEN}[OK]${RESET}   $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
fail() { echo -e "${RED}[FAIL]${RESET} $1" >&2; }
section() { echo; echo -e "${CYAN}${BOLD}=== $1 ===${RESET}"; }

record() {
    # record <bucket-name> <line>
    local current
    eval "current=\${$1}"
    if [[ -z "$current" ]]; then
        eval "$1=\$2"
    else
        eval "$1=\${current}\$'\\n'\$2"
    fi
}

print_list() {
    local title="$1" body="$2"
    echo -e "${BOLD}$title${RESET}"
    if [[ -z "$body" ]]; then
        echo "  - none"
    else
        while IFS= read -r line; do
            [[ -n "$line" ]] && echo "  - $line"
        done <<<"$body"
    fi
    echo
}

print_summary() {
    echo
    echo -e "${CYAN}${BOLD}========================================${RESET}"
    echo -e "${CYAN}${BOLD}Dotfiles Summary${RESET}"
    echo -e "${CYAN}${BOLD}========================================${RESET}"
    echo
    print_list "Linked:"          "$LINKED"
    print_list "Already correct:" "$UNCHANGED"
    print_list "Backed up:"       "$BACKED_UP"
    print_list "Skipped:"         "$SKIPPED"
    print_list "Missing in repo:" "$MISSING"

    if [[ -n "$BACKED_UP" ]]; then
        info "Replaced files were moved to $BACKUP_DIR"
    fi
    if [[ -n "$MISSING" ]]; then
        warn "Some sources listed in links.conf do not exist in the repo."
        return 1
    fi
    return 0
}

# =========================================================
# Argument parsing
# =========================================================
usage() { sed -n '2,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --terminal)
                [[ $# -ge 2 ]] || { fail "--terminal needs a value"; exit 2; }
                TERMINAL_CHOICE="$2"; shift 2 ;;
            --terminal=*) TERMINAL_CHOICE="${1#*=}"; shift ;;
            --wayland)    WAYLAND_OVERRIDE=1; shift ;;
            --no-wayland) WAYLAND_OVERRIDE=0; shift ;;
            -y|--yes)     ASSUME_YES=1; shift ;;
            -n|--dry-run) DRY_RUN=1; shift ;;
            -h|--help)    usage; exit 0 ;;
            *) fail "Unknown option: $1"; usage; exit 2 ;;
        esac
    done

    case "$TERMINAL_CHOICE" in
        ghostty|alacritty|none|"") ;;
        *) fail "--terminal must be ghostty, alacritty or none"; exit 2 ;;
    esac
}

# =========================================================
# Environment detection
# =========================================================
is_wsl() {
    [[ -n "${WSL_DISTRO_NAME:-}" ]] && return 0
    grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null
}

# Wayland configs are Linux-only and pointless under WSL, which has no compositor.
detect_wayland() {
    if [[ -n "$WAYLAND_OVERRIDE" ]]; then
        [[ "$WAYLAND_OVERRIDE" == "1" ]]
        return
    fi
    case "$OSTYPE" in darwin*) return 1 ;; esac
    is_wsl && return 1
    [[ -n "${WAYLAND_DISPLAY:-}" ]] && return 0
    command -v sway >/dev/null 2>&1
}

prompt_terminal() {
    [[ -n "$TERMINAL_CHOICE" ]] && return

    if [[ $ASSUME_YES -eq 1 || ! -t 0 ]]; then
        TERMINAL_CHOICE="none"
        info "No terminal specified and not interactive; skipping terminal config."
        return
    fi

    echo "Which terminal do you want to configure?"
    echo "  1) Ghostty"
    echo "  2) Alacritty"
    echo "  3) None"
    local choice
    read -rp "Enter your choice [1-3]: " choice
    case "$choice" in
        1) TERMINAL_CHOICE="ghostty" ;;
        2) TERMINAL_CHOICE="alacritty" ;;
        *) TERMINAL_CHOICE="none" ;;
    esac
}

# =========================================================
# Linking
# =========================================================
run() {
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "  would run: $*"
    else
        "$@"
    fi
}

backup_destination() {
    local dest="$1" rel="$2"
    local target="$BACKUP_DIR/$rel"
    run mkdir -p "$(dirname -- "$target")"
    run mv -- "$dest" "$target"
    record BACKED_UP "$rel"
}

link_one() {
    local src="$1" dest="$2" rel="$3"

    if [[ ! -e "$src" ]]; then
        fail "missing source: ${src#"$DOTFILES_DIR"/}"
        record MISSING "${src#"$DOTFILES_DIR"/} -> ~/$rel"
        return
    fi

    # Already pointing where it should — nothing to do.
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        record UNCHANGED "~/$rel"
        return
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ $ASSUME_YES -eq 1 ]]; then
            backup_destination "$dest" "$rel"
        else
            local confirm
            read -rp "~/$rel exists. Back it up and replace with a symlink? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                backup_destination "$dest" "$rel"
            else
                warn "skipped ~/$rel"
                record SKIPPED "~/$rel"
                return
            fi
        fi
    fi

    run mkdir -p "$(dirname -- "$dest")"
    run ln -sfn "$src" "$dest"
    ok "linked ~/$rel"
    record LINKED "~/$rel"
}

scope_is_active() {
    # Space-delimited membership test; portable to bash 3.2.
    case " $ACTIVE_SCOPES " in
        *" $1 "*) return 0 ;;
        *) return 1 ;;
    esac
}

apply_manifest() {
    ACTIVE_SCOPES="common"
    if detect_wayland; then
        ACTIVE_SCOPES="$ACTIVE_SCOPES wayland"
        info "Wayland session detected; including sway/waybar/mako."
    else
        info "No Wayland session; skipping sway/waybar/mako."
    fi
    if [[ "$TERMINAL_CHOICE" != "none" && -n "$TERMINAL_CHOICE" ]]; then
        ACTIVE_SCOPES="$ACTIVE_SCOPES $TERMINAL_CHOICE"
    fi

    local scope src dest rest
    while read -r scope src dest rest || [[ -n "${scope:-}" ]]; do
        case "${scope:-}" in ""|\#*) continue ;; esac
        if [[ -z "${dest:-}" ]]; then
            warn "malformed manifest line for scope '$scope'; expected 3 columns"
            continue
        fi
        if ! scope_is_active "$scope"; then
            record SKIPPED "~/$dest (scope: $scope)"
            continue
        fi
        link_one "$DOTFILES_DIR/$src" "$HOME/$dest" "$dest"
    done <"$MANIFEST"
}

# =========================================================
# Extras the configs depend on
# =========================================================

# tmux.conf ends with `run '~/.tmux/plugins/tpm/tpm'`, so without TPM every
# plugin line is silently inert.
install_tpm() {
    if [[ -d "$TPM_DIR" ]]; then
        ok "tmux plugin manager already present"
        return
    fi
    if ! command -v git >/dev/null 2>&1; then
        warn "git not found; skipping tmux plugin manager"
        return
    fi
    info "Installing tmux plugin manager..."
    if run git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
        ok "tmux plugin manager installed (press prefix + I in tmux to fetch plugins)"
    else
        warn "could not clone tpm"
    fi
}

# .gitconfig includes ~/.gitconfigs/personal.gitconfig, which is intentionally
# not in the repo. Without it git errors on every command in ~/projects/personal.
scaffold_git_identities() {
    local target="$HOME/.gitconfigs/personal.gitconfig"
    if [[ -e "$target" ]]; then
        ok "git identity ~/.gitconfigs/personal.gitconfig present"
        return
    fi

    info "Creating $target"
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "  would create: $target"
        return
    fi
    mkdir -p "$(dirname -- "$target")"
    cat >"$target" <<'EOF'
# Per-context git identity, deliberately not tracked in the dotfiles repo.
[user]
	name = Mathias Wouters
	email = CHANGE_ME@example.com
EOF
    warn "Set your real address in $target"
}

# =========================================================
# Main
# =========================================================
main() {
    parse_args "$@"

    if [[ ! -f "$MANIFEST" ]]; then
        fail "Link manifest not found at $MANIFEST"
        exit 1
    fi

    section "Deploying dotfiles from $DOTFILES_DIR"
    [[ $DRY_RUN -eq 1 ]] && warn "Dry run: no changes will be made."

    prompt_terminal
    apply_manifest

    section "Dependencies of the linked configs"
    install_tpm
    scaffold_git_identities

    print_summary || exit 1

    echo "Done. Restart your terminal or run: exec zsh"
}

main "$@"
