# My Dotfiles

A streamlined, lightweight dotfiles configuration tailored to work seamlessly across macOS, Linux distributions (Fedora, Arch, Debian/Ubuntu), and WSL.

## System Dependencies

Your `.zshrc` configuration relies on several modern command-line utilities. Before running the setup script, ensure these are installed by running the `dependencies.sh` script:

- **Zsh**
- **Starship**
- **Neovim**
- **Tmux**
- **Fzf**
- **Zoxide**
- **Fd**
- **Bat**
- **Eza**
- **Ripgrep**
- **Lf**

## Installation

1. Clone this repository directly into your home directory:
```bash
   git clone [https://github.com/mathiaswouters/dotfiles.git](https://github.com/mathiaswouters/dotfiles.git) ~/dotfiles
   cd ~/dotfiles
```

2. Run the dependencies script to install all required packages for your specific OS:
```bash
   ./scripts/setup.sh
```

3. Run the deployment script to safely symlink all configuration files to their appropriate targets:
```bash
   ./scripts/setup.sh
```

## Repository Architecture

- `zsh/`: Main shell parameters, configuration, and internal system-detection rules.
- `starship/`: Visual prompt configuration (placed globally into ~/.config/starship.toml).
- `nvim/`: Text-editor workspace configurations using Lua and the Lazy plugin manager.
- `tmux/`: Persistent terminal environment setups and custom workspace bindings.
- `lf/`: Keyboard-driven terminal file browser parameters.
- `alacritty/ & ghostty/`: GPU-accelerated graphical terminal emulator profiles.

Whenever you pull this repo onto a brand-new laptop, server, or WSL instance, installing your dependencies and typing `./setup.sh` will completely restore your entire environment instantly.
