{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.sharedNeovim;
in
{
  options = {
    programs.sharedNeovim = {
      enable = lib.mkEnableOption "Whether to enable shared neovim module";
      full = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Whether to build full or minimal neovim";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.neovim = lib.mkDefault {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = builtins.readFile ./plugins/nvim-lspconfig.lua;
        }
        {
          plugin = conform-nvim;
          type = "lua";
          config = builtins.readFile ./plugins/format.lua;
        }
        {
          plugin = nvim-autopairs;
          type = "lua";
          config =
            # Lua
            ''require("nvim-autopairs").setup({})'';
        }
        {
          plugin = nightfox-nvim;
          type = "lua";
          config = builtins.readFile ./plugins/nightfox-nvim.lua;
        }
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = builtins.readFile ./plugins/nvim-treesitter.lua;
        }
        {
          plugin = harpoon2;
          type = "lua";
          config = builtins.readFile ./plugins/harpoon.lua;
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          config = builtins.readFile ./plugins/lualine-nvim.lua;
        }
        {
          plugin = neogit;
          type = "lua";
          config = builtins.readFile ./plugins/neogit.lua;
        }
        # neogit dependencies
        diffview-nvim

        {
          plugin = nvim-cmp;
          type = "lua";
          config = builtins.readFile ./plugins/nvim-cmp.lua;
        }
        # nvim-cmp dependencies
        luasnip
        cmp_luasnip
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline

        fzf-lua
        # fzf-lua dependencies
        nvim-web-devicons

        cellular-automaton-nvim
        which-key-nvim
      ];
      extraPackages = with pkgs; [
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
      extraLuaConfig =
        builtins.readFile ./config/set.lua
        + builtins.readFile ./config/remap.lua
        + builtins.readFile ./config/autocmd.lua;
    };
  };
}
