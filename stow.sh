#!/usr/bin/env sh
set -e

# stow -t ~ sway waybar wofi swaync wlogout wallpapers
# stow -t ~/.config/ starship 
# stow -t ~ gitconfig vimrc
# sudo stow -t / greetd

is_macos() {
  [ "$(uname -s)" = "Darwin" ]
}

stow_package_with_backups() {
  package="$1"
  target="$2"
  backup_root="$target/.stow-backups/$package-$(date +%Y%m%d%H%M%S)-$$"

  mkdir -p "$target"

  find "$package" -type f | while IFS= read -r source_file; do
    relative_path="${source_file#"$package"/}"
    target_file="$target/$relative_path"

    if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
      mkdir -p "$backup_root/$(dirname "$relative_path")"
      mv "$target_file" "$backup_root/$relative_path"
    fi
  done

  stow -t "$target" "$package"
}

stow -t "$HOME" gitconfig vimrc waybar starship
mkdir -p "$HOME/.config/hypr"
stow -t "$HOME/.config/hypr" hypr
stow -t "$HOME" wofi wlogout wallpapers swaync

if is_macos; then
  stow_package_with_backups omniwm "$HOME/.config/omniwm"
  stow_package_with_backups sketchybar "$HOME/.config/sketchybar"
fi

mkdir -p "$HOME/bin"
cp dbox.sh "$HOME/bin/dbox"
