# DevOps Toolbox Terminal Setup Reference

A reference guide summarizing the terminal setup featured in DevOps Toolbox's video: *"I Tried Everything. This is the Best Terminal Setup"*.

---

## 🛠️ Core Tools Overview

| Category | Tool | Description & Key Features |
| :--- | :--- | :--- |
| **Terminal** | [Ghostty](https://ghostty.org/) | GPU-accelerated, fast, cross-platform terminal emulator written in Zig by Mitchell Hashimoto. |
| **Multiplexer** | [tmux](https://github.com/tmux/tmux) | Terminal multiplexer for workspace and session management. |
| **Shell** | **Bash** | Standard POSIX-compatible shell paired with modern CLI utilities. |
| **Prompt** | [Starship](https://starship.rs/) | Minimalist, fast, and ultra-customizable cross-shell prompt. |
| **Editor** | [Neovim](https://neovim.io/) | Text editor powered by the [LazyVim](https://www.lazyvim.org/) framework. |
| **Navigation** | [Zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` replacement that remembers your most visited directories (`z` command). |
| **Fuzzy Finder**| [fzf](https://github.com/junegunn/fzf) | General-purpose command-line fuzzy finder. |
| **History** | [Atuin](https://atuin.sh/) | SQLite-backed command history with fast searching and optional cross-device sync. |
| **Version Manager**|[Mise](https://mise.jdx.dev/) | Polyglot tool version manager (Node, Python, Go, etc.) and environment manager. |

---

## 🧩 tmux Plugins & Session Management

- **[sesh](https://github.com/joshmedeski/sesh):** Smart tmux session manager for quickly jumping between directories and projects.
- **[tmux-sessionx](https://github.com/omerxx/tmux-sessionx):** Fuzzy session manager with real-time preview windows.
- **[tmux-floax](https://github.com/omerxx/tmux-floax):** Brings persistent, floating terminal windows to tmux.

---

## 🚀 Workflows & Utilities

- **Git & Worktrees:**
  - **[worktrunk](https://github.com/max-nazarov/worktrunk) / workmux:** TUI dashboards bridging Git worktrees, tmux sessions, and parallel branch workflows.
- **AI Integration:**
  - **[pi](https://github.com/joshmedeski/pi):** Lightweight CLI harness for interacting with LLM coding agents directly from the terminal.
- **Modern CLI Replacement Tools:**
  - **[eza](https://github.com/eza-community/eza):** Modern replacement for `ls` with tree views and file icons.
  - **[Superfile](https://github.com/yorukot/superfile):** Feature-rich TUI file manager.
  - **[Television](https://github.com/alexpasmantier/television):** Fast TUI fuzzy search utility.

---

## 🍺 Quick Install (Homebrew Reference)

```bash
# Core tools
brew install ghostty tmux starship zoxide fzf atuin mise eza neovim

# Additional TUI tools
brew install superfile
```

---
*Reference Video:* [I Tried Everything. This is the Best Terminal Setup (DevOps Toolbox)](https://www.youtube.com/watch?v=QpiZOKul1U8)