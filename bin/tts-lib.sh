#!/usr/bin/env bash
# tts-lib.sh — shared helpers for the `tts` (Piper) and `narrate` (Kokoro)
# wrappers. Sourced, not executed: it holds the text/argument preprocessing and
# audio-player selection common to both, so the two commands stay in sync.
#
# Each function takes the calling command's name as its first argument, so error
# messages are prefixed correctly. Source it with:
#   . "$(dirname "$(readlink -f "$0")")/tts-lib.sh"

# Directory holding the bin scripts (this lib and the *-stream helpers),
# resolved through any symlink so callers find their siblings in the repo even
# when invoked via ~/.local/bin.
TL_BIN_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# tl_read_text PROG [ARG...] — echo the text to speak: the joined ARGs, or stdin
# if none were given. Pass "$@" after option parsing.
tl_read_text() {
    shift  # drop PROG (reserved for symmetry / future messages)
    if [ "$#" -gt 0 ]; then
        printf '%s' "$*"
    else
        cat
    fi
}

# tl_strip_markdown PROG RAW TEXT — echo TEXT with Markdown stripped via the
# sibling `unmd`, unless RAW is 1. If unmd is missing, warn and echo TEXT as-is
# rather than failing.
tl_strip_markdown() {
    local prog="$1" raw="$2" text="$3" unmd
    if [ "$raw" -eq 1 ]; then
        printf '%s' "$text"
        return
    fi
    unmd="$TL_BIN_DIR/unmd"
    [ -x "$unmd" ] || unmd=unmd
    if command -v "$unmd" >/dev/null 2>&1; then
        printf '%s' "$text" | "$unmd"
    else
        echo "$prog: unmd not found; reading text as-is (use --raw to silence)" >&2
        printf '%s' "$text"
    fi
}

# tl_require_text PROG TEXT — exit 2 with a message if TEXT is empty/whitespace.
tl_require_text() {
    [ -n "${2//[[:space:]]/}" ] || { echo "$1: no text given" >&2; exit 2; }
}

# tl_clamp_speed PROG SPEED LO HI — echo SPEED clamped to [LO, HI], warning on
# stderr when clamped. Exit 2 if SPEED is not a positive number. Used by engines
# (e.g. Kokoro) that hard-limit their speed range.
tl_clamp_speed() {
    local prog="$1" speed="$2" lo="$3" hi="$4"
    awk -v s="$speed" -v lo="$lo" -v hi="$hi" -v prog="$prog" '
        BEGIN {
            if (s !~ /^[0-9]*\.?[0-9]+$/ || s + 0 <= 0) { exit 1 }
            c = s + 0
            if (c < lo) {
                printf "%s: speed %s below %s; clamping to %s\n", prog, s, lo, lo > "/dev/stderr"
                c = lo
            } else if (c > hi) {
                printf "%s: speed %s above %s; clamping to %s\n", prog, s, hi, hi > "/dev/stderr"
                c = hi
            }
            printf "%s", c
        }
    ' || { echo "$prog: -s SPEED must be a positive number (got '$speed')" >&2; exit 2; }
}

# tl_pick_player RATE — set the array TL_PLAYER to a raw-PCM-capable player
# command for the given sample RATE, or to an empty array if none is available.
# paplay/aplay read raw PCM from stdin; pw-play/ffplay can't, so they're not
# offered here (callers handle those via a buffered file if needed).
tl_pick_player() {
    local rate="$1"
    # shellcheck disable=SC2034  # TL_PLAYER is consumed by the sourcing script
    if command -v paplay >/dev/null 2>&1; then
        TL_PLAYER=(paplay --raw --format=s16le --rate="$rate" --channels=1)
    elif command -v aplay >/dev/null 2>&1; then
        TL_PLAYER=(aplay -q -r "$rate" -f S16_LE -c 1 -t raw -)
    else
        TL_PLAYER=()
    fi
}

# tl_venv_python TOOL — echo the path to the Python interpreter in the uv tool
# venv that provides TOOL (e.g. piper, kokoro-tts), resolved through symlinks.
# Returns non-zero if TOOL isn't on PATH.
tl_venv_python() {
    local bin
    bin="$(command -v "$1")" || return 1
    printf '%s' "$(dirname "$(readlink -f "$bin")")/python"
}
