vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Return to file exporer." })
vim.keymap.set("n", "<F3>", "<cmd>set hlsearch!<CR>", { silent = true, desc = "Toggle search highlighting." })

vim.keymap.set(
	"n",
	"<leader>x",
	"<cmd>!chmod +x %<CR>",
	{ silent = true, desc = "Add execute permissions to current buffer." }
)

vim.keymap.set("n", "<C-i>", vim.cmd.Inspect, { desc = "Inspect under cursor." })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank into clipboard." })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank into clipboard." })

-- fzf-lua remaps
local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>pf", fzf.files, { desc = "Show files using fzf." })
vim.keymap.set("n", "<leader>ps", fzf.grep, { desc = "Grep in files using fzf." })
vim.keymap.set("n", "<leader>pp", fzf.grep_project, { desc = "Grep project using fzf." })
vim.keymap.set("n", "<leader>pw", fzf.grep_cword, { desc = "Grep word under cursor using fzf." })
vim.keymap.set("n", "<leader>pW", fzf.grep_cWORD, { desc = "Grep WORD under cursor using fzf." })
vim.keymap.set("v", "pv", fzf.grep_visual, { desc = "Grep visual selection using fzf." })

-- CellularAutomaton remaps
vim.keymap.set("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<cr>", { desc = "Make it rain!" })
vim.keymap.set("n", "<leader>fyl", "<cmd>CellularAutomaton game_of_life<cr>", { desc = "Game of life!" })
vim.keymap.set("n", "<leader>fol", "<cmd>CellularAutomaton scramble<cr>", { desc = "Scramble!" })

-- which-key remaps
local which_key = require("which-key")
vim.keymap.set("n", "<leader>?", function()
	which_key.show({ global = false })
end, { desc = "Buffer local keymaps (which-key)" })
