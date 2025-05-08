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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-apps = {
      url = "./apps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      ...
    }:
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
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ hosts/nixos-wsl/configuration.nix ];
      };
      # Steam Deck
      homeConfigurations."deck@steamdeck" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [ hosts/steamdeck/home.nix ];
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
}
