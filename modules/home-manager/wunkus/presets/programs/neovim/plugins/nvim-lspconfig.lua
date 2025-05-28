-- nvim-lspconfig.lua
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
lspconfig.pyright.setup({ capabilities = capabilities })
lspconfig.gopls.setup({ capabilities = capabilities })
lspconfig.nixd.setup({
	capabilities = capabilities,
	settings = {
		nixd = {
			options = {
				home_manager = {
					expr = [[(builtins.getFlake "github:jtompkin/dotfiles").homeConfigurations."none@completion".options]],
					--expr = [[(builtins.getFlake "/home/josh/dotfiles").homeConfigurations."completion".options]],
				},
				nixos = {
					expr = [[(builtins.getFlake "github:jtompkin/dotfiles").nixosConfigurations."completion".options]],
					--expr = [[(builtins.getFlake "/home/josh/dotfiles").nixosConfigurations."completion".options]],
				},
			},
		},
	},
})
lspconfig.lua_ls.setup({
	capabilities = capabilities,
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				--path ~= vim.fn.stdpath("config")
				path ~= vim.fn.expand("~/dotfiles")
				and (
					vim.loop.fs_stat(path .. "/.luarc.json")
					or vim.loop.fs_stat(path .. "/.luarc.jsonc")
				)
			then
				return
			end
		end

		client.config.settings.Lua =
			vim.tbl_deep_extend("force", client.config.settings.Lua, {
				runtime = {
					-- Tell the language server which version of Lua you're using
					-- (most likely LuaJIT in the case of Neovim)
					version = "LuaJIT",
				},
				-- Make the server aware of Neovim runtime files
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
						-- Depending on the usage, you might want to add additional paths here.
						-- "${3rd}/luv/library"
						-- "${3rd}/busted/library",
					},
					-- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
					-- library = vim.api.nvim_get_runtime_file("", true)
				},
			})
	end,
	settings = {
		Lua = {},
	},
})
