vim.api.nvim_create_user_command("Zen", function()
	if vim.o.laststatus > 0 then
		vim.o.laststatus = 0
	else
		vim.o.laststatus = 2
	end
end, { desc = "Toggle zen mode (No statusline)" })
