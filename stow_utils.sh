# stow -t ~ sway waybar wofi swaync wlogout wallpapers
mkdir -p ~/.config
stow -t ~/.config starship
stow -t ~ gitconfig
# sudo stow -t / greetd

# stow -t ~ gitconfig vimrc waybar starship
# stow -t ~/.config/hypr hypr
stow -t ~/.config kitty
stow -t ~/.config nvim
cp .zshrc ~/.zshrc
# stow -t ~ .zshrc
# stow -t ~ wofi wlogout wallpapers swaync

# cp dbox.sh ~/bin/dbox
