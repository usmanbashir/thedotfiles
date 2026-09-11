#!/usr/bin/env bash
# Tests for claude/statusline.sh — the Claude Code status line renderer.
#
# Pure bash, no framework. Each case feeds a JSON payload on stdin and compares
# the rendered line to an expected string. Run: tests/statusline_test.sh
# (exits non-zero on any failure)
#
# Most cases strip ANSI attributes before comparing, so expectations read as
# plain text. The few that care about colour use run_has and match the raw
# escape sequence instead.
set -u

DIR="$(cd "$(dirname "$0")/.." && pwd)"
STATUSLINE="$DIR/claude/statusline.sh"

pass=0
fail=0

# strip_ansi — drop CSI colour sequences so expectations stay readable.
strip_ansi() {
    sed $'s/\033\\[[0-9;]*m//g'
}

# ctx_json PERCENT TOKENS — minimal payload: a model name and a context window.
# Pass null for either field to represent it being absent from the real payload.
ctx_json() {
    printf '{"model":{"display_name":"Opus"},"context_window":{"used_percentage":%s,"total_input_tokens":%s}}' \
        "$1" "$2"
}

# run_case NAME JSON EXPECTED — compares the ANSI-stripped line to EXPECTED.
run_case() {
    local name=$1 json=$2 expected=$3 got
    got="$(printf '%s' "$json" | "$STATUSLINE" | strip_ansi)"
    if [ "$got" = "$expected" ]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        printf 'FAIL: %s\n  expected: %q\n  got:      %q\n' "$name" "$expected" "$got"
    fi
}

# run_has NAME JSON NEEDLE — asserts the raw line (ANSI intact) contains NEEDLE.
run_has() {
    local name=$1 json=$2 needle=$3 got
    got="$(printf '%s' "$json" | "$STATUSLINE")"
    case $got in
        *"$needle"*)
            pass=$((pass + 1))
            ;;
        *)
            fail=$((fail + 1))
            printf 'FAIL: %s\n  needle:   %q\n  got:      %q\n' "$name" "$needle" "$got"
            ;;
    esac
}

# Token count beside the percentage — the reason this file exists.
run_case "tokens follow percent"     "$(ctx_json 42 84231)"  'Opus · ctx:42% (84k)'
run_case "rounds to nearest k"       "$(ctx_json 42 84600)"  'Opus · ctx:42% (85k)'
run_case "rounds down below half"    "$(ctx_json 42 84499)"  'Opus · ctx:42% (84k)'
run_case "exactly one thousand"      "$(ctx_json 1 1000)"    'Opus · ctx:1% (1k)'
run_case "sub-1000 shown in full"    "$(ctx_json 1 400)"     'Opus · ctx:1% (400)'
run_case "999 stays unrounded"       "$(ctx_json 1 999)"     'Opus · ctx:1% (999)'
run_case "full window"               "$(ctx_json 100 200000)" 'Opus · ctx:100% (200k)'

# Degradation: the segment must survive a payload missing either half.
run_case "no ctx before first message" "$(ctx_json null null)" 'Opus'
run_case "percent alone if tokens absent" \
    '{"model":{"display_name":"Opus"},"context_window":{"used_percentage":42}}' \
    'Opus · ctx:42%'
run_case "percent alone if tokens unparseable" \
    '{"model":{"display_name":"Opus"},"context_window":{"used_percentage":42,"total_input_tokens":"lots"}}' \
    'Opus · ctx:42%'

# Colour: thresholds stay on the percent, parens stay dim and outside it.
run_has "danger colours the percent"  "$(ctx_json 92 184000)" $'\033[31m92%'
run_has "warning colours the percent" "$(ctx_json 75 150000)" $'\033[33m75%'
run_has "safe percent uncoloured"     "$(ctx_json 42 84231)"  $'\033[0m42%'
run_has "token count is dim"          "$(ctx_json 42 84231)"  $'\033[2;37m (84k)'

# Other segments are untouched by the change.
# shellcheck disable=SC2016  # the $ in $1.50 is a literal dollar sign
run_case "cost and duration still render" \
    '{"model":{"display_name":"Opus"},"context_window":{"used_percentage":42,"total_input_tokens":84231},"cost":{"total_cost_usd":1.5,"total_duration_ms":90000}}' \
    'Opus · ctx:42% (84k) · $1.50 · 1m 30s'

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
