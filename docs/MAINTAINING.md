# Maintaining this dotfiles repository

This guide explains how to keep the repository tidy as you add configuration files, applications, tools, and platform-specific setup.

## 1. Understand the layout

```text
dotfiles/
├── setup.sh                 # Main entrypoint, OS detection, and Stow deployment
├── bootstrap/
│   ├── macos.sh             # Homebrew, macOS applications, CLI tools, runtimes
│   ├── arch.sh              # Placeholder
│   ├── debian.sh            # Placeholder
│   └── fedora.sh            # Placeholder
├── aerospace/               # Stow package
├── ghostty/                 # Stow package
├── starship/                # Stow package
├── zsh/                     # Stow package
├── docs/                    # Documentation; not a Stow package
└── README.md
```

There are two separate responsibilities:

- **Bootstrap scripts** install software and perform operating-system setup.
- **GNU Stow packages** contain configuration files that should be linked into your home directory.

Keep those responsibilities separate. For example, Homebrew installs Ghostty; the `ghostty/` Stow package manages its configuration.

## 2. How GNU Stow packages work

Each top-level configuration directory is a Stow package. Its internal directory structure mirrors the paths that should exist under your home directory.

For example:

```text
zsh/
└── .zshrc
```

Stowing the `zsh` package creates:

```text
~/.zshrc -> <repository>/zsh/.zshrc
```

For configuration stored under `~/.config`, preserve that path inside the package:

```text
ghostty/
└── .config/
    └── ghostty/
        └── config
```

This becomes:

```text
~/.config/ghostty/config -> <repository>/ghostty/.config/ghostty/config
```

Do not put the literal home directory path (such as `home/username`) inside a package. The package root itself represents the home directory.

## 3. Add a file to an existing dotfile package

Use this when you want to manage another configuration file for an application that already has a package.

1. Find the correct package directory.
2. Recreate the file's path relative to your home directory inside that package.
3. Add or edit the configuration file in the repository.
4. Preview the Stow operation.
5. Apply it.

Example: adding a Ghostty configuration file:

```bash
mkdir -p ghostty/.config/ghostty
$EDITOR ghostty/.config/ghostty/config
./setup.sh --dotfiles-only --dry-run
./setup.sh --dotfiles-only
```

Because the destination is a symlink, editing the file through either the repository path or the linked home-directory path edits the same file.

If a configuration file already exists in your home directory and is not managed by Stow, Stow may report a conflict. Back it up and decide what to keep before proceeding. Do not blindly delete existing configuration.

## 4. Add a completely new dotfile package

Use a separate package when the configuration belongs to a distinct application or tool.

For example, to add Git configuration:

1. Create a package directory.
2. Put the desired home-directory files inside it.
3. Register the package in `setup.sh`.
4. Preview and apply Stow.

Example layout:

```text
git/
├── .gitconfig
└── .config/
    └── git/
        └── ignore
```

These files map to:

- `~/.gitconfig`
- `~/.config/git/ignore`

In `setup.sh`, find the `deploy_dotfiles()` function and add the package name to the appropriate package list:

```bash
packages=(zsh ghostty starship git)
if [[ "$OS_TYPE" == "macos" ]]; then
  packages+=(aerospace)
fi
```

If the package should only be deployed on macOS, add it to the macOS-specific list instead. If it should be deployed on every supported OS, add it to the common list.

Then run:

```bash
./setup.sh --dotfiles-only --dry-run
./setup.sh --dotfiles-only
```

**Important:** Creating a top-level directory does not automatically make it a Stow package. The package must be included in `setup.sh`'s explicit package list. This prevents folders such as `bootstrap/` and `docs/` from being stowed accidentally.

## 5. Add or remove macOS applications and CLI tools

The package lists live near the top of `bootstrap/macos.sh`.

- `TAPS`: additional Homebrew taps.
- `FORMULAE`: command-line tools and libraries installed with `brew install`.
- `CASKS`: GUI applications and cask-distributed tools installed with `brew install --cask`.
- `MISE_RUNTIMES`: language runtimes installed through Mise.

Add an item to the correct array. Keep one item per line and group related tools with comments.

Before adding a package:

1. Check its current installation name in the official [Homebrew Formulae](https://formulae.brew.sh/) website.
2. Check whether it is a formula or a cask; the arrays use different install commands.
3. Check platform and architecture requirements.
4. If it comes from a third-party tap, add that tap to `TAPS` before the package is installed.

For example:

```bash
FORMULAE=(
  # Existing tools...
  "ripgrep"
  "git"
  "new-cli-tool"
)

CASKS=(
  # Existing applications...
  "ghostty"
  "new-desktop-app"
)
```

The script checks whether each item is already installed before attempting installation. Installation failures stop the bootstrap so a partially completed setup is not reported as successful.

Remove an item from the relevant array when you no longer want the bootstrap to install it. Removing it from the array does **not** uninstall it from a machine where it is already installed.

### Mise runtimes

Add runtimes to `MISE_RUNTIMES`, using Mise's tool/version syntax, for example:

```bash
MISE_RUNTIMES=(
  "node@lts"
  "python@latest"
  "go@latest"
  "java@latest"
)
```

The current use of `latest` is convenient but not fully reproducible: a fresh setup at a later date may install a newer version. Pin a version when you need consistent environments.

## 6. Add or change OS-specific setup

The main entrypoint detects the operating system and selects one script from `bootstrap/`.

- macOS: `bootstrap/macos.sh`
- Arch: `bootstrap/arch.sh`
- Debian/Ubuntu: `bootstrap/debian.sh`
- Fedora: `bootstrap/fedora.sh`

When adding another supported distribution:

1. Create its bootstrap script.
2. Keep it responsible for OS-specific package installation and configuration only.
3. Add or update the OS detection and dispatch logic in `setup.sh`.
4. Do not add Stow deployment to the platform script. The main `setup.sh` owns that step.
5. Decide which dotfile packages are common and which are platform-specific.

Keep platform scripts safe to rerun where possible. Check whether a package or setting is already present before changing it, and make failures visible.

## 7. Test changes before applying them

Run these checks after editing shell scripts:

```bash
# Check shell syntax
bash -n setup.sh
bash -n bootstrap/macos.sh

# Preview bootstrap and dotfile operations
./setup.sh --dry-run

# Preview only dotfile links
./setup.sh --dotfiles-only --dry-run
```

If ShellCheck is installed, also run:

```bash
shellcheck setup.sh bootstrap/*.sh
```

A dry run is a preview, not a guarantee that every package will install successfully. It does not perform a full Homebrew installation test.

After reviewing the preview, run the relevant real command. For a normal workstation setup:

```bash
./setup.sh
```

## 8. Maintain existing Stow links

When you change a file already managed by Stow, the change is immediately reflected in the linked configuration file. You normally do not need to stow it again.

When you add, move, or remove files inside a package, re-stow that package so the links are reconciled:

```bash
stow --dir="$PWD" --target="$HOME" --restow zsh
```

To remove a package's managed links:

```bash
stow --dir="$PWD" --target="$HOME" --delete zsh
```

Replace `zsh` with the package name you intend to manage. Review the result before deleting or moving repository files.

## 9. Keep secrets and machine-specific state out of Git

Do not commit:

- API keys, passwords, access tokens, private keys, or certificates.
- Cloud credentials, kubeconfig files containing credentials, or authentication caches.
- Machine-specific generated state, caches, logs, and temporary files.
- Personal data that should not be present on every machine.

Prefer environment variables, an OS keychain, or a dedicated secrets manager for credentials. If a configuration needs a personal override, use an untracked local file and make the shared configuration support its optional presence.

If a secret is accidentally committed, removing it from the latest version is not enough: rotate the exposed credential and clean the Git history as appropriate.

## 10. Suggested maintenance workflow

For routine changes:

1. Pull the latest repository changes.
2. Create or edit the relevant package/configuration.
3. Update `setup.sh` if you created a new Stow package.
4. Update `bootstrap/macos.sh` if you added or removed a macOS application, formula, tap, or runtime.
5. Run syntax checks and the dry run.
6. Apply the relevant setup command.
7. Verify the application and configuration work.
8. Commit the change with a message describing what changed.

Keep this guide and the main `README.md` up to date whenever the setup workflow or repository layout changes.
