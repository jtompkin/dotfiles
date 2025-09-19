-- lualine-nvim.lua
require("lualine").setup({
	sections = {
		lualine_a = { "mode" },
		lualine_b = {
			{
				"branch",
				icon = "󰚄",
			},
			"diff",
			"diagnostics",
		},
		lualine_c = {
			{
				"filename",
				path = 4,
			},
			"searchcount",
			--{
			--	"harpoon2",
			--	icon = "󰄛",
			--	indicators = { "a", "s", "q", "w" },
			--	active_indicators = { "[A]", "[S]", "[Q]", "[W]" },
			--},
		},
		lualine_x = { "filetype", "fileformat" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	extensions = { "fzf" },
})
