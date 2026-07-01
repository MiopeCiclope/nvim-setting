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

-- JSON Tree-sitter highlighting for .pm files (LSP stays as model_compiler)
vim.treesitter.language.register("json", "pagemodel")

vim.cmd("command! W write")

-- Copy full path to clipboard
vim.api.nvim_create_user_command("CopyFullPath", function()
	local path = require("utils").get_full_path()
	vim.fn.setreg("+", path)
end, {})

-- Copy repo-relative path to clipboard
vim.api.nvim_create_user_command("CopyRepoPath", function()
	local path = require("utils").get_repo_relative_path()
	vim.fn.setreg("+", path)
end, {})

-- Copy filename only to clipboard
vim.api.nvim_create_user_command("CopyFileName", function()
	local filename = require("utils").get_filename_only()
	vim.fn.setreg("+", filename)
end, {})
