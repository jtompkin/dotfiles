lib: rec {
  # Taken from: https://github.com/nmasur/dotfiles
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
  listLuaFiles = dir: listFilesSuffix ".lua" dir;
  listNixFiles = dir: listFilesSuffix ".nix" dir;

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
}
