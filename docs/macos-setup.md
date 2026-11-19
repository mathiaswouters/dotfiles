# macOS Setup

## Inspiration

- [DevOps Toolbox YouTube](https://www.youtube.com/@devopstoolbox/videos)
- [DevOps Toolbox dotfiles](https://github.com/omerxx/dotfiles)
- [Sin-cy dotfiles](https://github.com/Sin-cy/dotfiles/tree/main)

---

## 1. Installation

### 1.1 Bootstrap

```bash
# Install command-line tools
xcode-select --install || true

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
echo >> /Users/$USER/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> /Users/$USER/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
```

### 1.2 Install apps and packages

```bash
# GUI Apps
brew install --cask brave-browser
brew install --cask ghostty
brew install --cask bitwarden
brew install --cask obsidian
brew install --cask nordvpn
brew install --cask cap
brew install --cask iina
brew install --cask logi-options+
brew install --cask raycast
brew install --cask vorssaint
brew install --cask macshot
brew install --cask spotify
brew install --cask visual-studio-code
brew install --cask zed
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask nikitabobko/tap/aerospace

# Terminal - CLI utilities
brew install zsh
brew install wget
brew install tree
brew install tmux
brew install starship
brew install neovim
brew install fastfetch
brew install stow
brew install jq
brew install yq
brew install ripgrep
brew install fd
brew install fzf
brew install atuin
brew install eza
brew install bat
brew install zoxide
brew install superfile

# Dev tools
brew install git
brew install mise
brew install docker
brew install docker-compose
brew install podman
brew install podman-compose
brew install colima
brew install kubernetes-cli
brew install helm
brew install talosctl

# IaC
brew tap hashicorp/tap && brew install hashicorp/tap/terraform
brew install opentofu
brew install ansible

# Cloud CLIs
brew install awscli
brew install --cask azure-cli
brew install --cask gcloud-cli
```

```
jq        # JSON processor
yq        # YAML processor
ripgrep   # Grep alternative
fd        # Find alternative
fzf       # Fuzzy finder
atuin     # Shell history
eza       # ls replacement
bat       # cat replacement
zoxide    # cd replacement
superfile # Terminal file manager
```

---

## 2. Configuration

- Cleanup dock
- Open all apps and set everything up (like logging in) + customize dock

### 2.1 System Settings:

#### 2.1.1 General
- `AutoFill & Passwords` --> Disable `AutoFill from Passwords`
- `Login Items & Extensions`:
  - AeroSpace
  - macshot
  - Raycast
  - Vorssaint

#### 2.1.2 Desktop & Dock
- Make Dock size smaller
- Enable: `Minimize windows into application icon`
- Enable: `Automatically hide and show the Dock`
- Disable: `Animate opening applications`
- Disable: `Show suggested and recent apps in Dock`
- Disable: `Show items On Desktop`
- Change: `Click wallpaper to show desktop` to `Only in Stage Manager`
- Disable: `Show recent apps in Stage Manager`
- Disable: `Show Widgets On Desktop` & `Show Widgets In Stage Manager`
- Change: `Default web browser to Brave`

#### 2.1.3 Menu Bar
- Customize Menu Bar
- ...
- Battery -> Show percentage ???

#### 2.1.4 Wallpaper
- Change wallpaper

#### 2.1.5 Notifications
- Configure everything

#### 2.1.6 Mouse
- Disable `Natural scrolling`

### 2.2 Finder
- Top bar --> View --> Show Path Bar + Show Status Bar
- Create `Developer` folder

Open finder settings: `COMMAND + ,`
- Show these items on the desktop: `none`
- New Finder windows show: `mathias`
- Turn off all tags
- Customize sidebar
- Enable following advanced setting: `Show all filename extensions`
- Keep folders on top: `In windows when sorting by name`
- When performing a search: `Search the Current Folder`

### 2.3 Development Environment

#### 2.3.1 SSH

- GitHub:
  - Generate SSH key: `ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519_github`
  - Add SSH key to GitHub
  - Test connection: `ssh -T git@github.com`

- Homelab:
  - Generate SSH key: `ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519_homelab`

- Configure `~/.ssh/config`:
  ```
  # Personal GitHub
  Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes

  # Homelab Server
  Host homelab
    HostName 192.168.1.50          # Replace with your homelab IP or domain
    User your_username             # Replace with your homelab username
    IdentityFile ~/.ssh/id_ed25519_homelab
    IdentitiesOnly yes
  ```

#### 2.3.2 Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global init.defaultBranch main
git config --global core.editor nvim
git config --global pull.rebase false
```

#### 2.3.3 ...
- dotfiles
- terminal

### 2.3.4 Start Colima & Docker
```bash
colima start
```

### 2.3.5 Start the Podman machine
```bash
podman machine init
podman machine start

# verify podman
podman info
```

### 2.4 App configuration
- **Brave**: make brave default browser
- **VS Code**:
  - use JetBrains mono as font
  - ...