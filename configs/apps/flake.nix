{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { nixpkgs }:
    let
      pkgs = import nixpkgs { };
    in
    {
      configs = {
        neovim = {
          full = import neovim/full { inherit pkgs; };
        };
      };
    };
}
