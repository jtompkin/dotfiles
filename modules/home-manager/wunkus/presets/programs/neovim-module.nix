{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
  cfg = config.wunkus.presets.programs.neovim;
  enablePluginList =
    pluginList:
    lib.listToAttrs (
      lib.map (plugin: lib.nameValuePair plugin { enable = lib.mkDefault true; }) pluginList
    );
  isSupported = lang: lib.elem lang cfg.supportedLangs;
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
    nixosConfigName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Name to use for generating Nixos option completion";
    };
    homeConfigName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Name to use for generating Home Manager option completion";
    };
    supportedLangs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of filetypes to enable support for. Used by nvim-treesitter, conform, nvim-lspconfig";
    };
    installSupportedLangs = lib.mkEnableOption "installing editor tools for supportedLangs";
  };
  config = lib.mkIf cfg.enable {
    wunkus.presets.programs.neovim.plugins = {
      enable = mkDefault true;
      pluginMapping = {
        nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      };
      plugins = lib.mkMerge [
        (builtins.mapAttrs (plugin: extraData: { inherit extraData; }) {
          nvim-lspconfig = {
            inherit (cfg)
              nixConfigDir
              nixosConfigName
              homeConfigName
              supportedLangs
              ;
          };
          nvim-treesitter = { inherit (cfg) supportedLangs; };
          conform-nvim = { inherit (cfg) supportedLangs; };
        })
        (lib.mkIf (cfg.dist != "none") (enablePluginList [
          "cellular-automaton-nvim"
          "conform-nvim"
          "neogit"
          "nightfox-nvim"
          "nvim-treesitter"
          "nvim-treesitter-context"
          "nvim-lspconfig"
          "blink-cmp"
          "render-markdown-nvim"
          "markdown-preview-nvim"
        ]))
        (lib.mkIf (cfg.dist == "mini") (enablePluginList [
          "mini-ai"
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
      initLua = lib.mkMerge [
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
    home.packages = lib.mkIf cfg.installSupportedLangs (
      [ ]
      ++ lib.optionals (isSupported "go") [
        pkgs.gopls
        pkgs.go
      ]
      ++ lib.optionals (isSupported "just") [
        pkgs.just
        pkgs.just-lsp
      ]
      ++ lib.optionals (isSupported "lua") [
        pkgs.lua-language-server
        pkgs.stylua
      ]
      ++ lib.optionals (isSupported "nix") [
        pkgs.nixd
        pkgs.nixfmt
      ]
      ++ lib.optionals (isSupported "python") [
        pkgs.basedpyright
        pkgs.ruff
      ]
      ++ lib.optionals (isSupported "roc") [
        pkgs.roc
      ]
      ++ lib.optionals (isSupported "toml") [
        pkgs.tombi
      ]
    );
  };
}
