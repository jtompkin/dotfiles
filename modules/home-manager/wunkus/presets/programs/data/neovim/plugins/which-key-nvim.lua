-- which-key-nvim.lua
-- which-key remaps
local which_key = require("which-key")
vim.keymap.set("n", "<leader>?", function()
	which_key.show({ global = false })
end, { desc = "Buffer local keymaps (which-key)" })
