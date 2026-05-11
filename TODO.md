# TODO

Ideas and experiments to try in the dotfiles.

---

## tmux: vertical tabs for windows

Tmux has no native vertical status line (`status-position` is top/bottom only). Two approaches worth trying:

### Option A — Tabby plugin
- Repo: https://github.com/brendandebeasi/tabby
- Purpose-built vertical sidebar listing windows, with grouping, icons, mouse click-to-switch.
- Architecture: Go daemon in a hidden tmux window renders into a real pane (since the status bar can't go vertical).
- Requires: tmux ≥ 3.1, Go 1.19+ to build, optional Nerd Font.
- Install via TPM: `set -g @plugin 'brendandebeasi/tabby'`, then `prefix + I`. Config at `~/.config/tabby/config.yaml`.
- Caveats: young/niche project — check activity and open issues before adopting. Spawns a daemon and consumes a pane per window, so heavier than a status-line tweak.

### Option B — Roll your own thin left pane
- Narrow left pane in each window running a script that prints `tmux list-windows -F` formatted vertically, refreshing on hooks (`window-renamed`, `window-linked`, etc.).
- No dependencies, full control, fits the rest of the config's style.
- Trade-offs: no click-to-switch unless wired up via `bind -n MouseDown1Pane`; pane has to be recreated in every new window (or via a hook).

Note: `tmux-plugins/tmux-sidebar` and `tmux-sidebar-plus` are *directory-tree* sidebars, not window lists — not what we want despite the name.
