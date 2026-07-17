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

-- Open this repo's orchestra workspace dir (set by dev.sh)
vim.api.nvim_create_user_command("Orchestra", function()
	local dir = vim.env.WORKSPACE_DIR
	if not dir or dir == "" then
		vim.notify("WORKSPACE_DIR not set (launch via `dev <repo>`)", vim.log.levels.WARN)
		return
	end
	vim.cmd("Explore " .. vim.fn.fnameescape(dir))
end, {})

-- Open file at matched line as cursor moves in quickfix list
vim.api.nvim_create_autocmd("CursorMoved", {
	pattern = "quickfix",
	callback = function()
		local idx = vim.fn.line(".")
		local entry = vim.fn.getqflist()[idx]
		if entry and entry.bufnr ~= 0 then
			vim.cmd("cc " .. idx)
			vim.cmd("wincmd p")
		end
	end,
})
