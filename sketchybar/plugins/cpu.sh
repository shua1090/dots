#!/usr/bin/env bash

source "$(dirname "$0")/helpers.sh"

cpu="$(top -l 1 -n 0 2>/dev/null | awk -F'[:,%]' '
  /CPU usage/ {
    user = $2
    sys = $3
    gsub(/[^0-9.]/, "", user)
    gsub(/[^0-9.]/, "", sys)
    printf "%.0f", user + sys
    found = 1
  }
  END { if (!found) print "" }
')"

color="$YELLOW"
if [[ "$cpu" =~ ^[0-9]+$ ]]; then
  (( cpu >= 80 )) && color="$RED"
  label="${cpu}%"
else
  color="$MUTED"
  label="--"
fi

sketchybar --set "${NAME:-cpu}" icon.color="$color" label="$label" label.color="$FG"
