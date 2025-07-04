{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixgl.url = "github:nix-community/nixGL";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mornix = {
      url = "/home/deck/Projects/mornix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      self,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      lib = inputs.nixpkgs.lib // {
        dotfiles = import ./lib { inherit inputs; };
      };
    in
    {
      # Host       : Description         : System
      # franken    : WSL2                : x86_64-linux
      # imperfect  : Virtualbox vm       : x86_64-linux
      # steamdeck  : Steam Deck          : x86_64-linux (home-manager)
      # ArtSci-*   : Lab Macs            : aarch64-darwin (nix-darwin)
      # completion : Dummy for lsp       : x86_64-linux (fake)
      nixosConfigurations = lib.dotfiles.flattenAttrset (
        lib.dotfiles.genConfigsFromModules lib.dotfiles.const.nixosModules { }
      );
      homeConfigurations = lib.dotfiles.flattenAttrset (
        lib.dotfiles.genConfigsFromModules lib.dotfiles.const.homeModules { }
      );
      darwinConfigurations."ArtSci-0KPQC4CF" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          hosts/artsci/configuration.nix
          home-manager.darwinModules.home-manager
        ];
      };
      nixosModules = {
        lib = {
          lib.dotfiles = lib.dotfiles;
        };
      };
      homeModules = {
        inherit (self.nixosModules) lib;
      };
    };
}
