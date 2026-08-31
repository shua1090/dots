#!/usr/bin/env bash

source "$(dirname "$0")/helpers.sh"

if [[ "${1:-}" == calendar ]]; then
  /usr/bin/open -a Calendar >/dev/null 2>&1
  exit 0
fi

sketchybar --set "${NAME:-clock}" \
  label="$(date '+%a %b %d · %H:%M')" \
  label.color="$FG"
