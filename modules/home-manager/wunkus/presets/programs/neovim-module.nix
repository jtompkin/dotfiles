{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
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
        ]
      );
      default = null;
      description = "Name of preset set of plugins to enable";
    };
    nixConfigDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory or ""}/dotfiles";
      description = "Path to flake directory with NixOS and Home Manager configurations for nixd completion options";
    };
  };
  config = lib.mkIf cfg.enable {
    wunkus.presets.programs.neovim.plugins = {
      enable = mkDefault true;
      pluginMapping = {
        nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        # TODO: remove once version is updated in Nixpkgs to one that has preview function
        render-markdown-nvim = pkgs.vimPlugins.render-markdown-nvim.overrideAttrs {
          version = "475d3ad8cae486b0df6fc6050cf5b5ea1de42db8";
          src = pkgs.fetchFromGitHub {
            owner = "MeanderingProgrammer";
            repo = "render-markdown.nvim";
            rev = "475d3ad8cae486b0df6fc6050cf5b5ea1de42db8";
            sha256 = "sha256-BXOBnDVH6e4MUvod5bYvaP9e+TU6UJzDNqNL64tVaAw=";
          };
        };
      };
      plugins = lib.mkMerge [
        {
          cellular-automaton-nvim.enable = mkDefault true;
          conform-nvim.enable = mkDefault true;
          neogit.enable = mkDefault true;
          nightfox-nvim.enable = mkDefault true;
          nvim-treesitter.enable = mkDefault true;
          nvim-lspconfig = {
            enable = mkDefault true;
            extraData = { inherit (cfg) nixConfigDir; };
          };
          mini-snippets.enable = mkDefault true;
          nvim-cmp.enable = mkDefault true;
        }
        (lib.mkIf (cfg.dist == "mini") {
          mini-clue.enable = mkDefault true;
          mini-pick.enable = mkDefault true;
          mini-diff.enable = mkDefault true;
          mini-files.enable = mkDefault true;
          mini-git.enable = mkDefault true;
          mini-sessions.enable = mkDefault true;
          mini-icons.enable = mkDefault true;
          mini-jump.enable = mkDefault true;
          mini-notify.enable = mkDefault true;
          mini-pairs.enable = mkDefault true;
          mini-statusline.enable = mkDefault true;
          mini-surround.enable = mkDefault true;
        })
        (lib.mkIf (cfg.dist == "oldschool") {
          fzf-lua.enable = mkDefault true;
          harpoon2.enable = mkDefault true;
          lualine-nvim.enable = mkDefault true;
          neogen.enable = mkDefault true;
          nvim-autopairs.enable = mkDefault true;
          nvim-surround.enable = mkDefault true;
          which-key-nvim.enable = mkDefault true;
        })
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
