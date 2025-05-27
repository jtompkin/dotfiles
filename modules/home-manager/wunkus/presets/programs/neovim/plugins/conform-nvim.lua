-- conform-nvim.lua
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
		python = { "black" },
		go = { "gofmt" },
	},
	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = { timeout_ms = 500 },
})

-- conform remaps
vim.keymap.set("n", "<leader>ff", function()
	require("conform").format({ async = true })
end)

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
