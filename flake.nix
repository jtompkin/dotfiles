{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Ephemeral filesystem management
    impermanence.url = "github:nix-community/impermanence";
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
    # Niri Wayland compositor
    niri-flake = {
      url = "github:sodiboo/niri-flake";
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
    # Theming
    stylix = {
      url = "github:nix-community/stylix";
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
      niri-flake,
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
        lib.dotfiles.genConfigsFromModules "nixos" lib.dotfiles.const.nixosModules { }
      );
      homeConfigurations = lib.dotfiles.flattenAttrset (
        lib.dotfiles.genConfigsFromModules "home" lib.dotfiles.const.homeModules { }
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

      packages = lib.dotfiles.forAllSystems (
        system: pkgs: {
          # WSL fix: https://gist.github.com/mle98/2deb6e0aa1da3aed70a73dad9c29e8f7
          niri-patched = niri-flake.packages.${system}.niri-unstable.overrideAttrs {
            patches = [
              (pkgs.writeText "niri-disable-csd.diff" ''
                --- a/src/backend/winit.rs
                +++ b/src/backend/winit.rs
                @@ -38,6 +38,7 @@ impl Winit {
                     ) -> Result<Self, winit::Error> {
                         let builder = Window::default_attributes()
                             .with_inner_size(LogicalSize::new(1280.0, 800.0))
                +            .with_decorations(false)
                             // .with_resizable(false)
                             .with_title("niri");
                         let (backend, winit) = winit::init_from_attributes(builder)?;
              '')
            ];
          };
        }
      );
      devShells = lib.dotfiles.forAllSystems (
        system: pkgs: {
          default = pkgs.mkShell {
            name = "dotfiles";
            packages = [
              agenix.packages.${system}.default
              pkgs.stylua
              pkgs.lua-language-server
              pkgs.nixfmt
            ];
          };
        }
      );
      inherit (lib.dotfiles.const) formatter;
    };
}
