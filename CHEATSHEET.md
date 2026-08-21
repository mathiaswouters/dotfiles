# Desktop cheat sheet

Bindings from this repo. **Super** is the Windows / Command key (`Mod4` in Sway). Directions are vim-style (`h j k l`) in Sway, tmux, lf, nvim, and the shell.

These tools nest. Sway owns the screen. Ghostty is a window. Inside it, zsh is the prompt. tmux is optional and only sees keys after that window is focused. lf and nvim are programs you run in a shell.

| Layer | Key | Role |
|-------|-----|------|
| Sway | **Super** | Windows, workspaces, launcher |
| tmux | **Ctrl+A** then another key | Panes and sessions inside a terminal |
| Neovim | **Space** | Leader (LazyVim) |

## Boot to a usable session

On a heimora Fedora machine:

1. GRUB (Heimora theme) — pick a kernel, 5s timeout.
2. tuigreet — type user and password. greetd on VT1.
3. Sway with waybar on top. Empty desktop is normal.
4. **Super+Return** for Ghostty, **Super+d** for apps.

`Ctrl+Alt+F3` is a spare TTY if greetd on VT1 is stuck. `Ctrl+Alt+F1` returns to the graphical session.

## Who does what

| Tool | Job | Config |
|------|-----|--------|
| Sway | Tiling window manager | `sway/config` → `~/.config/sway/config` |
| Waybar | Top status bar | `waybar/` |
| mako | Notifications (top-right) | `mako/config` |
| wofi | Launcher / menus | invoked from Sway |
| Ghostty | Default terminal (`$term`) | `ghostty/config` |
| Alacritty | Installed fallback | `alacritty/alacritty.toml` |
| zsh + Starship | Shell + prompt | `zsh/.zshrc`, `starship/` |
| tmux | Split terminals, persist sessions | `tmux/` |
| lf | Keyboard file browser | `lf/lfrc` |
| Neovim | Editor (LazyVim) | `nvim/` |

Machine-specific monitors and input go in `~/.config/sway-local/*.conf`, not this repo.

---

## Sway

Windows tile automatically. You only drag when a window is floating. Gaps collapse when a workspace has a single window (`smart_gaps`). Focus does not follow the mouse.

Idle: lock after 5 minutes, outputs off at 10. Sleep locks first. Click the waybar idle/awake control to inhibit that.

### Everyday

| Keys | Action | Notes |
|------|--------|-------|
| Super+Return | Open terminal | Ghostty |
| Super+d | App launcher | wofi drun — `.desktop` apps |
| Super+Shift+d | Run command | wofi run — `$PATH` binaries |
| Super+q | Close focused window | |
| Super+Escape | Lock screen | swaylock |
| Super+Shift+c | Reload Sway config | |
| Super+Shift+e | Exit Sway | confirm with swaynag |

### Focus and workspaces

| Keys | Action | Notes |
|------|--------|-------|
| Super+h / j / k / l | Focus left / down / up / right | arrows work too |
| Super+Shift+hjkl | Move window in that direction | |
| Super+1 … 0 | Switch to workspace 1–10 | |
| Super+Shift+1 … 0 | Move window to workspace 1–10 | |
| Super+Tab | Last workspace | |
| Super+a | Focus parent container | |
| Super+space | Toggle focus tiling ↔ floating | |
| Super+Shift+space | Toggle window floating | |

### Layout

| Keys | Action | Notes |
|------|--------|-------|
| Super+b | Split horizontal | next window to the right |
| Super+v | Split vertical | next window below |
| Super+e | Toggle split orientation | |
| Super+w | Tabbed layout | |
| Super+s | Stacking layout | |
| Super+f | Fullscreen | |
| Super+r | Resize mode | then hjkl; Enter/Esc to leave |
| Super+Shift+minus | Send to scratchpad | |
| Super+minus | Show / hide scratchpad | |
| Super+drag | Move floating window | hold Super, left-click drag |
| Super+right-drag | Resize floating window | |

### Clipboard, shots, media

| Keys | Action | Notes |
|------|--------|-------|
| Super+Shift+v | Clipboard history | cliphist + wofi |
| Print | Region screenshot → clipboard | grim + slurp |
| Shift+Print | Full screenshot → clipboard | |
| Super+n | Dismiss one notification | mako |
| Super+Shift+n | Dismiss all notifications | |
| Volume / mute keys | PipeWire volume | wpctl |
| Brightness keys | Screen brightness | brightnessctl |
| Media keys | Play / next / prev | playerctl |
| Right Alt + key | Compose (accents, symbols) | |

---

## Waybar

| Control | Action | Notes |
|---------|--------|-------|
| Left: workspaces | Click a number to switch | same as Super+1…0 |
| Center: clock | Hover for calendar | right-click changes calendar mode |
| vol … | Click → pavucontrol | right-click mute; scroll volume |
| idle / awake | Click to inhibit lock | awake = screen will not lock |
| tray | Bluetooth + Wi-Fi | blueman-applet, nm-applet |

---

## Ghostty and Alacritty

Appearance only in this repo (Catppuccin Mocha, JetBrains Mono 14, 95% opacity). Sway launches Ghostty. Run `alacritty` from wofi if you want the fallback. Neither file defines custom keybinds.

| Keys | Action | Notes |
|------|--------|-------|
| Ctrl+Shift+C / V | Copy / paste | Linux defaults |
| Ctrl+Shift+N | New window | Ghostty default |
| Ctrl+Shift++ / - | Font size | |

---

## tmux

Prefix is **Ctrl+A** (not Ctrl+B). Hold Ctrl, tap A, release, then tap the command.

**prefix+c** kills the pane. A new window is **prefix Ctrl+C**. Continuum restores the last session on attach. First time inside tmux: **prefix I** (capital I) to install TPM plugins.

| Keys | Action | Notes |
|------|--------|-------|
| Ctrl+A | Prefix | |
| prefix Ctrl+C | New window | starts in `$HOME` |
| prefix c | Kill pane | |
| prefix s | Split below | same directory |
| prefix v | Split right | same directory |
| prefix h / j / k / l | Move between panes | |
| prefix z | Zoom / unzoom pane | |
| prefix H / L | Previous / next window | |
| prefix Ctrl+A | Last window | |
| prefix , / . | Resize pane left / right | |
| prefix - / = | Resize pane down / up | |
| prefix o | Session picker (sessionx) | zoxide + `~/projects` |
| prefix p | Floating pane (floax) | |
| prefix S | Choose session | |
| prefix r | Rename window | |
| prefix R | Reload tmux.conf | |
| prefix Ctrl+D | Detach | |
| prefix K | Clear pane | |
| prefix [ then v | Copy mode, begin selection | vi keys; yank plugin |

---

## zsh

First launch clones plugins into `~/.config/zsh/plugins` (needs network). `vim` is aliased to nvim. `grep` is aliased to ripgrep.

| Keys / command | Action | Notes |
|----------------|--------|-------|
| Esc then hjkl | Vi-mode in the shell | zsh-vi-mode; beam cursor in insert |
| Ctrl+R | Fuzzy history | fzf |
| Ctrl+T | Fuzzy file insert | includes hidden files (fd) |
| Ctrl+F | Fuzzy file insert | excludes hidden files |
| Alt+C | Fuzzy cd | |
| ↑ / ↓ | History substring search | |
| Ctrl+← / Ctrl+→ | Word jump | |
| `z <dir>` | Jump to frequent directory | zoxide |
| `lf` | File manager, then cd there | wrapper follows last dir |

| Alias | Runs |
|-------|------|
| `ll` | `ls -l` |
| `gst` / `ga` / `gc` / `gp` | git status / add / commit -m / push |
| `gco` / `gb` / `gdiff` | checkout / branch / diff |
| `-` | `cd -` (previous directory) |

---

## lf

Hidden files on. Enter opens by type: nvim for text, imv for images, xdg-open otherwise. The `lf` function in `.zshrc` cds the shell to wherever you quit.

| Keys | Action | Notes |
|------|--------|-------|
| hjkl / Enter | Navigate / open | |
| q | Quit | shell cds to last dir |
| D or Delete | Trash | trash-put |
| y / p / x | Yank / paste / cut | lf defaults |
| A / T | mkdir / touch | |
| C / M | Copy / move via fzf dest | |
| E | Extract archive | |
| V | Open in nvim | |
| gh / gc / gd / gp / gv / g/ | Jump home / config / Downloads / Pictures / Videos / `/` | |

---

## Neovim (LazyVim)

`nvim/lua/config/keymaps.lua` is empty, so these are LazyVim defaults. Press Space and wait — which-key lists the rest.

| Keys | Action | Notes |
|------|--------|-------|
| Space | Leader | |
| Space Space | Find files | |
| Space / | Grep project | |
| Space e | File explorer | |
| Space sh | Help / keymap search | |
| gcc | Comment line | |
| `:w` / `:q` | Write / quit | |

---

## Suggested first hour

1. Super+d → Firefox. Super+Return → terminal.
2. Super+Return again. Super+h / l to jump. Super+Shift+l to swap.
3. Super+2, then Super+Shift+2 on a window. Super+Tab back.
4. In Ghostty: `tmux`. prefix v, prefix s, prefix hjkl.
5. Type `lf`, browse, q — you should be in that directory.
6. Super+Shift+v after copying a few things.
7. Print, drag a rectangle, paste into a chat.
