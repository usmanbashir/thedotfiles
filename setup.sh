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
if [ ${#missing[@]} -gt 0 ]; then
    echo "Warning: not on PATH: ${missing[*]}"
    echo "Linking configs anyway — install these before using them."
    echo ""
fi

mkdir -p "$DEST_FOLDER"

make_link() {
    local src=$1 dst=$2
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        echo "Removing existing $dst"
        rm -rf "$dst"
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

echo ""
echo "Done."
