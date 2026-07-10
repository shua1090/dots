echo "Installing atuin for ^r better"
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

echo "Installing Zoxide"
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

echo "Installing Antidote plugin manager and fzf"
if command -v brew >/dev/null 2>&1; then
  brew install antidote fzf
else
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y fzf
  fi

  antidote_dir="${ZDOTDIR:-$HOME}/.antidote"
  if [ ! -d "$antidote_dir/.git" ]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$antidote_dir"
  fi
fi

echo "installing eza [ls] and bat [cat] replacements"
cargo install eza
cargo install --locked bat

echo "installing better git-delta"
cargo install git-delta

echo "installing octorus/lazygit"
cargo install octorus
go install github.com/jesseduffield/lazygit@latest

echo "Keeping NVM and SDKMAN for now; mise is a good future replacement candidate."
