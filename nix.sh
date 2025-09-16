#!/usr/bin/env bash
set -euo pipefail

EXTRA=(--extra-experimental-features "nix-command flakes")
ACCEPT=(--accept-flake-config)

FLAKE_DIR="${1:-./nixenv}"
ATTR="${2:-workstation}"      # flake attr to install/upgrade
ENTRY_NAME="$ATTR"            # profile entry name == attr name

# Resolve absolute path for stable path: URI
if command -v realpath >/dev/null 2>&1; then
  FLAKE_ABS="$(realpath -m "$FLAKE_DIR")"
else
  FLAKE_ABS="$(cd "$(dirname "$FLAKE_DIR")" && pwd)/$(basename "$FLAKE_DIR")"
fi

PKG="path:$FLAKE_ABS#$ATTR"

echo "Upgrading existing entry if present: $ENTRY_NAME"
if nix profile upgrade "$ENTRY_NAME" "${EXTRA[@]}" "${ACCEPT[@]}"; then
  echo "Upgraded '$ENTRY_NAME'."
else
  echo "Entry '$ENTRY_NAME' not found; adding it fresh."
  nix profile add "$PKG" "${EXTRA[@]}" "${ACCEPT[@]}"
fi

echo
nix profile list "${EXTRA[@]}"

