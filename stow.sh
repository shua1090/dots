# stow -t ~ sway waybar wofi swaync wlogout wallpapers
# stow -t ~/.config/ starship 
# stow -t ~ gitconfig vimrc
# sudo stow -t / greetd

stow -t ~ gitconfig vimrc waybar starship
stow -t ~/.config/hypr hypr
stow -t ~/.config/kitty kitty
stow -t ~ wofi wlogout wallpapers swaync

cp dbox.sh ~/bin/dbox