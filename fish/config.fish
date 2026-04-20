set fish_greeting			        # Supresses intro message
set -U TERM xterm-256color		# Not sure I need to set the terninal type

# Dep?
set -U EDITOR nvim			      # Use NeoVim in Terminal
set -U VISUAL nvim	          # No GUI Option, use NeoVim in Terminal

# Editor (change to nvim/vim/code as you like)
set -Ux EDITOR nvim

if status is-interactive
  # Commands to run in interactive sessions can go here
  fish_config theme choose 'ayu Dark'
end

### bling.fish source start
test -f /usr/share/ublue-os/bling/bling.fish && source /usr/share/ublue-os/bling/bling.fish
### bling.fish source end

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
alias gl "git log" # over writtin
alias gp "git push"
alias pull "git pull"
alias gpf "gp --force"
alias gph "git push heroku master"
alias gphf "gph --force"
alias gl "git log --oneline" # over writtin
alias gl='git log --oneline --decorate --graph -n 20'
alias gn "gl -n"
alias authors "git log --pretty=format:%aN | sort | uniq -c | sort -rn"
alias grv "git remote -v"

alias gg "ghq get"
alias lg "lazygit"
alias lzd "lazydocker"

alias Z fzf

alias d "~/bin/domainis.sh"

# Roll the dice
alias rr 'curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

# alias ls='eza -la --group-directories-first'
# alias ll='eza -lah --git'
# alias rg='rg --vimgrep'


### ----- Starship prompt -----
if not set -q STARSHIP_SHELL
    starship init fish | source
end

### ----- Better defaults -----
# Use bat as manpager when available (nice but optional)
if type -q bat
    set -Ux MANPAGER "sh -c 'col -bx | bat -l man -p'"
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
    set -Ux FZF_DEFAULT_COMMAND "fd --hidden --follow --exclude .git"
    set -Ux FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
end


### ----- zoxide (smart 'cd') -----
if type -q zoxide; and not functions -q __zoxide_z
    zoxide init fish | source
end

# ls replacement (eza) with a couple variants
if type -q eza
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lah --group-directories-first --icons=auto'
    alias la "ll -a"
    alias lte "ll -T"
    alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
    alias lta "lt -a"
end

# Better cat (bat) — keep plain cat as \cat
if type -q bat
    alias cat='bat'
end

# Grep replacement
if type -q rg
    alias grep='rg'
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

# Start or attach to a tmux session; defaults to the current directory's name.
function tm --argument name
  test -z "$name"; and set name (basename $PWD | string replace -ra '[.:\s]' '_')
  tmux new-session -A -s $name
end

fish_add_path $HOME/.local/bin
