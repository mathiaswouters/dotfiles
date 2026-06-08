# My Dotfiles

A streamlined, lightweight dotfiles configuration tailored to work seamlessly across macOS, Linux distributions (Fedora, Arch, Debian/Ubuntu), and WSL.

## System Dependencies

Your `.zshrc` configuration relies on several modern command-line utilities. Before running the setup script, ensure these are installed via your package manager:

| Tool | macOS (`brew`) | Fedora (`dnf`) | Arch (`pacman`) | Debian/Ubuntu (`apt`) |
| :--- | :--- | :--- | :--- | :--- |
| **Zsh** | Built-in / `zsh` | `zsh` | `zsh` | `zsh` |
| **Starship** | `starship` | `starship` | `starship` | *See note below* |
| **Neovim** | `neovim` | `neovim` | `neovim` | `neovim` |
| **Tmux** | `tmux` | `tmux` | `tmux` | `tmux` |
| **Fzf** | `fzf` | `fzf` | `fzf` | `fzf` |
| **Zoxide** | `zoxide` | `zoxide` | `zoxide` | `zoxide` |
| **Fd** | `fd` | `fd-find` | `fd` | `fd-find` |
| **Bat** | `bat` | `bat` | `bat` | `bat` |
| **Eza** | `eza` | `eza` | `eza` | `eza` |
| **Ripgrep** | `ripgrep` | `ripgrep` | `ripgrep` | `ripgrep` |
| **Lf** | `lf` | `lf` | `lf` | *See note below* |

> ⚠️ **Debian/Ubuntu Notes:** 
> * **Starship:** Install via `curl -sS https://starship.rs/install.sh | sh`
> * **Lf:** Best installed manually via the official binary releases on GitHub or via Go.
> * **Eza:** Requires adding the official eza gpg/apt repository before running `apt install eza`.

## Installation

1. Clone this repository directly into your home directory:
```bash
   git clone [https://github.com/mathiaswouters/dotfiles.git](https://github.com/mathiaswouters/dotfiles.git) ~/dotfiles
   cd ~/dotfiles
```

2. Run the deployment script to safely symlink all configuration files to their appropriate targets:
```bash
   ./setup.sh
```

## Repository Architecture

- `zsh/`: Main shell parameters, configuration, and internal system-detection rules.
- `starship/`: Visual prompt configuration (placed globally into ~/.config/starship.toml).
- `nvim/`: Text-editor workspace configurations using Lua and the Lazy plugin manager.
- `tmux/`: Persistent terminal environment setups and custom workspace bindings.
- `lf/`: Keyboard-driven terminal file browser parameters.
- `alacritty/ & ghostty/`: GPU-accelerated graphical terminal emulator profiles.

Whenever you pull this repo onto a brand-new laptop, server, or WSL instance, installing your dependencies and typing `./setup.sh` will completely restore your entire environment instantly.
