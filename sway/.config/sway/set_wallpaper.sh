#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   set_wallpaper.sh <wallpaper-name|random> <transition-type|random>
# Examples:
#   set_wallpaper.sh random random
#   set_wallpaper.sh "leopard" wipe
#   set_wallpaper.sh "alpsunrise.jpg" simple

WALL_ARG="${1:-random}"
TRANS_ARG="${2:-random}"

DIR="${HOME}/.config/wallpapers"
[[ -d "$DIR" ]] || { echo "Wallpapers dir not found: $DIR"; exit 1; }

# Ensure swww is available
command -v swww >/dev/null 2>&1 || { echo "swww not found in PATH"; exit 1; }

# Start swww daemon if not running
if ! pgrep -x swww-daemon >/dev/null 2>&1; then
  swww init
fi

# Collect images via bash globbing (case-insensitive)
shopt -s nullglob nocaseglob
files=( "$DIR"/*.png "$DIR"/*.jpg "$DIR"/*.jpeg "$DIR"/*.gif )

if (( ${#files[@]} == 0 )); then
  echo "No images in $DIR"
  echo "Debug listing:"
  ls -la "$DIR" || true
  exit 1
fi

pick_random_file() {
  printf '%s\n' "${files[RANDOM % ${#files[@]}]}"
}

# Resolve wallpaper
if [[ "$WALL_ARG" == "random" ]]; then
  IMG="$(pick_random_file)"
else
  # If an exact filename (with or without path) exists, use it
  if [[ -f "$DIR/$WALL_ARG" ]]; then
    IMG="$DIR/$WALL_ARG"
  elif [[ -f "$WALL_ARG" ]]; then
    IMG="$WALL_ARG"
  else
    # Fuzzy match on basename (case-insensitive)
    candidates=( "$DIR"/*"$WALL_ARG"* )
    if (( ${#candidates[@]} > 0 )); then
      IMG="${candidates[0]}"
    else
      echo "No match for wallpaper: $WALL_ARG — picking random."
      IMG="$(pick_random_file)"
    fi
  fi
fi

# Resolve transition type
VALID_TRANSITIONS=(simple grow outer wipe center any)
if [[ "$TRANS_ARG" == "random" ]]; then
  TTYPE="${VALID_TRANSITIONS[RANDOM % ${#VALID_TRANSITIONS[@]}]}"
else
  TTYPE="$TRANS_ARG"
fi

echo "Applying: $IMG"
echo "Transition: $TTYPE"

# Apply with a smooth, sane default
swww img "$IMG" \
  --transition-type "$TTYPE" \
  --transition-fps 120 \
  --transition-step 120 \
  --transition-duration 0.6 \
  --resize crop

