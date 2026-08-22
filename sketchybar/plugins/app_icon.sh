#!/usr/bin/env bash

app_icon() {
  case "$1" in
    "Google Chrome" | Chrome | Chromium) printf '󰊯' ;;
    Safari) printf '󰀹' ;;
    Firefox) printf '󰈹' ;;
    "Zen Browser" | Zen) printf '󰖟' ;;
    Dia) printf '󰇩' ;;
    Zed | "Visual Studio Code" | Code | Cursor | Xcode) printf '󰨞' ;;
    Ghostty | Terminal | iTerm2 | WezTerm | kitty) printf '' ;;
    Finder) printf '󰀶' ;;
    Codex) printf '󰚩' ;;
    Discord) printf '󰙯' ;;
    Spotify | Music) printf '󰓇' ;;
    Mail | Outlook | "Microsoft Outlook") printf '󰇮' ;;
    Messages) printf '󰍡' ;;
    Calendar) printf '󰃭' ;;
    Notes) printf '󰎞' ;;
    Slack) printf '󰒱' ;;
    Zoom | "zoom.us") printf '󰍫' ;;
    Figma) printf '' ;;
    "System Settings") printf '󰒓' ;;
    "Activity Monitor") printf '󰍛' ;;
    *) printf '󰣆' ;;
  esac
}
