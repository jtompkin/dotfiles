inputs:
let
  lib = inputs.nixpkgs.lib;
  extra = rec {
    allSystems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    linuxSystems = lib.filter (lib.hasSuffix "-linux") allSystems;
    darwinSystems = lib.filter (lib.hasSuffix "-darwin") allSystems;

    forSystems = systems: lib.genAttrs systems;
    forAllSystems = lib.genAttrs allSystems;

    # flattenAttrset taken from: https://github.com/nmasur/dotfiles
    flattenAttrset = attrs: builtins.foldl' lib.mergeAttrs { } (builtins.attrValues attrs);

    genAttrsFromFiles =
      files: f:
      let
        attrLists = lib.pipe files [
          (map (lib.match "\./?([^.]*)(\..*$)"))
          (map lib.head)
          (map (lib.splitString "/"))
        ];
      in
      map (lib.foldl' (acc: elem: acc // { ${elem} = f elem; }) { }) attrLists;
    #files: f:
    #let
    #  attrLists = lib.pipe files [
    #    (map (lib.match "\./?([^.]*)(\..*$)"))
    #    (map lib.head)
    #    (map (lib.splitString "/"))
    #  ];
    #in
    ##map (map (name: lib.nameValuePair name (f name))) attrLists;
    #map flattenAttrset (map (names: lib.genAttrs names f) attrLists);

    listFilesFromDir = dir: map (lib.path.removePrefix dir) (lib.filesystem.listFilesRecursive dir);

    listFilesSuffix =
      suffix: dir: lib.filter (lib.hasSuffix suffix) (lib.filesystem.listFilesRecursive dir);
    listLuaFiles = listFilesSuffix ".lua";
    listNixFiles = listFilesSuffix ".nix";
    listModuleFiles = listFilesSuffix "-module.nix";
    listDefaultFiles =
      dir: lib.filter (file: baseNameOf file == "default.nix") (lib.filesystem.listFilesRecursive dir);
    genImportsFromDir =
      dir:
      lib.genAttrs (map (file: baseNameOf (dirOf file)) (listDefaultFiles dir)) (
        name: import (dir + "/${name}")
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

    mkNixosConfiguration =
      specialArgs: module:
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
      specialArgs: system: module:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { } // specialArgs;
        modules = [
          libModule
          { imports = listModuleFiles ../modules/home-manager; }
          module
        ];
      };

    libModule = {
      lib.lib = extra;
    };
  };
in
lib // extra
