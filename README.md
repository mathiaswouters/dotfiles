# My Dotfiles

A streamlined, lightweight dotfiles configuration tailored to work seamlessly across macOS, Linux distributions (Fedora, Arch, Debian/Ubuntu), and WSL.

**New to the Sway desktop?** Keybindings and how the layers nest: [CHEATSHEET.md](CHEATSHEET.md).

## System Dependencies

The `.zshrc` relies on several modern command-line utilities. Install them for your OS with `scripts/dependencies.sh`:

- **Zsh**
- **Starship**
- **Neovim**
- **Tmux**
- **Fzf**
- **Zoxide**
- **Fd**
- **Bat**
- **Ripgrep**
- **Lf**

## Installation

1. Clone this repository:

```bash
git clone https://github.com/mathiaswouters/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Install the packages the configs expect:

```bash
./scripts/dependencies.sh
```

3. Link the configs into place:

```bash
./scripts/setup.sh
```

`setup.sh` finds the repo from its own location, so the checkout does not have to be `~/dotfiles` — heimora clones it to `~/.dotfiles` and runs the same script logic against it.

### setup.sh options

| Flag | Effect |
|------|--------|
| `--terminal <ghostty\|alacritty\|none>` | Which terminal config to link. Prompts when omitted. |
| `--wayland` / `--no-wayland` | Override Wayland autodetection. |
| `-y`, `--yes` | Never prompt. Conflicting files are backed up, not skipped. |
| `-n`, `--dry-run` | Print what would happen and change nothing. |

Re-running is safe. A symlink that already points at the right place is left alone, and anything else sitting on a destination is moved to `~/.dotfiles-backup/<timestamp>/` rather than deleted.

```bash
./scripts/setup.sh --dry-run          # see the plan first
./scripts/setup.sh --terminal ghostty --yes
```

## What gets linked

[`links.conf`](links.conf) is the single source of truth. It maps a source in this repo to a destination under `$HOME`, tagged with a scope:

| Scope | When it applies |
|-------|-----------------|
| `common` | Everywhere. |
| `wayland` | Only in a Wayland/Sway session. Skipped on macOS and WSL. |
| `ghostty` / `alacritty` | Whichever terminal you select. |

Two things read that file, which is why they cannot disagree:

- `scripts/setup.sh`, for any machine you set up by hand.
- the `dotfiles` Ansible role in [heimora](https://github.com/mathiaswouters/heimora), which provisions Fedora + Sway.

Adding a config means adding a directory here and one line to `links.conf` — nothing in heimora needs to change.

## Repository Architecture

- `zsh/`: Shell parameters, plugins, keybindings, and system-detection rules.
- `git/`: Global git config. Identities are per-directory, see below.
- `starship/`: Prompt configuration, linked to `~/.config/starship/starship.toml` (`.zshrc` points `STARSHIP_CONFIG` there).
- `nvim/`: Neovim config in Lua, using the Lazy plugin manager.
- `tmux/`: Terminal multiplexer config, keybindings, and helper scripts.
- `lf/`: Keyboard-driven terminal file browser.
- `sway/`, `waybar/`, `mako/`: Wayland session — compositor, status bar, notifications. Catppuccin Mocha throughout.
- `alacritty/`, `ghostty/`: GPU-accelerated terminal emulator profiles.
- `scripts/`: `dependencies.sh` installs packages, `setup.sh` links configs.

## Git identities

`git/.gitconfig` commits a deliberately **invalid** `user.email`, so a commit made outside a known project directory fails loudly instead of landing with the wrong name on it. Real addresses live in `~/.gitconfigs/*.gitconfig`, which are never tracked here.

`setup.sh` scaffolds `~/.gitconfigs/personal.gitconfig` on a new machine; fill in your address. To add a work context, drop a file next to it and reference it from `git/.gitconfig`:

```gitconfig
[includeIf "gitdir:~/projects/<context>/"]
        path = ~/.gitconfigs/<context>.gitconfig
```

## Machine-specific Sway settings

Monitor layout and input tweaks differ per machine, so `sway/config` loads `~/.config/sway-local/*.conf` last and lets it win. That path is intentionally outside `~/.config/sway`, which is a symlink into this repo. A VM needs nothing there; a laptop might want:

```
output eDP-1 scale 1.5
output DP-3 position 0,0
```

## Notes

- **tmux plugins**: `setup.sh` installs TPM to `~/.tmux/plugins/tpm`. Press `prefix + I` (prefix is `Ctrl+A`) inside tmux to fetch the plugins listed in `tmux/tmux.conf`.
- **zsh plugins**: `.zshrc` clones its own plugins into `~/.config/zsh/plugins` on first start, so the first shell after install needs network. Run `zplugin-update` to update them.
- **Fonts**: the terminal, bar and notification configs all ask for JetBrains Mono. Install it from your package manager (`jetbrains-mono-fonts` on Fedora) or the font will silently fall back.
