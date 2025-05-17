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
    plugin =
      {
        "nvim-treesitter" = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      }
      .${name} or pkgs.vimPlugins.${name};
    type = "lua";
    config = builtins.readFile ./shared-neovim/plugins/${name}.lua;
  };
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
        (mkBefore
          # lua
          ''
            vim.g.mapleader = " "
            vim.g.maplocalleader = "\\"
          ''
        )
        (lib.pipe (lib.filesystem.listFilesRecursive ./.) [
          (lib.filter (p: lib.hasSuffix ".lua" p))
          (lib.concatMapStrings lib.readFile)
        ])
      ];
    };
  };
}
