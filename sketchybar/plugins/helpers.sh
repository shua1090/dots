#!/usr/bin/env sh

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

PLUGIN_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CONFIG_DIR="${CONFIG_DIR:-$(dirname "$PLUGIN_DIR")}"

if [ -f "$CONFIG_DIR/colors.sh" ]; then
  . "$CONFIG_DIR/colors.sh"
fi

open_settings() {
  /usr/bin/open "$1" >/dev/null 2>&1 || /usr/bin/open -b com.apple.systempreferences >/dev/null 2>&1
}

shorten() {
  text="$1"
  max="${2:-24}"
  length="$(printf '%s' "$text" | wc -m | tr -d ' ')"

  if [ "$length" -gt "$max" ]; then
    cut_at=$((max - 3))
    printf '%s...' "$(printf '%s' "$text" | cut -c "1-$cut_at")"
  else
    printf '%s' "$text"
  fi
}
