{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixgl.url = "github:nix-community/nixGL";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin"];
      imports = [./modules/configs.nix];
      flake = {
        # VirtualBox x86_64-linux vm
        nixosConfigurations."imperfect" = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [hosts/imperfect/configuration.nix];
        };
        # VirtualBox x86_64-linux vm with zfs
        nixosConfigurations."zeefess" = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [hosts/zeefess/configuration.nix];
        };
        # QEMU x86_64-linux vm
        # WSL2
        nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [hosts/nixos-wsl/configuration.nix];
        };
        # Steam Deck
        homeConfigurations."deck@steamdeck" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = {inherit inputs;};
          modules = [hosts/steamdeck/home.nix];
        };
        # lab mac
        darwinConfigurations."ArtSci-0KPQC4CF" = nix-darwin.lib.darwinSystem {
          specialArgs = {inherit inputs;};
          modules = [
            hosts/artsci/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.benoitja = hosts/artsci/home.nix;
                extraSpecialArgs = {inherit inputs;};
              };
            }
          ];
        };
        # Dummy for completion
        homeConfigurations."completion" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            {
              home = {
                username = "none";
                homeDirectory = "/home/none";
                stateVersion = "24.11";
              };
            }
          ];
        };
      };
      perSystem = {pkgs, ...}: {
        configs = {
          neovim = {
            full = import ./apps/configs/neovim/full {inherit pkgs;};
          };
        };
        packages = {
          goclacker = pkgs.callPackage ./apps/pkgs/goclacker/package.nix {};
        };
      };
    };
}
