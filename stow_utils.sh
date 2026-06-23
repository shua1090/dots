#!/usr/bin/env sh
set -e

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

# stow -t ~ sway waybar wofi swaync wlogout wallpapers
mkdir -p "$HOME/.config"
stow -t "$HOME/.config" starship
stow -t "$HOME" gitconfig
# sudo stow -t / greetd

# stow -t ~ gitconfig vimrc waybar starship
# stow -t ~/.config/hypr hypr
mkdir -p "$HOME/.config/kitty"
stow -t "$HOME/.config/kitty" kitty
mkdir -p "$HOME/.config/nvim"
stow -t "$HOME/.config/nvim" nvim

if is_macos; then
  stow_package_with_backups omniwm "$HOME/.config/omniwm"
  stow_package_with_backups sketchybar "$HOME/.config/sketchybar"
fi

cp .zshrc "$HOME/.zshrc"
# stow -t ~ .zshrc
# stow -t ~ wofi wlogout wallpapers swaync

# cp dbox.sh ~/bin/dbox
