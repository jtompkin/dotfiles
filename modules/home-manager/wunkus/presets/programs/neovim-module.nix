{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
  enablePluginList =
    pluginList:
    lib.listToAttrs (
      lib.map (plugin: lib.nameValuePair plugin { enable = lib.mkDefault true; }) pluginList
    );
  cfg = config.wunkus.presets.programs.neovim;
in
{
  imports = [ ./neovim/plugins ];
  options.wunkus.presets.programs.neovim = {
    enable = lib.mkEnableOption "Neovim preset configuration";
    dist = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "mini"
          "oldschool"
          "none"
        ]
      );
      default = null;
      description = "Name of preset set of plugins to enable. \"none\" will not enable any plugins by default";
    };
    nixConfigDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = config.wunkus.settings.flakeDir;
      description = "Path to flake directory with NixOS and Home Manager configurations for nixd completion options";
    };
    supportedLangs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "go"
        "lua"
        "markdown"
        "nix"
        "python"
      ];
      description = "List of filetypes to enable nvim-treesitter highlighting for";
    };
  };
  config = lib.mkIf cfg.enable {
    wunkus.presets.programs.neovim.plugins = {
      enable = mkDefault true;
      pluginMapping = {
        nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      };
      plugins = lib.mkMerge [
        {
          nvim-lspconfig.extraData = { inherit (cfg) nixConfigDir; };
          nvim-treesitter.extraData = { inherit (cfg) supportedLangs; };
        }
        (lib.mkIf (cfg.dist != "none") (enablePluginList [
          "cellular-automaton-nvim"
          "conform-nvim"
          "neogit"
          "nightfox-nvim"
          "nvim-treesitter"
          "nvim-lspconfig"
          "mini-snippets"
          "nvim-cmp"
          "render-markdown-nvim"
          "markdown-preview-nvim"
        ]))
        (lib.mkIf (cfg.dist == "mini") (enablePluginList [
          "mini-clue"
          "mini-pick"
          "mini-diff"
          "mini-files"
          "mini-git"
          "mini-sessions"
          "mini-starter"
          "mini-icons"
          "mini-jump"
          "mini-notify"
          "mini-pairs"
          "mini-statusline"
          "mini-surround"
        ]))
        (lib.mkIf (cfg.dist == "oldschool") (enablePluginList [
          "fzf-lua"
          "harpoon2"
          "lualine-nvim"
          "neogen"
          "nvim-autopairs"
          "nvim-surround"
          "which-key-nvim"
        ]))
      ];
    };
    programs.neovim = {
      enable = mkDefault true;
      defaultEditor = mkDefault true;
      viAlias = mkDefault true;
      vimAlias = mkDefault true;
      extraLuaConfig = lib.mkMerge [
        (lib.mkBefore ''
          vim.g.mapleader = " "
          vim.g.maplocalleader = "\\"
        '')
        (lib.concatMapStrings (
          f: "-- START: ${baseNameOf f}\n" + lib.readFile f + "-- END: ${baseNameOf f}\n"
        ) (config.lib.dotfiles.listLuaFiles ./data/neovim/config))
      ];
    };
    xdg = {
      configFile.stylua.source = mkDefault ./data/neovim/stylua;
    };
  };
}
