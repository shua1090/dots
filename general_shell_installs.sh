echo "Installing atuin for ^r better"
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

echo "Installing Zoxide"
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

echo "installing eza [ls] and bat [cat] replacements"
cargo install eza
cargo install --locked bat

echo "installing better git-delta"
cargo install git-delta
