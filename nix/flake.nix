{
  description = "Simple workstation flake with apps and a Rust devshell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAll = f: nixpkgs.lib.genAttrs systems (system:
      let pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # needed for vscode/brave
      };
      in f pkgs
    );
  in {
    # Bundle of desktop apps
    packages = forAll (pkgs: {
      workstation = pkgs.buildEnv {
        name = "workstation";
        paths = with pkgs; [
          vim
          brave
          vscode       # Microsoft build
          code-cursor  # if available in nixpkgs; else swap/remove
          starship
        ];
      };
    });

    # Rust devshell from external file
    devShells = forAll (pkgs: {
      rust = import ./rust.nix { inherit pkgs; };
    });
  };
}

