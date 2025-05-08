{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        ./configs.nix
      ];
      perSystem =
        { pkgs, ... }:
        {
          configs = {
            neovim = {
              full = import neovim/full { inherit pkgs; };
            };
          };
        };
    };
}
