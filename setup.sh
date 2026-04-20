#!/bin/bash
set -euo pipefail

echo "THE DOT FILES"
echo "============="
echo ""

SOURCE_FOLDER="$(cd "$(dirname "$0")" && pwd)"
DEST_FOLDER="$HOME/.config"

# Pre-req check (warn, don't fail)
missing=()
command -v nvim >/dev/null 2>&1 || missing+=(nvim)
command -v tmux >/dev/null 2>&1 || missing+=(tmux)
command -v fish >/dev/null 2>&1 || missing+=(fish)
if [ ${#missing[@]} -gt 0 ]; then
    echo "Warning: not on PATH: ${missing[*]}"
    echo "Linking configs anyway — install these before using them."
    echo ""
fi

mkdir -p "$DEST_FOLDER"

make_link() {
    local src=$1 dst=$2
    if [ -L "$dst" ]; then
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        echo "Error: $dst exists and is not a symlink. Refusing to overwrite." >&2
        echo "Move or remove it manually, then re-run setup.sh." >&2
        exit 1
    fi
    ln -s "$src" "$dst"
}

echo "Linking NeoVim config..."
make_link "$SOURCE_FOLDER/nvim" "$DEST_FOLDER/nvim"

echo "Linking spell dictionaries..."
make_link "$SOURCE_FOLDER/dicts" "$DEST_FOLDER/dicts"

echo "Linking tmux config..."
mkdir -p "$DEST_FOLDER/tmux"
make_link "$SOURCE_FOLDER/tmux/tmux.conf" "$DEST_FOLDER/tmux/tmux.conf"

echo "Bootstrapping tpm..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "tpm already present"
fi

echo "Linking fish config..."
mkdir -p "$DEST_FOLDER/fish"
make_link "$SOURCE_FOLDER/fish/config.fish" "$DEST_FOLDER/fish/config.fish"
make_link "$SOURCE_FOLDER/fish/fish_plugins" "$DEST_FOLDER/fish/fish_plugins"

echo "Bootstrapping Fisher..."
if command -v fish >/dev/null 2>&1; then
    if ! fish -c 'functions -q fisher' 2>/dev/null; then
        fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
    else
        echo "Fisher already present"
    fi
    fish -c 'fisher update'
else
    echo "fish not on PATH — skipping Fisher bootstrap"
fi

echo "Configuring git delta..."
if command -v brew >/dev/null 2>&1; then
    if ! brew list git-delta >/dev/null 2>&1; then
        brew install git-delta
    else
        echo "git-delta already installed"
    fi
else
    echo "brew not on PATH — skipping git-delta install"
fi

DELTA_INCLUDE="$SOURCE_FOLDER/git/delta.gitconfig"
git config --global --unset-all include.path 'git/delta\.gitconfig$' 2>/dev/null || true
git config --global --add include.path "$DELTA_INCLUDE"
echo "Set delta include in global gitconfig"

echo ""
echo "Done."
