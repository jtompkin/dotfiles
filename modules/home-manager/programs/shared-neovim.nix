{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkBefore;
  cfg = config.programs.sharedNeovim;
  mkPluginCfg = name: {
    type = "lua";
    plugin =
      {
        "nvim-treesitter" = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      }
      .${name} or pkgs.vimPlugins.${name};
    config =
      let
        cfgPath = ./shared-neovim/plugins/${name}.lua;
      in
      if lib.pathIsRegularFile cfgPath then builtins.readFile cfgPath else "";
  };
  readDirPaths = dir: lib.mapAttrsToList (name: _type: dir + "/${name}") (builtins.readDir dir);
in
{
  options = {
    programs.sharedNeovim = {
      enable = lib.mkEnableOption "Whether to enable shared neovim module";
      full = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Whether to build neovim with all plugins (default) or just basic configuration";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      plugins = mkIf cfg.full (
        with pkgs.vimPlugins;
        [
          # neogit dependencies
          diffview-nvim
          # nvim-cmp dependencies
          luasnip
          cmp_luasnip
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp-cmdline
          # fzf-lua dependencies
          nvim-web-devicons
        ]
        ++ lib.pipe (builtins.readDir ./shared-neovim/plugins) [
          (lib.filterAttrs (name: type: lib.hasSuffix ".lua" name && type == "regular"))
          lib.attrNames
          (lib.map (lib.removeSuffix ".lua"))
          (lib.map mkPluginCfg)
        ]
      );
      extraPackages =
        with pkgs;
        mkIf cfg.full [
          # LSPs
          nixd # # Nix
          lua-language-server # # Lua
          pyright # # Python
          gopls # # Go
          # Formatters
          nixfmt-rfc-style # # Nix
          stylua # # Lua
          black # # Python
        ];
      extraLuaConfig = mkMerge [
        (mkBefore ''
          vim.g.mapleader = " "
          vim.g.maplocalleader = "\\"
        '')
        (lib.pipe (readDirPaths ./shared-neovim/config) [
          (lib.filter (name: lib.hasSuffix ".lua" name))
          (lib.concatMapStrings lib.readFile)
        ])
      ];
    };
  };
}
