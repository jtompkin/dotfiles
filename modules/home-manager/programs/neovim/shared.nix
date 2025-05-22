{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge mkBefore;
  inherit (config.lib.custom) listLuaFiles mkNeovimPluginCfgFromFile;
  cfg = config.programs.neovim.shared;
in
{
  imports = [

  ];
  options = {
    programs.neovim.shared.enable = lib.mkEnableOption "shared neovim configuration";
    programs.neovim.shared.minimal = lib.mkEnableOption "building neovim with all plugins (false) or just basic configuration (true)";
  };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      plugins = mkIf (!cfg.minimal) (
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
        ++ map (mkNeovimPluginCfgFromFile pkgs.vimPlugins {
          # Add plugin mappings here, otherwise basename of file is plugin name
          "nvim-treesitter" = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        }) (listLuaFiles ./shared/plugins)
      );
      extraPackages =
        with pkgs;
        mkIf (!cfg.minimal) [
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
        (lib.concatMapStrings lib.readFile (listLuaFiles ./shared/config))
      ];
    };
  };
}
