-- neogit.lua
require("neogit").setup({
	mappings = {
		finder = {
			["<c-j>"] = "Next",
			["<c-k>"] = "Previous",
		},
	},
})

-- neogit remaps
local neogit = require("neogit")
vim.keymap.set("n", "<leader>gs", neogit.open, { desc = "Open git integration." })
