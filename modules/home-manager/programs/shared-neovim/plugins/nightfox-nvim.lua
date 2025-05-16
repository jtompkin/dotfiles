require("nightfox").setup({
	specs = {
		all = {
			syntax = {
				func = "magenta",
				keyword = "red",
				conditional = "red",
				builtin0 = "pink",
			},
		},
	},
	groups = {
		all = {
			["@variable.parameter"] = { link = "Variable" },
			["@function.builtin"] = { link = "Function" },
			Special = { link = "@keyword" },
		},
	},
	modules = {
		neogit = true,
	},
})
vim.cmd.colorscheme("carbonfox")
vim.cmd.highlight("Normal guibg=none")
