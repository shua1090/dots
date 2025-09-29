# VSCode for

sudo dnf copr enable alebastr/sway-extras -y

sudo dnf install \
    git git-lfs gitui zsh\
    hyprland wofi waybar wlogout swaync swww clipman wl-clipboard grim slurp\
    \
    brave-browser kitty \
    \
    stow \
    \
    blueman-manager \
    \
    distrobox fastfetch \
    \
    golang rust cargo \
    \
    openssl-devel alsa-lib-devel dbus-devel \
    sh-autosuggestions zsh-syntax-highlighting \


flatpak install flathub com.spotify.Client
cargo install spotify_player --locked
cargo install starship --locked
