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
      homeManagerModules = forAllSystems (filterHostsFromSystem (lib.hasInfix "@"));
    };

    negate = predicate: x: !(predicate x);
    forAllSystems = f: lib.genAttrs const.allSystems f;
    filterHostsFromSystem =
      predicate: system: lib.filterAttrs (host: module: predicate host) const.allSystemModules.${system};

    # flattenAttrset taken from: https://github.com/nmasur/dotfiles
    # { x86_64-linux = { franken = { ... } } } -> { franken = { ... } }
    #flattenAttrset = attrs: builtins.foldl' lib.mergeAttrs { } (builtins.attrValues attrs);
    flattenAttrset = attrs: lib.mergeAttrsList (lib.attrValues attrs);

    listFilesSuffix =
      suffix: dir: lib.filter (lib.hasSuffix suffix) (lib.filesystem.listFilesRecursive dir);
    listLuaFiles = dir: listFilesSuffix ".lua" dir;
    listNixFiles = dir: listFilesSuffix ".nix" dir;
    listModuleFiles = dir: listFilesSuffix "-module.nix" dir;
    listDefaultFiles =
      dir: lib.filter (file: baseNameOf file == "default.nix") (lib.filesystem.listFilesRecursive dir);

    genImportsFromDir =
      dir:
      lib.genAttrs (map (file: baseNameOf (dirOf file)) (listDefaultFiles dir)) (
        name: import (dir + "/${name}")
      );

    mkNixosConfiguration =
      {
        system ? null,
        specialArgs,
        module,
      }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          inputs.home-manager.nixosModules.home-manager
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
          inputs.nixos-wsl.nixosModules.default
          libModule
          { imports = listModuleFiles ../modules/nixos; }
          {
            home-manager = {
              sharedModules = [ libModule ] ++ listModuleFiles ../modules/home-manager;
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
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { } // specialArgs;
        modules = [
          libModule
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

    genConfigsFromModules =
      configMaker: specialArgs: modules:
      flattenAttrset (
        lib.genAttrs (lib.attrNames modules) (
          system:
          let
            getConfigMaker =
              { system, host }:
              if lib.elem system const.darwinSystems then
                mkDarwinConfiguration
              else if lib.hasInfix "@" host then
                mkHomeManagerConfiguration
              else
                mkNixosConfiguration;
          in
          lib.mapAttrs (
            host: module:
            getConfigMaker { inherit system host; } {
              inherit
                specialArgs
                system
                module
                ;
            }
          ) modules.${system}
        )
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
