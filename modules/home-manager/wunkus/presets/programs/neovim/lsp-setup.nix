{
  pkgs,
  lib,
  nixConfigDir ? "",
}:
# lua
''
  local function config_and_enable(server, config)
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
  end
  config_and_enable("pyright", {
    cmd = { "${lib.getExe' pkgs.pyright "pyright-langserver"}", "--stdio" }
  })
  config_and_enable("gopls", {
    cmd = { "${lib.getExe pkgs.gopls}" }
  })
  config_and_enable("nixd", {
    cmd = { "${lib.getExe pkgs.nixd}" }
    settings = {
      nixd = {
        options = {
          nixos = {
            expr = '(builtins.getFlake ("${nixConfigDir}")).nixosConfigurations.completion.options',
          },
          home_manager = {
            expr = '(builtins.getFlake ("${nixConfigDir}")).homeConfigurations."none@completion".options',
          },
        },
      },
    },
  })
  config_and_enable("lua_ls", {
    cmd = { "${lib.getExe pkgs.lua-language-server}" },
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if 
          path ~= vim.fn.stdpath("config")
          and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using (most
          -- likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
          -- Tell the language server how to find Lua modules same way as Neovim
          -- (see `:h lua-module-load`)
          path = {
            "lua/?.lua",
            "lua/?/init.lua",
          },
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME
            -- Depending on the usage, you might want to add additional paths
            -- here.
            -- "''${3rd}/luv/library"
            -- "''${3rd}/busted/library"
          }
          -- Or pull in all of 'runtimepath'.
          -- NOTE: this is a lot slower and will cause issues when working on
          -- your own configuration.
          -- See https://github.com/neovim/nvim-lspconfig/issues/3189
          -- library = {
          --   vim.api.nvim_get_runtime_file("", true),
          -- }
        }
      })
    end,
    settings = {
      Lua = {}
    }
  })
''
