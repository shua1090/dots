# VSCode for

sudo dnf copr enable alebastr/sway-extras -y

sudo dnf install \
    git \
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
    install openssl-devel alsa-lib-devel dbus-devel

flatpak install flathub com.spotify.Client
cargo install spotify_player --locked
