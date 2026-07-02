local fzf = require("fzf")
local M = {}

M.git_files = fzf.run({
	source       = "{ git ls-files; git ls-files --others --exclude-standard; }",
	display      = "file",
	preview      = "file",
	extract      = "path",
	deps         = { "fzf", "git", "bat" },
	requires_git = true,
})

M.buffers = fzf.run({
	source = function()
		local bufs = require("utils").get_open_buffers()
		if #bufs == 0 then
			print("No buffers available")
			return nil
		end
		return "echo " .. vim.fn.shellescape(table.concat(bufs, "\n"))
	end,
	display = "file",
	preview = "file",
	extract = "path",
	deps    = { "fzf", "bat" },
})

M.grep_search = fzf.run({
	source = function()
		local ok, p = pcall(vim.fn.input, "Grep Search: ")
		if not ok or p == "" then return nil end
		return "git grep -i --line-number --color=always " .. vim.fn.shellescape(p)
	end,
	display      = "grep",
	preview      = "grep",
	extract      = "path_line",
	deps         = { "fzf", "git", "bat" },
	requires_git = true,
})

return M
