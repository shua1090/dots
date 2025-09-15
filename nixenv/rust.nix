# Minimal Rust development shell
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    rustup     # lets you manage toolchains (cargo, rustc, etc.)
    clang
    pkg-config
    openssl.dev
  ];
  shellHook = ''
    echo "🦀 Rust dev environment ready"
  '';
}

