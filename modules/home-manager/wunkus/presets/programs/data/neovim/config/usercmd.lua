vim.api.nvim_create_user_command("Zen", function(opts)
	local val = 0
	if string.sub(opts.fargs[1] or "", 1, 1) == "d" then
		val = 2
	end
	vim.o.laststatus = val
	vim.o.showtabline = val
end, {
	desc = "Enable/Disable zen mode (No status-lines)",
	nargs = "?",
	complete = function()
		return { "disable" }
	end,
})
