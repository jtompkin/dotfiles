vim.api.nvim_create_user_command("Zen", function(opts)
	local arg = string.sub(opts.fargs[1] or "", 1, 1)
	local val = ({ [0] = 2, [2] = 0 })[vim.o.laststatus] or vim.o.laststatus ---@type int
	if arg == "d" then
		val = 2
	elseif arg == "e" then
		val = 0
	end
	vim.o.laststatus = val
	vim.o.showtabline = val
end, {
	desc = "Enable/Disable zen mode (No status-lines)",
	nargs = "?",
	complete = function()
		return { "enable", "disable" }
	end,
})
