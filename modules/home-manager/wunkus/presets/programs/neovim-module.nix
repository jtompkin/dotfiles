{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkBefore
    mkDefault
    mkIf
    mkMerge
    ;
  inherit (config.lib.dotfiles) listLuaFiles;
  cfg = config.wunkus.presets.programs.neovim;
in
{
  imports = [ ./neovim/plugins ];
  options.wunkus.presets.programs.neovim = {
    enable = lib.mkEnableOption "Neovim preset configuration";
    minimal = lib.mkEnableOption "building neovim with all plugins (false) or just basic configuration (true)";
    nixConfigDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory or ""}/dotfiles";
      description = "Path to flake directory with NixOS and Home Manager configurations for nixd completion options";
    };
  };
  config = mkIf cfg.enable {
    wunkus.presets.programs.neovim.plugins = {
      enable = mkDefault true;
      pluginMapping = {
        nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      };
      plugins = {
        cellular-automaton-nvim.enable = mkDefault true;
        conform-nvim.enable = mkDefault true;
        fzf-lua.enable = mkDefault true;
        harpoon2.enable = mkDefault true;
        lualine-nvim.enable = mkDefault true;
        neogit.enable = mkDefault true;
        nightfox-nvim.enable = mkDefault true;
        nvim-autopairs.enable = mkDefault true;
        nvim-cmp.enable = mkDefault true;
        nvim-lspconfig = {
          enable = mkDefault true;
          extraData = { inherit (cfg) nixConfigDir; };
        };
        nvim-surround.enable = mkDefault true;
        nvim-treesitter.enable = mkDefault true;
        which-key-nvim.enable = mkDefault true;
      };
    };
    programs.neovim = {
      enable = mkDefault true;
      defaultEditor = mkDefault true;
      viAlias = mkDefault true;
      vimAlias = mkDefault true;
      extraLuaConfig = mkMerge [
        (mkBefore ''
          vim.g.mapleader = " "
          vim.g.maplocalleader = "\\"
        '')
        (lib.concatMapStrings lib.readFile (listLuaFiles ./data/neovim/config))
      ];
    };
    xdg = {
      configFile.stylua.source = mkDefault ./data/neovim/stylua;
    };
  };
}
