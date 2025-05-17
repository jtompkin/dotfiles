-- fzf-lua remaps
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>pf", fzf.files, { desc = "Show files using fzf." })
vim.keymap.set("n", "<leader>ps", fzf.grep, { desc = "Grep in files using fzf." })
vim.keymap.set(
	"n",
	"<leader>pp",
	fzf.grep_project,
	{ desc = "Grep project using fzf." }
)
vim.keymap.set(
	"n",
	"<leader>pw",
	fzf.grep_cword,
	{ desc = "Grep word under cursor using fzf." }
)
vim.keymap.set(
	"n",
	"<leader>pW",
	fzf.grep_cWORD,
	{ desc = "Grep WORD under cursor using fzf." }
)
vim.keymap.set(
	"v",
	"pv",
	fzf.grep_visual,
	{ desc = "Grep visual selection using fzf." }
)
