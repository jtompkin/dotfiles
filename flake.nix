{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixgl.url = "github:nix-community/nixGL";
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
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      extraModulesPath = ./modules;
      lib = import ./lib inputs;
    in
    {
      # Host       : Description         : System
      # franken    : WSL2                : x86_64-linux
      # imperfect  : Virtualbox vm       : x86_64-linux
      # zeefess    : Virtualbox vm w/zfs : x86_64-linux
      # spinny     : External HDD        : x86_64-linux
      # steamdeck  : Steam Deck          : x86_64-linux (home-manager)
      # ArtSci-*   : Lab Macs            : aarch64-darwin (nix-darwin)
      # completion : Dummy for lsp       : x86_64-linux (fake)
      nixosConfigurations =
        # TODO: replace old configs with shiny new format
        lib.pipe lib.linuxSystems [
          (lib.mapGenAttrs (system: lib.genImportsFromDir ./hosts/${system}))
          lib.flattenAttrset
          (lib.mapAttrs (_host: module: lib.mkNixosConfiguration { } module))
        ]
        // {
          "imperfect" = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [ hosts/imperfect/configuration.nix ];
          };
          "zeefess" = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [ hosts/zeefess/configuration.nix ];
          };
          "spinny" = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [ hosts/spinny/configuration.nix ];
          };
          "completion" = lib.mkNixosConfiguration { } {
            nixpkgs.hostPlatform = "x86_64-linux";
          };
        };
      homeConfigurations."deck@steamdeck" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [ hosts/steamdeck/home.nix ];
      };
      darwinConfigurations."ArtSci-0KPQC4CF" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          hosts/artsci/configuration.nix
          home-manager.darwinModules.home-manager
        ];
      };
      homeConfigurations."completion" = lib.mkHomeManagerConfiguration { } "x86_64-linux" {
        home = {
          username = "none";
          homeDirectory = "/home/none";
          stateVersion = "25.05";
        };
      };
      homeManagerModules.neovim.shared = import (
        extraModulesPath + "/home-manager/programs/neovim/shared.nix"
      );
    };
}
