{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.programs.sharedNeovim;
  pluginsNeedCfg = [
    "nvim-lspconfig"
    "nightfox-nvim"
    "conform-nvim"
    "nvim-autopairs"
    "harpoon2"
    "lualine-nvim"
    "neogit"
    "nvim-cmp"
    "fzf-lua"
    "cellular-automaton-nvim"
    "which-key-nvim"
  ];
  mkPluginCfg = name: {
    plugin = pkgs.vimPlugins.${name};
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
          {
            plugin = nvim-treesitter.withAllGrammars;
            type = "lua";
            config = builtins.readFile ./shared-neovim/plugins/nvim-treesitter.lua;
          }
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
        ++ lib.map mkPluginCfg pluginsNeedCfg
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
      extraLuaConfig = lib.concatMapStrings lib.readFile (
        lib.filesystem.listFilesRecursive ./shared-neovim/config
      );
    };
  };
}
