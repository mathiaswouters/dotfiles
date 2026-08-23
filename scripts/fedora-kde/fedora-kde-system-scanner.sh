#!/bin/bash
#
# Fedora KDE Bloat Scanner
# Scans a Fedora (especially KDE Plasma) system for potentially removable
# packages, services, apps, and other "bloat". Produces a clear Markdown report.
#
# SAFE: This script only READS and reports. It never removes or modifies anything.
#
# Usage:
#   chmod +x fedora-kde-system-scanner.sh
#   ./fedora-kde-system-scanner.sh
#   # or: bash fedora-kde-system-scanner.sh
#
# Output: ~/fedora-kde-system-scan-YYYYMMDD-HHMMSS.md
#

set -euo pipefail

# ---------- Config ----------
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT="./fedora-kde-system-scan-${TIMESTAMP}.md"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Common optional / frequently-removed packages on Fedora KDE
# (gathered from community debloat lists; review carefully before removing)
BLOAT_CANDIDATES=(
  # PIM / Akonadi suite
  akregator kmail kontact korganizer kaddressbook ktnef
  akonadi-import-wizard akonadi-server mariadb-server mariadb
  # Games
  kmines kmahjongg kpat kdegames
  # Media players / camera
  elisa-player dragon kamoso
  # Accessibility / tools many never use
  kmag kmousetool kmouth kcharselect kcolorchooser
  # Remote / sharing
  krdc krfb konversation kdeconnect
  # Office / docs (huge)
  libreoffice libreoffice-core libreoffice-writer libreoffice-calc
  libreoffice-impress libreoffice-draw libreoffice-math libreoffice-langpack-en
  # Other common optional apps
  mediawriter kolourpaint kfind kgpg qt5-qdbusviewer qt6-qdbusviewer
  dnfdragora plasma-discover  # Discover is useful for Flatpaks; keep if you use it
  # Help / crash reporting
  khelpcenter yelp abrt abrt-desktop gnome-abrt plasma-drkonqi
  # Misc
  im-chooser system-config-language firewall-config
  orca kamera zenity
  # X11 leftovers if you are Wayland-only
  kwin-x11 sddm-x11 plasma-workspace-x11
  # Guest / VM agents (safe to remove on bare metal)
  qemu-guest-agent spice-vdagent hyperv-daemons
  # Other
  plymouth  # boot splash; optional
)

# Services that are often safe to disable on a desktop/gaming machine
# (always research first!)
SERVICE_CANDIDATES=(
  abrt-journal-core.service
  abrt-oops.service
  abrt-xorg.service
  abrtd.service
  livesys.service
  livesys-late.service
  ModemManager.service          # only if no modem
  bluetooth.service             # only if you never use BT
  cups.service                  # only if no printer
  cups-browsed.service
  avahi-daemon.service          # mDNS; optional
  packagekit.service
  dnf-makecache.timer
  fstrim.timer                  # keep if SSD!
  plymouth-quit-wait.service
)

# ---------- Helpers ----------
section() {
  echo ""
  echo "## $1"
  echo ""
}

codeblock() {
  echo '```'
  cat
  echo '```'
}

have() { command -v "$1" &>/dev/null; }

pkg_installed() {
  rpm -q "$1" &>/dev/null
}

# ---------- Start report ----------
{
  echo "# Fedora KDE Bloat Scan Report"
  echo ""
  echo "**Generated:** $(date)"
  echo "**Hostname:** $(hostname)"
  echo "**User:** $(whoami)"
  echo ""
  echo "> **Safety note:** This report only *suggests* candidates.  "
  echo "> Always check dependencies with \`dnf remove --assumeno <pkg>\` or \`rpm -q --whatrequires <pkg>\` before removing anything.  "
  echo "> Critical Plasma components (plasma-*, kwin, sddm, dolphin, konsole, kwallet, etc.) should normally stay."
  echo ""

  # ===== 1. System overview =====
  section "1. System Overview"
  {
    echo "- **OS:** $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
    echo "- **Kernel:** $(uname -r)"
    echo "- **Desktop session:** ${XDG_CURRENT_DESKTOP:-unknown} / ${XDG_SESSION_TYPE:-unknown}"
    echo "- **Architecture:** $(uname -m)"
    if have free; then
      echo "- **Memory:** $(free -h | awk '/^Mem:/{print $2 " total, " $3 " used"}')"
    fi
    echo "- **Root filesystem:** $(df -h / | awk 'NR==2{print $2 " total, " $3 " used (" $5 ")"}')"
    echo "- **Package count (rpm):** $(rpm -qa | wc -l)"
  }

  # ===== 2. Installed package groups =====
  section "2. Installed DNF Groups (high-level)"
  echo "These groups often pull in many optional packages. Removing a group removes its members (if nothing else depends on them)."
  echo ""
  if have dnf; then
    dnf group list --installed 2>/dev/null | sed 's/^/    /' || echo "_Could not list groups (try with sudo or dnf5)._"
  else
    echo "_dnf not found_"
  fi

  # ===== 3. User-installed packages =====
  section "3. Explicitly User-Installed Packages"
  echo "Packages marked as user-installed (not pure dependencies). Review these first."
  echo ""
  if have dnf; then
    # Works on both dnf4 and dnf5 in most cases
    (dnf repoquery --userinstalled --qf '%{name}' 2>/dev/null || \
     dnf history userinstalled 2>/dev/null || \
     echo "(command not available)") | sort -u | head -100 | sed 's/^/- /' || true
    echo ""
    echo "_Showing up to 100. Full list: \`dnf repoquery --userinstalled\`_"
  fi

  # ===== 4. Largest installed packages =====
  section "4. Largest Installed Packages (top 40 by size)"
  echo "Size is approximate installed size from RPM database."
  echo ""
  rpm -qa --queryformat '%{SIZE} %{NAME}\n' 2>/dev/null | \
    sort -nr | head -40 | \
    awk '{ printf "- **%s** — %.1f MiB\n", $2, $1/1024/1024 }' || echo "_rpm query failed_"

  # ===== 5. Potential bloat packages =====
  section "5. Potential Bloat / Optional Packages Found"
  echo "These are commonly removed on minimal Fedora KDE setups. **Not all should be removed** — pick only what you don't need."
  echo ""
  FOUND=0
  for pkg in "${BLOAT_CANDIDATES[@]}"; do
    # Handle globs roughly
    if [[ "$pkg" == *\** ]]; then
      matches=$(rpm -qa "$pkg" 2>/dev/null || true)
      if [[ -n "$matches" ]]; then
        echo "- \`$pkg\` → present:"
        echo "$matches" | sed 's/^/  - /'
        FOUND=1
      fi
    else
      if pkg_installed "$pkg"; then
        size=$(rpm -q --queryformat '%{SIZE}' "$pkg" 2>/dev/null || echo 0)
        size_m=$(awk "BEGIN {printf \"%.1f\", $size/1024/1024}")
        echo "- **$pkg** (${size_m} MiB) — installed"
        FOUND=1
      fi
    fi
  done
  if [[ $FOUND -eq 0 ]]; then
    echo "_None of the common candidate packages were found (already lean?)._"
  fi
  echo ""
  echo "**Suggested review command (dry-run):**"
  echo '```bash'
  echo 'sudo dnf remove --assumeno <package1> <package2> ...'
  echo 'sudo dnf autoremove --assumeno'
  echo '```'

  # ===== 6. Services =====
  section "6. Enabled Systemd Services"
  echo "Services set to start at boot. Review anything you don't recognize."
  echo ""
  systemctl list-unit-files --type=service --state=enabled --no-pager --no-legend 2>/dev/null | \
    awk '{print "- `" $1 "`"}' || echo "_systemctl failed_"

  echo ""
  section "6b. Currently Running Services"
  systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | \
    awk '{print "- `" $1 "` — " substr($0, index($0,$5))}' || echo "_systemctl failed_"

  echo ""
  section "6c. Candidate Services Often Disabled on Desktop/Gaming PCs"
  echo "Only disable after confirming you don't need them (e.g. keep bluetooth if you use it, cups if you print, etc.)."
  echo ""
  for svc in "${SERVICE_CANDIDATES[@]}"; do
    if systemctl is-enabled "$svc" &>/dev/null; then
      state=$(systemctl is-enabled "$svc" 2>/dev/null || echo "unknown")
      active=$(systemctl is-active "$svc" 2>/dev/null || echo "unknown")
      echo "- **$svc** — enabled=$state, active=$active"
    fi
  done

  # ===== 7. Flatpak / Snap / AppImage =====
  section "7. Flatpak, Snap, and Other Runtimes"
  if have flatpak; then
    echo "### Flatpaks"
    echo ""
    flatpak list --columns=application,name,size 2>/dev/null | sed 's/^/    /' || echo "    (none or error)"
    echo ""
    echo "Unused runtimes can be cleaned with: \`flatpak uninstall --unused\`"
  else
    echo "- Flatpak: not installed"
  fi
  if have snap; then
    echo ""
    echo "### Snaps"
    snap list 2>/dev/null | sed 's/^/    /' || true
  else
    echo "- Snap: not installed"
  fi

  # ===== 8. Desktop applications (menu entries) =====
  section "8. Desktop Applications (from .desktop files)"
  echo "Applications visible in the application menu. Useful to spot unused GUI apps."
  echo ""
  find /usr/share/applications ~/.local/share/applications -name '*.desktop' 2>/dev/null | \
    while read -r f; do
      name=$(grep -m1 '^Name=' "$f" 2>/dev/null | cut -d= -f2- || basename "$f")
      echo "- $name (\`$(basename "$f")\`)"
    done | sort -u | head -80
  echo ""
  echo "_Showing up to 80 unique entries._"

  # ===== 9. Extra useful info =====
  section "9. Extra Useful Checks"
  echo "### Kernel modules / firmware (large ones)"
  rpm -qa 'kernel*' 'linux-firmware*' --queryformat '%{NAME}-%{VERSION} (%{SIZE} bytes)\n' 2>/dev/null | head -20 | sed 's/^/- /'
  echo ""
  echo "### Locale / language packs (can be huge)"
  rpm -qa '*langpack*' '*locale*' --queryformat '%{NAME}\n' 2>/dev/null | head -30 | sed 's/^/- /' || true
  echo ""
  echo "### Orphaned / unneeded packages (preview)"
  if have dnf; then
    dnf repoquery --unneeded 2>/dev/null | head -30 | sed 's/^/- /' || \
    dnf list --autoremove 2>/dev/null | head -30 | sed 's/^/- /' || \
    echo "_Run: sudo dnf autoremove --assumeno_"
  fi

  # ===== 10. Recommended next steps =====
  section "10. Recommended Next Steps (manual)"
  cat << 'EOF'
1. **Backup / snapshot** first (Timeshift, Btrfs snapshot, or just know you can reinstall).
2. Review section 5 and decide what you truly don't need.
3. Dry-run removals:
   ```bash
   sudo dnf remove --assumeno akregator kmail kontact korganizer kaddressbook \
     elisa-player dragon kamoso kmines kmahjongg kpat mediawriter \
     libreoffice-* kmag kmousetool kmouth
   ```
4. After successful dry-run, remove for real, then:
   ```bash
   sudo dnf autoremove
   sudo dnf clean all
   ```
5. For Akonadi-heavy cleanup (if you don't use KMail/Kontact):
   ```bash
   sudo dnf remove akonadi* pim*  # review carefully
   ```
6. Disable unneeded services (example):
   ```bash
   sudo systemctl disable --now abrtd.service
   ```
7. Consider switching to Fedora Kinoite (immutable, leaner KDE) or a netinstall + minimal KDE groups next time.
8. Gaming tip: keep Mesa, Vulkan, Steam, Proton, and GPU drivers. Remove guest agents if this is bare metal.

**Useful one-liners after cleanup:**
```bash
# See what would be removed by autoremove
sudo dnf autoremove --assumeno

# List remaining large packages
rpm -qa --queryformat '%{SIZE} %{NAME}\n' | sort -nr | head -20

# Vacuum old journals
sudo journalctl --vacuum-time=7d
```
EOF

  echo ""
  echo "---"
  echo "*Report generated by fedora-kde-system-scanner.sh — review carefully before acting.*"

} > "$REPORT"

echo "Scan complete!"
echo "Report written to: $REPORT"
echo ""
echo "Open it with:  less \"$REPORT\"   or   kate \"$REPORT\"   or any Markdown viewer."
ls -lh "$REPORT"
