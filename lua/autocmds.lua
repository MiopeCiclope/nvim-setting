-- Center cursor on insert
vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	command = "norm zz",
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

-- Provide a :W command (write file)
vim.api.nvim_create_user_command("W", function()
	vim.cmd("write")
end, {})
