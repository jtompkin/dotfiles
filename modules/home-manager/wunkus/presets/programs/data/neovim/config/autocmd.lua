local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local yank_group = augroup("yank", { clear = true })
autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 70,
		})
	end,
	desc = "Highlight yanked text.",
})

local lsp_group = augroup("lsp", { clear = true })

autocmd("FileType", {
	group = lsp_group,
	pattern = { "nix", "lua", "toml" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})

autocmd("FileType", {
	group = lsp_group,
	pattern = { "markdown" },
	callback = function()
		vim.opt_local.colorcolumn = "79"
		vim.opt_local.textwidth = 79
	end,
})

autocmd("LspAttach", {
	group = lsp_group,
	callback = function(e)
		local function opts(extra)
			local t = { buffer = e.buf }
			for k, v in pairs(extra) do
				t[k] = v
			end
			return t
		end

		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition()
		end, opts({ desc = "Go to definition." }))

		vim.keymap.set("n", "<leader>vws", function()
			vim.lsp.buf.workspace_symbol()
		end, opts({ desc = "Search workspace symbols." }))

		vim.keymap.set("n", "<leader>vd", function()
			vim.diagnostic.open_float()
		end, opts({ desc = "Open diagnostic float." }))

		vim.keymap.set("n", "<leader>vca", function()
			vim.lsp.buf.code_action()
		end, opts({ desc = "Show code actions." }))

		vim.keymap.set("n", "<leader>vrr", function()
			vim.lsp.buf.references()
		end, opts({ desc = "Show object references." }))

		vim.keymap.set("n", "<leader>vrn", function()
			vim.lsp.buf.rename()
		end, opts({ desc = "Rename object in scope." }))

		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, opts({ desc = "Go to previous diagnostic." }))

		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, opts({ desc = "Go to next diagnostic." }))
	end,
})
