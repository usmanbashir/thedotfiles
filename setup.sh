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

echo "Linking bin scripts..."
mkdir -p "$HOME/.local/bin"
for script in "$SOURCE_FOLDER"/bin/*; do
    # Only link executables — sourced libraries (e.g. tts-lib.sh) aren't commands
    # and shouldn't land on PATH.
    [ -f "$script" ] && [ -x "$script" ] || continue
    make_link "$script" "$HOME/.local/bin/$(basename "$script")"
done

echo "Linking Claude Code statusline..."
mkdir -p "$HOME/.claude"
make_link "$SOURCE_FOLDER/claude/statusline.sh" "$HOME/.claude/statusline-command.sh"

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

GIT_INCLUDE="$SOURCE_FOLDER/git/gitconfig"
git config --global --unset-all include.path 'git/(delta\.)?gitconfig$' 2>/dev/null || true
git config --global --add include.path "$GIT_INCLUDE"
echo "Set dotfiles git include in global gitconfig"

echo "Installing clock-rs..."
if command -v brew >/dev/null 2>&1; then
    if ! brew list clock-rs >/dev/null 2>&1; then
        brew install clock-rs
    else
        echo "clock-rs already installed"
    fi
else
    echo "brew not on PATH — skipping clock-rs install"
fi

echo "Installing glow..."
if command -v brew >/dev/null 2>&1; then
    if ! brew list glow >/dev/null 2>&1; then
        brew install glow
    else
        echo "glow already installed"
    fi
else
    echo "brew not on PATH — skipping glow install"
fi

echo "Linking glow config..."
mkdir -p "$DEST_FOLDER/glow"
make_link "$SOURCE_FOLDER/glow/glow.yml" "$DEST_FOLDER/glow/glow.yml"

echo "Installing starship..."
if command -v brew >/dev/null 2>&1; then
    if ! brew list starship >/dev/null 2>&1; then
        brew install starship
    else
        echo "starship already installed"
    fi
else
    echo "brew not on PATH — skipping starship install"
fi

echo "Installing zoxide..."
if command -v brew >/dev/null 2>&1; then
    if ! brew list zoxide >/dev/null 2>&1; then
        brew install zoxide
    else
        echo "zoxide already installed"
    fi
else
    echo "brew not on PATH — skipping zoxide install"
fi

echo "Installing clau..."
if command -v brew >/dev/null 2>&1; then
    if ! brew list --cask clau >/dev/null 2>&1; then
        brew install --cask usmanbashir/tap/clau
    else
        echo "clau already installed"
    fi
else
    echo "brew not on PATH — skipping clau install"
fi

echo "Configuring clau..."
if command -v clau >/dev/null 2>&1; then
    clau link
    mkdir -p "$DEST_FOLDER/fish/conf.d"
    clau completions fish > "$DEST_FOLDER/fish/conf.d/clau.fish"
else
    echo "clau not on PATH — skipping clau link/completions"
fi

# Local TTS engines for the `tts` (Piper) and `narrate` (Kokoro) bin scripts.
# Linux-only: macOS has a native `say`, and the engines are CPU/Linux-centric.
# Both run through uv-managed isolated tool envs pinned to Python 3.12
# (kokoro-tts requires <3.13).
echo "Installing TTS engines (Piper + Kokoro)..."
if [ "$(uname -s)" = "Linux" ]; then
    if command -v brew >/dev/null 2>&1; then
        if ! command -v uv >/dev/null 2>&1; then
            brew install uv
        else
            echo "uv already installed"
        fi

        # espeak-ng handles phonemization (Piper embeds it; Kokoro can use it).
        # Bluefin ships it in the base image, so only nudge if it's absent.
        command -v espeak-ng >/dev/null 2>&1 || \
            echo "Note: espeak-ng not found — layer it or 'brew install espeak-ng' for best phonemization."

        PIPER_VOICES="${XDG_DATA_HOME:-$HOME/.local/share}/piper/voices"
        KOKORO_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/kokoro"

        # Piper — fast/everyday (`tts`)
        if ! command -v piper >/dev/null 2>&1; then
            uv tool install --python 3.12 piper-tts
        else
            echo "piper already installed"
        fi
        mkdir -p "$PIPER_VOICES"
        if [ ! -f "$PIPER_VOICES/en_US-lessac-high.onnx" ]; then
            echo "Downloading Piper voice en_US-lessac-high..."
            uvx --python 3.12 --from piper-tts python -m piper.download_voices \
                en_US-lessac-high --data-dir "$PIPER_VOICES"
        else
            echo "Piper voice en_US-lessac-high already present"
        fi

        # Kokoro — quality/long-form (`narrate`)
        if ! command -v kokoro-tts >/dev/null 2>&1; then
            uv tool install --python 3.12 kokoro-tts
        else
            echo "kokoro-tts already installed"
        fi
        mkdir -p "$KOKORO_DIR"
        KOKORO_REL="https://github.com/nazdridoy/kokoro-tts/releases/download/v1.0.0"
        if [ ! -f "$KOKORO_DIR/kokoro-v1.0.onnx" ]; then
            echo "Downloading Kokoro model (~310MB)..."
            curl -fSL -o "$KOKORO_DIR/kokoro-v1.0.onnx" "$KOKORO_REL/kokoro-v1.0.onnx"
        else
            echo "Kokoro model already present"
        fi
        if [ ! -f "$KOKORO_DIR/voices-v1.0.bin" ]; then
            echo "Downloading Kokoro voices..."
            curl -fSL -o "$KOKORO_DIR/voices-v1.0.bin" "$KOKORO_REL/voices-v1.0.bin"
        else
            echo "Kokoro voices already present"
        fi
    else
        echo "brew not on PATH — skipping TTS install"
    fi
else
    echo "Not Linux — skipping TTS install (use the native 'say' on macOS)"
fi

echo ""
echo "Done."
