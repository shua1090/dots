#!/usr/bin/env bash
set -euo pipefail
pkill -x wofi || true
cd "$HOME/.config/wofi"
exec wofi --show drun --config ./config --style ./style.css

