#!/bin/bash

# COPRs, enabled in the apps role. Fedora proper ships none of these.
copr_repos:
  - atim/starship
  - pennbauman/ports           # lf
  - scottames/ghostty          # the source Ghostty's own docs point at
  - alois-has-neurons/caligula # caligula

base_packages:
  - vim                    # modal text editor
  - git                    # version control
  - curl                   # HTTP/transfer client
  - wget                   # file downloader
  - tmux                   # terminal multiplexer
  - zsh                    # interactive shell
  - htop                   # interactive process viewer
  - btop                   # resource monitor TUI
  - unzip                  # zip archive extractor
  - tar                    # archive utility
  - rsync                  # file sync and copy
  - firewalld              # firewall daemon
  - dnf-plugins-core       # extra dnf commands (copr, config-manager, …)
  - NetworkManager-wifi    # Wi-Fi plugin for NetworkManager
  - iwd                    # wireless daemon (NetworkManager backend)
  - bluez                  # Bluetooth stack
  - bluez-tools            # Bluetooth CLI helpers
  - pciutils               # lspci / PCI device info

# General desktop / productivity apps — placeholder list, prune to taste
app_packages:
  - firefox                  # web browser
  - ghostty                  # GPU terminal (scottames COPR)
  - alacritty                # GPU terminal emulator
  - neovim                   # modal text editor
  - fastfetch                # system info banner
  - starship                 # cross-shell prompt
  - fzf                      # fuzzy finder
  - ripgrep                  # fast recursive grep (rg)
  - fd-find                  # fast find (fd)
  - bat                      # cat with syntax highlighting
  - jq                       # JSON processor
  - zoxide                   # smarter cd (learns directories)
  - lf                       # terminal file manager (pennbauman/ports COPR)
  - imv                      # image viewer (Wayland-friendly)
  - file-roller              # archive GUI used by the Thunar plugin
  - gvfs                     # virtual FS (trash, mounts, GVFS backends)
  - geany                    # lightweight GUI editor
  - caligula                 # disk image writer (alois-has-neurons/caligula COPR)
  - obs-studio               # screen recording / streaming (RPM Fusion)
  - code                     # Visual Studio Code (Microsoft repo)
  - cursor                   # AI code editor (Anysphere yum repo)
  - nordvpn                  # NordVPN CLI + daemon
  - nordvpn-gui              # official NordVPN GUI (same repo)
  - nodejs                   # JavaScript runtime
  - npm                      # Node package manager
  - python3                  # Python interpreter
  - python3-pip              # Python package installer
  - python3-devel            # headers for compiling Python extensions
  - golang                   # Go compiler and toolchain
  - bitwarden_rpm_url

# Not in Fedora/RPM Fusion. Flathub is added by the apps role.
flatpak_apps:
  - com.spotify.Client       # Spotify desktop client

# Cloud/DevOps tooling relevant to your day job — extend freely
devops_packages:
  - ansible-core             # Ansible (no extra collections)
  - terraform                # IaC CLI (HashiCorp repo, enabled in base)
  - kubectl                  # Kubernetes CLI (k8s.io repo, enabled in base)
  - docker-ce                # Docker Engine (Docker Inc. repo, enabled in base)
  - docker-ce-cli            # Docker CLI
  - containerd.io            # container runtime used by Docker
  - docker-buildx-plugin     # BuildKit / docker buildx
  - docker-compose-plugin    # docker compose v2 plugin

# GTX 1060 is Pascal. NVIDIA 595+ (Fedora 44's default akmod-nvidia) dropped
# it; RPM Fusion's 580xx branch is the last that works. Turing+ would use
# unsuffixed akmod-nvidia instead. The nvidia role only installs these when
# lspci finds an NVIDIA GPU, so a VM without passthrough skips them.
nvidia_packages:
  - kernel-devel                             # headers for building the NVIDIA kmod
  - akmods                                   # rebuilds kmods after kernel updates
  - akmod-nvidia-580xx                       # NVIDIA kernel module (Pascal 580xx)
  - xorg-x11-drv-nvidia-580xx                # NVIDIA userspace driver
  - xorg-x11-drv-nvidia-580xx-cuda           # CUDA userspace (580xx)
  - xorg-x11-drv-nvidia-580xx-cuda-libs      # CUDA libraries (580xx)
  - xorg-x11-drv-nvidia-580xx-libs.i686      # 32-bit NVIDIA libs (Steam / Proton)
  - vulkan-loader                            # Vulkan ICD loader
  - libva-nvidia-driver                      # VA-API via NVIDIA (NVDEC)
  - libva-utils                              # vainfo and other VA-API tools

gaming_packages:
  - steam                    # game store and launcher
  - lutris                   # launcher for non-Steam / Wine games
  - gamemode                 # CPU/GPU tweaks while a game is running
  - gamemode.i686            # 32-bit GameMode (Proton / older titles)
  - mangohud                 # in-game FPS / overlay
  - mangohud.i686            # 32-bit MangoHud
  - vulkan-tools             # vulkaninfo, vkcube
  - protontricks             # winetricks for Steam Proton prefixes
