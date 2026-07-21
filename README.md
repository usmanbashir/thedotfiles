# THE DOT FILES

My personal dotfiles: the shell, editor, terminal multiplexer, and handful of
small CLI tools I carry between machines. Built to stay portable across
Bluefin/Fedora, macOS (Apple Silicon + Intel), and WSL/Windows Terminal, with
[Homebrew](https://brew.sh) as the common package manager.

> These are tuned to my taste: fish with vi mode everywhere, a `Ctrl-A` tmux
> prefix, Tokyo Night colours. You're welcome to run the whole thing, but you'll
> probably get more out of forking it and lifting the parts you like.

## What's inside

| Path | Configures |
|------|------------|
| `fish/` | Fish shell: aliases, git helper functions, vi mode, [starship](https://starship.rs) prompt, [zoxide](https://github.com/ajeetdsouza/zoxide), fzf, eza/bat. Plugins via Fisher. |
| `nvim/` | Neovim: lazy.nvim, Mason LSP, Telescope, completion, gitsigns, Tokyo Night. |
| `tmux/` | tmux: `Ctrl-A` prefix, vim-style panes and copy mode, a custom status bar, tpm + tmux-resurrect, a fullscreen clock popup. |
| `git/` | delta pager, `zdiff3` conflict style, fast-forward-only pulls (merged into your global git config). |
| `bin/` | Small CLI tools (below). |
| `claude/` | Claude Code status line. |
| `glow/`, `dicts/` | glow (markdown viewer) config and spell dictionaries. |

### bin tools

- **`tts` / `narrate`**: speak text aloud with local neural TTS (Piper for
  speed, Kokoro for quality); `unmd` strips Markdown so it reads cleanly.
- **`domainis` / `domainhunt`**: check domain availability over RDAP.
- **`cht.sh`**: [cheat.sh](https://cheat.sh) in your shell.

## Requirements

- **[Homebrew](https://brew.sh)**: installs most of the tooling. Set it up first.
- **fish**, **neovim**, **tmux**, **git**, **curl**: what the configs target.
  `setup.sh` warns if fish/nvim/tmux are missing but links the configs anyway.
- Everything else (git-delta, starship, zoxide, glow, clock-rs, and my
  [`clau`](https://github.com/usmanbashir/clau) Claude Code launcher) is
  installed by `setup.sh` via Homebrew.

## Setup

```sh
git clone https://github.com/usmanbashir/thedotfiles.git
cd thedotfiles
./setup.sh
```

Keep the clone around afterwards. The configs are **symlinked back to it**, so
deleting the repo breaks them.

`setup.sh` is idempotent and safe to re-run. It:

- symlinks the configs into `~/.config` (plus the Claude status line into
  `~/.claude` and the `bin/` scripts into `~/.local/bin`);
- bootstraps tmux's plugin manager (tpm) and fish's (Fisher);
- **adds an include line to your global `~/.gitconfig`** so the git settings apply;
- **installs tools via Homebrew**, including
  [`clau`](https://github.com/usmanbashir/clau) from my own tap
  (`usmanbashir/tap/clau`);
- on **Linux only**, sets up the Piper/Kokoro TTS engines and **downloads
  ~300 MB of voice models**.

It won't clobber anything: if a target already exists and isn't a symlink it
stops and asks you to move it yourself, and if Homebrew is missing the install
steps are skipped (you get the symlinks, not the tools).

Afterwards, start a fresh fish session (`exec fish`) and, inside tmux, press
`Ctrl-A I` once to let tpm fetch its plugins.

## License

Copyright (C) 2024-2026 Usman Bashir. Licensed under [GPL-3.0-or-later](LICENSE).

## Feedback

Suggestions and improvements are
[welcome](https://github.com/usmanbashir/thedotfiles/issues)!
