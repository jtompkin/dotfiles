vim.keymap.set("n", "<leader>pv", vim.cmd.Explore, { desc = "Return to file exporer." })
vim.keymap.set(
	"n",
	"<F3>",
	"<cmd>set hlsearch!<CR>",
	{ silent = true, desc = "Toggle search highlighting." }
)

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank into clipboard." })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank into clipboard." })

vim.keymap.set("n", "<LeftDrag>", "<LeftMouse>", { desc = "Disable mouse drag." })
vim.keymap.set("n", "<2-LeftMouse>", "<Nop>", { desc = "Disable mouse double click." })
vim.keymap.set("n", "<3-LeftMouse>", "<Nop>", { desc = "Disable mouse triple click." })
