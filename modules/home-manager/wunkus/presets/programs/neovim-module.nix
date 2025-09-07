{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkBefore
    mkDefault
    ;
  inherit (config.lib.dotfiles) listLuaFiles mkNeovimPluginCfgFromFile;
  cfg = config.wunkus.presets.programs.neovim;
in
{
  options = {
    wunkus.presets.programs.neovim.enable = lib.mkEnableOption "Neovim preset configuration";
    wunkus.presets.programs.neovim.minimal =
      lib.mkEnableOption "building neovim with all plugins (false) or just basic configuration (true)";
  };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = mkDefault true;
      defaultEditor = mkDefault true;
      viAlias = mkDefault true;
      vimAlias = mkDefault true;
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
        }) (listLuaFiles ./neovim/plugins)
      );
      extraPackages = lib.optionals (!cfg.minimal) (
        with pkgs;
        [
          # LSPs
          nixd # Nix
          lua-language-server # Lua
          pyright # Python
          gopls # Go
          # Formatters
          nixfmt-rfc-style # Nix
          stylua # Lua
          black # Python
        ]
      );
      extraLuaConfig = ''
        vim.g.mapleader = " "
        vim.g.maplocalleader = "\\"
      ''
      + (lib.concatMapStrings lib.readFile (listLuaFiles ./neovim/config));
    };
    xdg = {
      configFile.stylua.source = mkDefault ./neovim/stylua;
    };
  };
}
