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
      # VirtualBox x86_64-linux vm
      nixosConfigurations."imperfect" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ hosts/imperfect/configuration.nix ];
      };
      # VirtualBox x86_64-linux vm with zfs
      nixosConfigurations."zeefess" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ hosts/zeefess/configuration.nix ];
      };
      # QEMU x86_64-linux vm
      # WSL2
      #nixosConfigurations."nixos" = lib.nixosSystem {
      #  specialArgs = { inherit inputs; };
      #  modules = [ hosts/nixos-wsl/configuration.nix ];
      #};
      nixosConfigurations."franken" = lib.mkNixosConfiguration { } ./hosts/x86_64-linux/franken;
      nixosConfigurations."completion" = lib.mkNixosConfiguration { } {
        nixpkgs.hostPlatform = "x86_64-linux";
      };
      # External HDD
      nixosConfigurations."spinny" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ hosts/spinny/configuration.nix ];
      };
      # Steam Deck
      homeConfigurations."deck@steamdeck" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [ hosts/steamdeck/home.nix ];
      };
      # lab mac
      darwinConfigurations."ArtSci-0KPQC4CF" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          hosts/artsci/configuration.nix
          home-manager.darwinModules.home-manager
        ];
      };
      nixosModules.lib = extraModulesPath + "/common/lib.nix";
      homeManagerModules.neovim.shared = import (
        extraModulesPath + "/home-manager/programs/neovim/shared.nix"
      );
      # Dummies for completion
      #nixosConfigurations."completion" = nixpkgs.lib.nixosSystem {
      #  specialArgs = { inherit inputs; };
      #  modules = [
      #    {
      #      imports = [
      #        inputs.nixos-wsl.nixosModules.default
      #        inputs.home-manager.nixosModules.home-manager
      #        inputs.self.nixosModules.lib
      #      ];
      #      nixpkgs.hostPlatform.system = "x86_64-linux";
      #    }
      #  ];
      #};
      homeConfigurations."completion" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [
          {
            imports = [ inputs.self.homeManagerModules.neovim.shared ];
            home = {
              username = "none";
              homeDirectory = "/home/none";
              stateVersion = "24.11";
            };
          }
        ];
      };
    };
}
