#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

PLUGIN_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CONFIG_DIR="${CONFIG_DIR:-$(dirname "$PLUGIN_DIR")}"

if [[ -f "$CONFIG_DIR/colors.sh" ]]; then
  source "$CONFIG_DIR/colors.sh"
fi

open_settings() {
  /usr/bin/open "$1" >/dev/null 2>&1 \
    || /usr/bin/open -b com.apple.systempreferences >/dev/null 2>&1
}

shorten() {
  local text="$1"
  local max="${2:-32}"
  local length
  length="$(printf '%s' "$text" | wc -m | tr -d ' ')"

  if (( length > max )); then
    printf '%s…' "$(printf '%s' "$text" | cut -c "1-$((max - 1))")"
  else
    printf '%s' "$text"
  fi
}
