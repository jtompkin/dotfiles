# This file requires "nixpkgs" to be in inputs
inputs:
let
  lib = inputs.nixpkgs.lib;
  extra = rec {
    const = {
      allSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      linuxSystems = lib.filter (lib.hasSuffix "-linux") const.allSystems;
      darwinSystems = lib.filter (lib.hasSuffix "-darwin") const.allSystems;
      allSystemModules = forAllSystems (system: genImportsFromDir ../hosts/${system});
      nixosModules = lib.genAttrs const.linuxSystems (filterHostsFromSystem (negate (lib.hasInfix "@")));
      darwinModules = lib.genAttrs const.darwinSystems (
        filterHostsFromSystem (negate (lib.hasInfix "@"))
      );
      homeModules = forAllSystems (filterHostsFromSystem (lib.hasInfix "@"));
      overlays = [
        inputs.nixgl.overlay
        inputs.goclacker.overlays.default
      ];
      pkgsBySystem = forAllSystems (
        system:
        import inputs.nixpkgs {
          localSystem = { inherit system; };
          inherit (const) overlays;
        }
      );
    };

    negate = predicate: x: !(predicate x);
    forAllSystems = f: lib.genAttrs const.allSystems f;
    filterHostsFromSystem =
      predicate: system: lib.filterAttrs (host: module: predicate host) const.allSystemModules.${system};

    # { x86_64-linux = { franken = { ... } } } -> { franken = { ... } }
    flattenAttrset = attrs: lib.mergeAttrsList (lib.attrValues attrs);

    listFilesSuffix =
      suffix: dir: lib.filter (lib.hasSuffix suffix) (lib.filesystem.listFilesRecursive dir);
    listLuaFiles = dir: listFilesSuffix ".lua" dir;
    listNixFiles = dir: listFilesSuffix ".nix" dir;
    listModuleFiles = dir: listFilesSuffix "-module.nix" dir;
    listDefaultFiles =
      dir: lib.filter (file: baseNameOf file == "default.nix") (lib.filesystem.listFilesRecursive dir);

    # Recurse into dir and return attrset of imported default.nix files as values and
    # their containing directory as keys
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
          inputs.home-manager.nixosModules.home-manager
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
          inputs.nixos-wsl.nixosModules.default
          libModule
          { imports = listModuleFiles ../modules/nixos; }
          { nixpkgs.pkgs = const.pkgsBySystem.${system}; }
          {
            home-manager = {
              sharedModules = [
                libModule
                inputs.goclacker.homeModules.default
              ] ++ listModuleFiles ../modules/home-manager;
              extraSpecialArgs = { } // specialArgs;
              useUserPackages = lib.mkDefault true;
              useGlobalPkgs = lib.mkDefault true;
            };
          }
          module
        ];
      };

    mkHomeManagerConfiguration =
      {
        system,
        specialArgs,
        module,
      }:
      inputs.home-manager.lib.homeManagerConfiguration {
        #pkgs = inputs.nixpkgs.legacyPackages.${system};
        pkgs = const.pkgsBySystem.${system};
        extraSpecialArgs = { } // specialArgs;
        modules = [
          libModule
          inputs.goclacker.homeModules.default
          { imports = listModuleFiles ../modules/home-manager; }
          module
        ];
      };
    mkDarwinConfiguration =
      {
        system,
        specialArgs,
        module,
      }:
      abort "Not implemented";

    /**
      modules: { <system> = { <host> = <module>; }; }
    */
    genConfigsFromModules =
      modules: specialArgs:
      let
        getConfigMaker =
          system: host:
          if lib.elem system const.darwinSystems then
            mkDarwinConfiguration
          else if lib.hasInfix "@" host then
            mkHomeManagerConfiguration
          else
            mkNixosConfiguration;
      in
      lib.genAttrs (lib.attrNames modules) (
        system:
        lib.mapAttrs (
          host: module:
          getConfigMaker system host {
            inherit
              specialArgs
              system
              module
              ;
          }
        ) modules.${system}
      );

    # Generate a Neovim plugin config suitable for home-manager containing configuration
    # from a file
    mkNeovimPluginCfgFromFile =
      vimPlugins: pluginMapping: cfgPath:
      let
        pluginName = lib.removeSuffix ".lua" (baseNameOf cfgPath);
      in
      {
        type = "lua";
        plugin = pluginMapping.${pluginName} or vimPlugins.${pluginName};
        config = if lib.pathExists cfgPath then lib.readFile cfgPath else "";
      };

    libModule = {
      lib.lib = extra;
    };
  };
in
lib // extra
