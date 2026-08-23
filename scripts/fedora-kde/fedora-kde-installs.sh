#!/bin/bash

# Ensure dnf plugins and basic tools are present
sudo dnf install -y dnf-plugins-core curl wget

# Enable RPM Fusion (needed for obs-studio and multimedia)
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Enable COPR Repositories
sudo dnf copr enable -y atim/starship
sudo dnf copr enable -y pennbauman/ports
sudo dnf copr enable -y scottames/ghostty
sudo dnf copr enable -y alois-has-neurons/caligula

# VS Code Repository
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# Cursor Repository
sudo tee /etc/yum.repos.d/cursor.repo << 'EOF'
[cursor]
name=Cursor
baseurl=https://downloads.cursor.com/yumrepo
enabled=1
gpgcheck=1
gpgkey=https://downloads.cursor.com/keys/anysphere.asc
EOF

# Sublime Text Repository
sudo dnf config-manager addrepo --from-repofile=https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo

# HashiCorp (Terraform) Repository
wget -O- https://rpm.releases.hashicorp.com/fedora/hashicorp.repo | sudo tee /etc/yum.repos.d/hashicorp.repo

# Docker CE Repository
sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo

# Kubernetes (kubectl) Repository
sudo sh -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
EOF'

# Install DNF packages
sudo dnf install -y \
  vim git tmux zsh htop btop unzip tar rsync firewalld \
  NetworkManager-wifi iwd bluez bluez-tools pciutils \
  ghostty alacritty neovim fastfetch starship fzf ripgrep fd-find \
  bat jq zoxide lf imv file-roller gvfs sublime-text caligula obs-studio \
  code cursor nodejs npm python3 python3-pip python3-devel golang \
  ansible-core terraform kubectl \
  docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  steam lutris gamemode gamemode.i686 mangohud mangohud.i686 vulkan-tools protontricks

# Bitwarden Desktop RPM
sudo dnf install -y "https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=rpm"

# Install NordVPN
sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh) -p nordvpn-gui

# Enable Flathub remote
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Spotify
flatpak install -y flathub com.spotify.Client

# Enable and start Docker service, add user to docker group
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
