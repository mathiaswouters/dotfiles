#!/usr/bin/env bash

# Color formatters
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
WARNINGS=0

pass() {
  echo -e "  [${GREEN}PASS${NC}] $1"
  ((PASSED++))
}

fail() {
  echo -e "  [${RED}FAIL${NC}] $1"
  ((FAILED++))
}

warn() {
  echo -e "  [${YELLOW}WARN${NC}] $1"
  ((WARNINGS++))
}

header() {
  echo -e "\n${BLUE}=== $1 ===${NC}"
}

# 1. Repositories Verification
header "Checking Configured Repositories"
REQUIRED_REPOS=(
  "rpmfusion-free"
  "rpmfusion-nonfree"
  "copr:copr.fedorainfracloud.org:atim:starship"
  "copr:copr.fedorainfracloud.org:pennbauman:ports"
  "copr:copr.fedorainfracloud.org:scottames:ghostty"
  "copr:copr.fedorainfracloud.org:alois-has-neurons:caligula"
  "code"
  "cursor"
  "hashicorp"
  "docker-ce-stable"
  "kubernetes"
)

ENABLED_REPOS=$(dnf repolist --enabled -q 2>/dev/null)
for repo in "${REQUIRED_REPOS[@]}"; do
  if echo "$ENABLED_REPOS" | grep -qi "$repo"; then
    pass "Repository enabled: $repo"
  else
    warn "Repository not explicitly listed in repolist: $repo"
  fi
done

# 2. CLI Tools & Binaries (Path Check)
header "Checking CLI Executables"
COMMANDS=(
  # Base Tools
  "curl" "wget" "git" "vim" "tmux" "zsh" "htop" "btop" "unzip" "tar" "rsync" "pciutils:lspci"
  # Dev & Shell Tools
  "fastfetch" "starship" "fzf" "rg" "fd" "bat" "jq" "zoxide" "lf" "nvim"
  # Programming Runtimes & Compilers
  "node" "npm" "python3" "pip3" "go"
  # DevOps & Containers
  "ansible" "terraform" "kubectl" "docker" "containerd"
  # Gaming & Performance Utilities
  "gamemoderun" "mangohud" "vulkaninfo" "vkcube" "protontricks"
  # System/Network CLI
  "firewall-cmd" "iwctl" "bluetoothctl" "caligula" "nordvpn"
)

for cmd_entry in "${COMMANDS[@]}"; do
  # Handle cases where package name != binary name (e.g. pciutils:lspci)
  if [[ "$cmd_entry" == *":"* ]]; then
    pkg="${cmd_entry%%:*}"
    binary="${cmd_entry##*:}"
  else
    pkg="$cmd_entry"
    binary="$cmd_entry"
  fi

  if command -v "$binary" >/dev/null 2>&1; then
    pass "Executable available: $binary ($pkg)"
  else
    fail "Executable missing: $binary ($pkg)"
  fi
done

# Check Docker plugins specifically
header "Checking Docker CLI Plugins"
if docker buildx version >/dev/null 2>&1; then
  pass "Docker plugin: buildx"
else
  fail "Docker plugin: buildx not detected"
fi

if docker compose version >/dev/null 2>&1; then
  pass "Docker plugin: compose"
else
  fail "Docker plugin: compose not detected"
fi

# 3. GUI Applications (RPMs / Desktop Files)
header "Checking GUI Applications"
GUI_PACKAGES=(
  "ghostty"
  "alacritty"
  "imv"
  "file-roller"
  "geany"
  "obs-studio"
  "code"
  "cursor"
  "bitwarden"
  "steam"
  "lutris"
  "nordvpn-gui"
)

for pkg in "${GUI_PACKAGES[@]}"; do
  if rpm -q "$pkg" >/dev/null 2>&1; then
    pass "RPM package installed: $pkg"
  else
    fail "RPM package missing: $pkg"
  fi
done

# 4. Multilib / 32-bit Gaming Libraries
header "Checking 32-bit (i686) Gaming Libraries"
I686_PKGS=(
  "gamemode.i686"
  "mangohud.i686"
)

for pkg in "${I686_PKGS[@]}"; do
  if rpm -q "$pkg" >/dev/null 2>&1; then
    pass "32-bit package installed: $pkg"
  else
    fail "32-bit package missing: $pkg"
  fi
done

# 5. Flatpak Verifications
header "Checking Flatpak Runtime & Applications"
if flatpak remotes | grep -q "flathub"; then
  pass "Flathub remote configured"
else
  fail "Flathub remote missing"
fi

if flatpak list --app | grep -q "com.spotify.Client"; then
  pass "Flatpak installed: Spotify (com.spotify.Client)"
else
  fail "Flatpak missing: Spotify (com.spotify.Client)"
fi

# 6. Services & Daemon States
header "Checking Daemons & Permissions"
SERVICES=("docker" "nordvpnd" "firewalld")

for svc in "${SERVICES[@]}"; do
  if systemctl is-active --quiet "$svc"; then
    pass "Service is running: $svc"
  else
    warn "Service is not active: $svc (Run: sudo systemctl start $svc)"
  fi

  if systemctl is-enabled --quiet "$svc"; then
    pass "Service is enabled on boot: $svc"
  else
    warn "Service is not enabled: $svc (Run: sudo systemctl enable $svc)"
  fi
done

# Check Docker group membership
if id -nG "$USER" | grep -qw "docker"; then
  pass "User '$USER' is in the 'docker' group"
else
  warn "User '$USER' is not in the active session's 'docker' group (a reboot or 'newgrp docker' is required)"
fi

# --- Final Summary ---
header "Validation Summary"
echo -e "  Passed:   ${GREEN}$PASSED${NC}"
echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
echo -e "  Failed:   ${RED}$FAILED${NC}\n"

if [ "$FAILED" -eq 0 ]; then
  echo -e "${GREEN}All critical installations and configurations verified successfully!${NC}"
  exit 0
else
  echo -e "${RED}Some packages or configurations are missing. Please inspect the failures above.${NC}"
  exit 1
fi
