#!/bin/sh
# Output the tmux status-right battery segment when running on battery power.
# Stays silent on AC power or when no battery is detected.
# Keeps this config portable across Bluefin, macOS, WSL, Arch, Ubuntu, etc.

capacity=

case "$(uname -s)" in
    Linux)
        on_ac=0
        for psy in /sys/class/power_supply/*; do
            [ -d "$psy" ] || continue
            [ -r "$psy/type" ] || continue
            read -r type <"$psy/type"
            case $type in
                Mains)
                    if [ -r "$psy/online" ]; then
                        read -r online <"$psy/online"
                        [ "$online" = 1 ] && on_ac=1
                    fi
                    ;;
                Battery)
                    if [ -z "$capacity" ] && [ -r "$psy/capacity" ]; then
                        read -r capacity <"$psy/capacity"
                    fi
                    ;;
            esac
        done
        [ "$on_ac" = 1 ] && exit 0
        ;;
    Darwin)
        batt=$(pmset -g batt 2>/dev/null) || exit 0
        case $batt in
            *"AC Power"*) exit 0 ;;
        esac
        capacity=$(printf '%s\n' "$batt" | awk '
            match($0, /[0-9]+%/) {
                print substr($0, RSTART, RLENGTH - 1)
                exit
            }')
        ;;
esac

[ -n "$capacity" ] || exit 0

# Map capacity to an 8-tier glyph (▁ ▂ ▃ ▄ ▅ ▆ ▇ █) at the same thresholds
# tmux-battery's charge-tier defaults use: 5 / 20 / 35 / 50 / 65 / 80 / 95 %.
if   [ "$capacity" -ge 95 ]; then glyph='█'
elif [ "$capacity" -ge 80 ]; then glyph='▇'
elif [ "$capacity" -ge 65 ]; then glyph='▆'
elif [ "$capacity" -ge 50 ]; then glyph='▅'
elif [ "$capacity" -ge 35 ]; then glyph='▄'
elif [ "$capacity" -ge 20 ]; then glyph='▃'
elif [ "$capacity" -gt  5 ]; then glyph='▂'
else                              glyph='▁'
fi

printf '#[fg=#5a6371]%s %s%% #[fg=#3d424b]│ ' "$glyph" "$capacity"
