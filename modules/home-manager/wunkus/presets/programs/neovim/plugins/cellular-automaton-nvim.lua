-- cellular-automaton-nvim.lua
-- CellularAutomaton remaps
vim.keymap.set(
	"n",
	"<leader>fml",
	"<cmd>CellularAutomaton make_it_rain<cr>",
	{ desc = "Make it rain!" }
)
vim.keymap.set(
	"n",
	"<leader>fyl",
	"<cmd>CellularAutomaton game_of_life<cr>",
	{ desc = "Game of life!" }
)
vim.keymap.set(
	"n",
	"<leader>fol",
	"<cmd>CellularAutomaton scramble<cr>",
	{ desc = "Scramble!" }
)
