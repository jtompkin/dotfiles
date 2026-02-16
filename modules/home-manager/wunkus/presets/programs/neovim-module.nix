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
    lib.genAttrs pluginList (plugin: {
      enable = lib.mkDefault true;
    });
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
    availableLangs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "go"
        "just"
        "lua"
        "markdown"
        "nix"
        "python"
        "roc"
        "toml"
      ];
      readOnly = true;
      internal = true;
    };
    supportedLangs = lib.mkOption {
      type = lib.types.submodule {
        options = lib.genAttrs cfg.availableLangs (lang: {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable ${lang} Neovim support";
          };
          install = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to install ${lang} editor tools";
          };
        });
      };
      default = { };
      description = "Configuration for languages to support in Neovim";
    };
  };
  config = lib.mkIf cfg.enable {
    wunkus.presets.programs.neovim.plugins = {
      enable = mkDefault true;
      pluginMapping = {
        nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      };
      plugins = lib.mkMerge [
        # Give extraData to plugins unconditionally
        (builtins.mapAttrs (plugin: extraData: { inherit extraData; }) {
          nvim-lspconfig = {
            inherit (cfg)
              nixConfigDir
              nixosConfigName
              homeConfigName
              supportedLangs
              ;
          };
          nvim-treesitter = {
            inherit (cfg) supportedLangs;
          };
          conform-nvim = {
            inherit (cfg) supportedLangs;
          };
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
          "mini-extra"
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
      configFile."tombi/config.toml" = {
        text = ''
          toml-version = "v1.1.0"
        '';
        enable = cfg.supportedLangs.toml.enable;
      };
    };
    home.packages =
      [ ]
      ++ lib.optionals (cfg.supportedLangs.go.install) [
        pkgs.gopls
        pkgs.go
      ]
      ++ lib.optionals (cfg.supportedLangs.just.install) [
        pkgs.just
        pkgs.just-lsp
      ]
      ++ lib.optionals (cfg.supportedLangs.lua.install) [
        pkgs.lua-language-server
        pkgs.stylua
      ]
      ++ lib.optionals (cfg.supportedLangs.nix.install) [
        pkgs.nixd
        pkgs.nixfmt
      ]
      ++ lib.optionals (cfg.supportedLangs.python.install) [
        pkgs.basedpyright
        pkgs.ruff
      ]
      ++ lib.optionals (cfg.supportedLangs.roc.install) [
        pkgs.roc
      ]
      ++ lib.optionals (cfg.supportedLangs.toml.install) [
        pkgs.tombi
      ];
  };
}
