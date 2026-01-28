{
  inputs ? null,
  lib ? inputs.nixpkgs.lib,
}:
rec {
  const = {
    allSystems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    linuxSystems = lib.filter (lib.hasSuffix "-linux") const.allSystems;
    darwinSystems = lib.filter (lib.hasSuffix "-darwin") const.allSystems;
    allSystemModules = forAllSystems (system: _: genImportsFromDir ../hosts/${system});
    nixosModules = lib.genAttrs const.linuxSystems (
      filterHostsFromSystem (negatePredicate (lib.hasInfix "@"))
    );
    darwinModules = lib.genAttrs const.darwinSystems (
      filterHostsFromSystem (negatePredicate (lib.hasInfix "@"))
    );
    homeModules = forAllSystems (system: _: filterHostsFromSystem (lib.hasInfix "@") system);
    overlays = [
      inputs.niri-flake.overlays.niri
      (final: prev: inputs.self.packages.${prev.stdenv.hostPlatform.system})
    ];
    pkgsBySystem = forAllSystems (_: pkgs: pkgs);
    formatter = forAllSystems (_: pkgs: pkgs.nixfmt-tree);
    inherit (inputs) self;
  };
  /**
    Args:
      f <func> : Function that takes two arguments: `system` and `pkgs`
    Returns:
      Attribute set that is the result of applying `f` to every `system` in `allSystems`
  */
  forAllSystems =
    f:
    lib.genAttrs const.allSystems (
      system:
      f system (
        import inputs.nixpkgs {
          inherit (const) overlays;
          localSystem = { inherit system; };
          config.allowUnfree = true;
        }
      )
    );
  negatePredicate = predicate: x: !(predicate x);
  filterHostsFromSystem =
    predicate: system: lib.filterAttrs (host: module: predicate host) const.allSystemModules.${system};

  /**
    { x86_64-linux = { franken = { ... } } } -> { franken = { ... } }
  */
  flattenAttrset = attrs: lib.mergeAttrsList (lib.attrValues attrs);

  listFilesSuffix =
    suffix: dir: lib.filter (lib.hasSuffix suffix) (lib.filesystem.listFilesRecursive dir);
  listLuaFiles = dir: listFilesSuffix ".lua" dir;
  listNixFiles = dir: listFilesSuffix ".nix" dir;
  listModuleFiles = dir: listFilesSuffix "-module.nix" dir;
  listDefaultFiles =
    dir: lib.filter (file: baseNameOf file == "default.nix") (lib.filesystem.listFilesRecursive dir);

  /**
    Recurse into dir and return attrset of imported default.nix files as values and
    their containing directory as keys
  */
  genImportsFromDir =
    dir:
    lib.genAttrs (map (file: baseNameOf (dirOf file)) (listDefaultFiles dir)) (
      name: import (dir + "/${name}")
    );

  mkNixosConfiguration =
    {
      module,
      specialArgs,
      system,
    }:
    lib.nixosSystem {
      inherit specialArgs;
      modules = [
        inputs.agenix.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        inputs.impermanence.nixosModules.impermanence
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.niri-flake.nixosModules.niri
        inputs.nixos-wsl.nixosModules.default
        inputs.self.nixosModules.lib
        inputs.stylix.nixosModules.stylix
        {
          imports = listModuleFiles ../modules/nixos;
          nixpkgs.pkgs = const.pkgsBySystem.${system};
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          home-manager = {
            extraSpecialArgs = specialArgs;
            useUserPackages = lib.mkDefault true;
            useGlobalPkgs = lib.mkDefault true;
          };
        }
        module
      ];
    };

  mkHomeManagerConfiguration =
    {
      module,
      specialArgs,
      system,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = const.pkgsBySystem.${system};
      extraSpecialArgs = specialArgs;
      modules = [
        inputs.agenix.homeManagerModules.default
        inputs.mornix.homeModules.default
        inputs.niri-flake.homeModules.niri
        inputs.niri-flake.homeModules.stylix
        inputs.self.homeModules.lib
        inputs.stylix.homeModules.stylix
        {
          imports = listModuleFiles ../modules/home-manager;
          nix = {
            package = const.pkgsBySystem.${system}.nix;
            channels = { inherit (inputs) nixpkgs; };
            settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          };
        }
        module
      ];
    };

  mkDarwinConfiguration =
    {
      # module,
      # specialArgs,
      # system,
      ...
    }:
    abort "Not implemented";

  /**
    modules: specialArgs: { <system> = { <host> = <config>; }; }
  */
  genConfigsFromModules =
    type: modules: specialArgs:
    lib.genAttrs (lib.attrNames modules) (
      system:
      lib.mapAttrs (
        host: module:
        (
          {
            nixos = mkNixosConfiguration;
            home = mkHomeManagerConfiguration;
            darwin = mkDarwinConfiguration;
          }
          .${type}
        )
          { inherit module specialArgs system; }
      ) modules.${system}
    );

  types = {
    defaultApp =
      { config, name, ... }:
      let
        appTypeToApps = {
          terminal = [
            "kitty"
            "alacritty"
            "foot"
          ];
          fileManager = [ "thunar" ];
          appLauncher = [
            "fuzzel"
            "anyrun"
          ];
          screenShotter = [
            "hyprshot"
            "flameshot"
          ];
          imageViewer = [ "feh" ];
          videoPlayer = [ "mpv" ];
        };
      in
      {
        options = {
          name = lib.mkOption {
            type = lib.types.enum appTypeToApps.${config.appType};
            default = lib.head appTypeToApps.${config.appType};
            description = "Name of the program to be used as the default application for this application type";
          };
          appType = lib.mkOption {
            type = lib.types.enum (lib.attrNames appTypeToApps);
            default = name;
            readOnly = true;
            description = "Class of the program, based on the name";
          };
          package = lib.mkOption {
            type = lib.types.package;
            description = "Package to use for app";
          };
        };
      };
  };
}
