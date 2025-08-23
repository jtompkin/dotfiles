{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Alternate Nix implementation
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    # Ephemeral filesystem management
    impermanence.url = "github:nix-community/impermanence";
    # GUI apps on non-NixOS support
    nixgl.url = "github:nix-community/nixGL";
    # Secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Disk partitioning and configuration
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # User profile and home directory management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Secure boot support
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Personal packages and modules
    mornix = {
      url = "github:jtompkin/mornix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # WSL2 support
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # MacOS support
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      self,
      agenix,
      home-manager,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      lib = nixpkgs.lib // {
        dotfiles = import ./lib { inherit inputs; };
      };
    in
    {
      /*
        Host       : Description   : System
        ixodes     : Laptop        : x86-64-linux (dual-boot)
        franken    : WSL2          : x86_64-linux
        imperfect  : Virtualbox vm : x86_64-linux
        steamdeck  : Steam Deck    : x86_64-linux (home-manager)
        ArtSci-*   : Lab Macs      : aarch64-darwin (nix-darwin)
        completion : Dummy for LSP : x86_64-linux (fake)
      */
      nixosConfigurations = lib.dotfiles.flattenAttrset (
        lib.dotfiles.genConfigsFromModules lib.dotfiles.const.nixosModules { }
      );
      homeConfigurations = lib.dotfiles.flattenAttrset (
        lib.dotfiles.genConfigsFromModules lib.dotfiles.const.homeModules { }
      );
      darwinConfigurations."ArtSci-0KPQC4CF" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/artsci/configuration.nix
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

      devShells = lib.dotfiles.forAllSystems (
        system:
        let
          pkgs = lib.dotfiles.const.pkgsBySystem.${system};
        in
        {
          default = pkgs.mkShell { packages = [ agenix.packages.${system}.default ]; };
        }
      );
    };
}
