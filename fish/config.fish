set fish_greeting			        # Supresses intro message

# Editor (change to nvim/vim/code as you like)
set -gx EDITOR nvim
set -gx VISUAL nvim

if status is-interactive
  # Commands to run in interactive sessions can go here
  fish_config theme choose 'ayu Dark'
end

### bling.fish source start
# Use plain aliases instead of abbreviations so commands like `cat` don't
# visibly expand (to `bat`, `eza`, `ug`, …) as you type. Our own aliases below
# then take effect on top.
set -g BLING_USE_ABBR 0
test -f /usr/share/ublue-os/bling/bling.fish && source /usr/share/ublue-os/bling/bling.fish
### bling.fish source end

# Keep the real grep everywhere — bling aliases grep/egrep/fgrep → ugrep on
# Bluefin. Use `ug` (or `command ug`) when you want ugrep.
functions --erase grep egrep fgrep xzgrep xzegrep xzfgrep

# Homebrew shellenv (cross-platform: Linux, macOS Apple Silicon, macOS Intel)
for brew_path in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew
    if test -x $brew_path
        eval ($brew_path shellenv)
        break
    end
end

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

# Make human readable
alias df 'df -h'
alias free 'free -m'

alias q exit
alias v nvim
alias sv "sudo nvim"

alias t 'tldr'

alias ta 'tmux attach'
alias tls 'tmux list-sessions'

# Git Shortcuts
alias g git
alias gs "git status"
alias ga "git add"
alias gap "git add -p"
alias gc "git commit"
alias gcm "git commit -m"
alias gd "git diff"
alias gdd "git diff --cached"
alias gp "git push"
# The remote's default branch as a remote-tracking ref, e.g. origin/main. The
# origin/main fallback covers clones that never set origin/HEAD, and makes these
# degrade to their old hardcoded behaviour (fix a repo: git remote set-head origin -a).
# --verify --quiet matters: a plain `rev-parse --abbrev-ref origin/HEAD` echoes
# "origin/HEAD" back on stdout when the ref is unset, which would sail past an
# emptiness check and become a bogus revision.
function __git_default_remote_branch
    set -l head (git rev-parse --abbrev-ref --verify --quiet origin/HEAD 2>/dev/null)
    test -n "$head"; or set head origin/main
    echo $head
end

# The same branch as a local ref, e.g. main.
function __git_default_branch
    string replace -r '^origin/' '' -- (__git_default_remote_branch)
end

# gu* compare HEAD against the branch's upstream. A branch that hasn't been
# `push -u`'d has no @{u} at all, so fall back to the default branch — otherwise
# these die with "no upstream configured for branch 'x'".
function __gu_base
    set -l base (git rev-parse --abbrev-ref --symbolic-full-name --verify --quiet @{u} 2>/dev/null)
    test -n "$base"; or set base (__git_default_remote_branch)
    echo $base
end

function gu --wraps 'git rev-list'
    git rev-list --count (__gu_base)..HEAD $argv
end

function gul --wraps 'git log'
    git log --oneline (__gu_base)..HEAD $argv
end

function guf --wraps 'git diff'
    git diff --stat (__gu_base)..HEAD $argv
end

# The LESS on gur/gmr puts a "lines 22-43/979 3%" progress readout in the pager,
# so a long review shows how much is left. M is the long prompt; --file-size makes
# less size the input up front, which it can't do for a pipe otherwise, so the
# percentage has a total to count against (needs less >= 590). FRX are the defaults
# git sets for us, but only when LESS is unset, so repeat them here.
function gur --wraps 'git log'
    LESS='-FRXM --file-size' git log --reverse -p --stat --no-merges (__gu_base)..HEAD $argv
end

# Reviews the whole branch against the default branch. Uses __git_default_branch,
# not __gu_base: gmr should ignore @{u} entirely, or it would compare a pushed
# branch against itself and show nothing.
function gmr --wraps 'git log'
    LESS='-FRXM --file-size' git log --reverse -p --stat --no-merges (__git_default_branch)..HEAD $argv
end

alias gpl "git pull"
alias gpf "gp --force"
alias gph "git push heroku master"
alias gphf "gph --force"
alias gl='git log --oneline --decorate --graph -n 20'
alias gll='git log'
alias gn "gl -n"
alias authors "git log --pretty=format:%aN | sort | uniq -c | sort -rn"
alias grv "git remote -v"

alias gg "ghq get"
alias lg "lazygit"
alias lzd "lazydocker"

alias Z fzf

alias d domainis

# Roll the dice
alias rr 'curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

# alias ls='eza -la --group-directories-first'
# alias ll='eza -lah --git'
# alias rg='rg --vimgrep'


### ----- Starship prompt -----
if type -q starship
    starship init fish | source
end

### ----- Better defaults -----
# Use bat as manpager when available (nice but optional)
if type -q bat
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

### ----- fzf integration -----
# Enable fzf keybindings/completions if brew provides them
# if test -d (brew --prefix)/opt/fzf
#     set -l fzfdir (brew --prefix)/opt/fzf
#     if test -f $fzfdir/shell/key-bindings.fish
#         source $fzfdir/shell/key-bindings.fish
#     end
#     if test -f $fzfdir/shell/completion.fish
#         source $fzfdir/shell/completion.fish
#     end
# end

# --- fzf (Homebrew) keybindings + completion ---
if type -q brew
    set -l fzf_base (brew --prefix)/opt/fzf
    if test -f $fzf_base/shell/key-bindings.fish
        source $fzf_base/shell/key-bindings.fish
    end
    if test -f $fzf_base/shell/completion.fish
        source $fzf_base/shell/completion.fish
    end
end

# Make fzf use fd for file lists (faster / respects ignores)
if type -q fd
    set -gx FZF_DEFAULT_COMMAND "fd --hidden --follow --exclude .git"
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
end


### ----- zoxide (smart 'cd') -----
if type -q zoxide
    # On Bluefin, bling.fish (sourced above) has already run this, so only
    # initialise when nothing else has.
    functions -q __zoxide_z; or zoxide init fish | source

    # zoxide's hook is `--on-variable PWD`, which only fires when PWD *changes*,
    # so the directory a shell starts in is never recorded. tmux windows, splits
    # and `tn` sessions all start fish in an inherited directory, which would
    # leave those directories permanently invisible to `z`.
    test -z "$fish_private_mode"; and zoxide add -- $PWD
end

# ls replacement (eza) with a couple variants
if type -q eza
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lah --group-directories-first --icons=auto'
    alias la "ll -a"
    alias lte "ll -T"
    alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
    alias lta "lt -a"
    alias l. 'eza -d .* --icons=auto'                        # hidden entries only
    alias l1 'eza -1 --icons=auto --group-directories-first'  # one entry per line
end

# Better cat (bat); use `rcat` (or `command cat`) for the real cat
alias rcat='command cat'
if type -q bat
    alias cat='bat'
end

### ----- WSL niceties -----
# If you use Windows' clipboard from WSL:
# sudo apt install -y xclip  (or use clip.exe)
if type -q clip.exe
    alias clip='clip.exe'
end

# Enable vi mode
fish_vi_key_bindings

# Cursor shapes for vi mode
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual block


# Functions

# Fast escape: jj -> normal mode (insert mode only)
function fish_user_key_bindings
    # jj in insert mode -> normal mode
    bind --mode insert --sets-mode default jj repaint
end

function bk --argument filename
  cp $filename $filename.bak
end

function mkcd
  mkdir -p -- $argv && cd -- $argv
end

function gccd --argument repo
  git clone $repo && cd (basename $repo | cut -d. -f1)
end

# Start, attach to, or switch to a tmux session; defaults to the current
# directory's name. Inside tmux, attaching would nest, so create the session
# detached and switch the client to it instead.
# Targets are matched with a leading `=` for exactness: tmux resolves plain
# targets by prefix, so `-t work` would find an existing `workspace` session.
function tn --argument name
  test -z "$name"; and set name (basename $PWD | string replace -ra '[.:\s]' '_')
  if set -q TMUX
    tmux has-session -t "=$name" 2>/dev/null; or tmux new-session -d -s $name
    tmux switch-client -t "=$name"
  else
    tmux new-session -A -s $name
  end
end

# Run `claude -p` and append the query, response, and duration to a log.
function `
  set -l logfile $HOME/.local/state/claude-queries.md
  mkdir -p (dirname $logfile)

  set -l query (string join ' ' -- $argv)
  set -l timestamp (date '+%Y-%m-%d %H:%M:%S %Z')
  set -l start_epoch (date +%s)

  set -l tmpfile (mktemp)
  claude -p $argv | tee $tmpfile

  set -l duration (math (date +%s) - $start_epoch)

  printf '## %s — %ds\n\n> %s\n\n' "$timestamp" "$duration" "$query" >> $logfile
  cat $tmpfile >> $logfile
  printf '\n---\n\n' >> $logfile

  rm $tmpfile
end

fish_add_path $HOME/.local/bin

# bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin
