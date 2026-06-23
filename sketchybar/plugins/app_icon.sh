#!/usr/bin/env sh

app_icon() {
  case "$1" in
    "Google Chrome" | Chrome) printf "󰊯" ;;
    Safari) printf "󰀹" ;;
    Firefox) printf "󰈹" ;;
    "Zen Browser" | Zen) printf "󰖟" ;;
    Zed | "Visual Studio Code" | Code | Cursor) printf "󰨞" ;;
    kitty | Ghostty | Terminal | iTerm2 | WezTerm) printf "" ;;
    Finder) printf "󰀶" ;;
    Discord) printf "󰙯" ;;
    Spotify) printf "󰓇" ;;
    Mail | Outlook | "Microsoft Outlook") printf "󰇮" ;;
    Messages) printf "󰍡" ;;
    Calendar) printf "󰃭" ;;
    Notes) printf "󰎞" ;;
    Slack) printf "󰒱" ;;
    Zoom | "zoom.us") printf "󰍫" ;;
    Figma) printf "" ;;
    "System Settings") printf "󰒓" ;;
    *) printf "•" ;;
  esac
}
