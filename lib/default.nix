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
    allSystemModules = forAllSystems (system: genImportsFromDir ../hosts/${system});
    nixosModules = lib.genAttrs const.linuxSystems (
      filterHostsFromSystem (negatePredicate (lib.hasInfix "@"))
    );
    darwinModules = lib.genAttrs const.darwinSystems (
      filterHostsFromSystem (negatePredicate (lib.hasInfix "@"))
    );
    homeModules = forAllSystems (filterHostsFromSystem (lib.hasInfix "@"));
    overlays = [
      inputs.nixgl.overlay
    ];
    pkgsBySystem = forAllSystems (
      system:
      import inputs.nixpkgs {
        inherit (const) overlays;
        localSystem = { inherit system; };
        config.allowUnfree = true;
      }
    );
  };

  negatePredicate = predicate: x: !(predicate x);
  forAllSystems = f: lib.genAttrs const.allSystems f;
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
        inputs.determinate.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        inputs.impermanence.nixosModules.impermanence
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nixos-wsl.nixosModules.default
        inputs.self.nixosModules.lib
        {
          imports = listModuleFiles ../modules/nixos;
          age.secrets.password1.file = ../secrets/password1.age;
          nixpkgs.pkgs = const.pkgsBySystem.${system};
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
        inputs.self.homeModules.lib
        inputs.walker.homeManagerModules.default
        {
          imports = listModuleFiles ../modules/home-manager;
          age.secrets = {
            spotify-client-id-01.file = ../secrets/spotify-client-id-01.age;
            spotify-secret-01.file = ../secrets/spotify-secret-01.age;
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
        host: module: getConfigMaker system host { inherit module specialArgs system; }
      ) modules.${system}
    );

  /**
    Generate a Neovim plugin config suitable for home-manager containing configuration
    from a file
  */
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
}
