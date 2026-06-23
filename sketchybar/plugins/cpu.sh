#!/usr/bin/env sh

. "$(dirname "$0")/helpers.sh"

cpu="$(top -l 1 -n 0 2>/dev/null | awk -F'[:,%]' '
  /CPU usage/ {
    user = $2
    sys = $3
    gsub(/[^0-9.]/, "", user)
    gsub(/[^0-9.]/, "", sys)
    printf "%.0f%%", user + sys
    found = 1
  }
  END {
    if (!found) print "--"
  }
')"

color="$SUBTEXT"
numeric="$(printf '%s' "$cpu" | tr -d '%')"
if [ "$numeric" -ge 80 ] 2>/dev/null; then
  color="$RED"
elif [ "$numeric" -ge 55 ] 2>/dev/null; then
  color="$AMBER"
fi

sketchybar --set "${NAME:-cpu}" \
  icon.color="$color" \
  label="$cpu" \
  label.color="$SUBTEXT"
