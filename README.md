# dotfiles

Personal workstation configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Installation

Clone the repository, enter it, and run the setup script:

\`\`\`bash
git clone https://github.com/mathiaswouters/dotfiles.git
cd dotfiles
./setup.sh
\`\`\`

By default, setup performs both steps in order:

1. Detects the operating system and runs the matching script in \`bootstrap/\`.
2. Deploys the supported dotfile packages to your home directory with GNU Stow.

On macOS, the bootstrap installs and configures Homebrew, command-line tools, GUI applications, the Homebrew version of Zsh, and the configured language runtimes. The dotfiles are then linked into place.

## Options

| Command | Action |
| --- | --- |
| \`./setup.sh\` | Full setup (default). |
| \`./setup.sh --dry-run\` | Preview actions without changing the system. |
| \`./setup.sh --bootstrap-only\` | Run OS bootstrap without deploying dotfiles. |
| \`./setup.sh --dotfiles-only\` | Deploy dotfiles without running the OS bootstrap. |
| \`./setup.sh --help\` | Show usage. |

The dry run does not install Homebrew or packages. If GNU Stow is already installed, it uses Stow's simulation mode to preview symlink operations.

## Repository layout

- \`bootstrap/\`: OS-specific installation scripts.
- \`aerospace/\`, \`ghostty/\`, \`starship/\`, \`zsh/\`: GNU Stow packages.
- \`setup.sh\`: shared entrypoint and dotfile deployment.

AeroSpace is only deployed on macOS. Zsh, Ghostty, and Starship are treated as cross-platform packages.

## Notes

- Run the script from a cloned copy of this repository; it does not clone the repository automatically.
- GNU Stow must be installed for dotfile deployment. The macOS bootstrap installs it through Homebrew.
- Existing, unmanaged files that conflict with Stow links must be moved or backed up before deployment. The script intentionally does not overwrite them.
- Arch, Debian/Ubuntu, and Fedora bootstrap scripts are placeholders at this stage; macOS is the currently implemented platform.
