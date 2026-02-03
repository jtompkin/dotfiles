vim.keymap.set("n", "<leader>pv", vim.cmd.Explore, { desc = "Return to file exporer." })
vim.keymap.set(
	"n",
	"<F3>",
	"<cmd>set hlsearch!<CR>",
	{ silent = true, desc = "Toggle search highlighting." }
)

vim.keymap.set(
	"n",
	"<leader>x",
	"<cmd>!chmod +x %<CR>",
	{ silent = true, desc = "Add execute permissions to current buffer." }
)

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank into clipboard." })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank into clipboard." })
vim.keymap.set("n", "<leader>c", ":!", { desc = "Begin shell command input." })

vim.keymap.set("n", "<LeftDrag>", "<LeftMouse>", { desc = "Disable mouse drag." })
vim.keymap.set("n", "<2-LeftMouse>", "<Nop>", { desc = "Disable mouse double click." })
