#!/usr/bin/env bash
# Claude Code status line script
# Reads JSON from stdin and prints a formatted status line.

input=$(cat)

# ANSI helpers — all output via printf so \e expands to ESC (0x1b)
DIM=$(printf '\e[2;37m')    # dim grey  — labels and separators
RESET=$(printf '\e[0m')     # reset all attributes
YELLOW=$(printf '\e[33m')   # warning threshold (>=70%)
RED=$(printf '\e[31m')      # danger threshold  (>=90%)
SEP="${DIM} · ${RESET}"     # middle dot separator

# Color a percentage integer value: yellow >=70, red >=90, default otherwise
pct_color() {
  local val=$1
  if [ "$val" -ge 90 ]; then
    printf '%s' "${RED}${val}%${RESET}"
  elif [ "$val" -ge 70 ]; then
    printf '%s' "${YELLOW}${val}%${RESET}"
  else
    printf '%s' "${val}%"
  fi
}

model=$(echo "$input" | jq -r '.model.display_name // ""')

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Build context segment: dim label, colored value
ctx_segment=""
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  ctx_segment="${DIM}ctx:${RESET}$(pct_color "$used_int")"
fi

# Build cost segment: no coloring, plain value
cost_segment=""
cost_raw=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost_raw" ]; then
  cost_segment=$(printf '$%.2f' "$cost_raw")
fi

# Build duration segment: no coloring, plain value
dur_segment=""
dur_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
if [ -n "$dur_ms" ]; then
  dur_s=$(( ${dur_ms%.*} / 1000 ))
  if [ "$dur_s" -lt 60 ]; then
    dur_segment="${dur_s}s"
  elif [ "$dur_s" -lt 3600 ]; then
    m=$(( dur_s / 60 ))
    s=$(( dur_s % 60 ))
    dur_segment="${m}m $(printf '%02d' "$s")s"
  else
    h=$(( dur_s / 3600 ))
    m=$(( (dur_s % 3600) / 60 ))
    dur_segment="${h}h$(printf '%02d' "$m")m"
  fi
fi

# Build rate limit segment: dim label, each value independently colored
rl_segment=""
rl_five_raw=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_week_raw=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$rl_five_raw" ] || [ -n "$rl_week_raw" ]; then
  if [ -n "$rl_five_raw" ] && [ -n "$rl_week_raw" ]; then
    rl_five_int=$(printf '%.0f' "$rl_five_raw")
    rl_week_int=$(printf '%.0f' "$rl_week_raw")
    rl_segment="${DIM}rl:${RESET}$(pct_color "$rl_five_int")${DIM}/${RESET}$(pct_color "$rl_week_int")"
  elif [ -n "$rl_five_raw" ]; then
    rl_five_int=$(printf '%.0f' "$rl_five_raw")
    rl_segment="${DIM}rl:${RESET}$(pct_color "$rl_five_int")${DIM}/-${RESET}"
  else
    rl_week_int=$(printf '%.0f' "$rl_week_raw")
    rl_segment="${DIM}rl:${RESET}-${DIM}/${RESET}$(pct_color "$rl_week_int")"
  fi
fi

# Join non-empty parts with middle-dot separator (avoids IFS array join bug)
output=""
for part in "$model" "$ctx_segment" "$cost_segment" "$dur_segment" "$rl_segment"; do
  if [ -n "$part" ]; then
    if [ -n "$output" ]; then
      output="${output}${SEP}${part}"
    else
      output="$part"
    fi
  fi
done

printf '%s' "$output"
