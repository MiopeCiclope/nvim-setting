local M = {}

-- Toggle diagnostics
function M.toggle_diagnostics()
	local currentValue = vim.diagnostic.config().virtual_text
	vim.diagnostic.config({ virtual_text = not currentValue })
end

function M.is_executable(cmd)
	return vim.fn.executable(cmd) == 1
end

function M.check_dependencies()
	local deps = { "fzf", "git", "bat" }
	local missing = {}

	for _, dep in ipairs(deps) do
		if not M.is_executable(dep) then
			table.insert(missing, dep)
		end
	end

	if #missing > 0 then
		print("Missing dependencies: " .. table.concat(missing, ", "))
		return false
	end
	return true
end

function M.get_temp_file()
	return vim.fn.tempname()
end

function M.cleanup_temp(temp_file)
	pcall(os.remove, temp_file)
end

-- Check if we're in a git repository
function M.is_git_repo()
	local result = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
	return vim.v.shell_error == 0 and result:match("true") ~= nil
end

function M.get_open_buffers()
	return vim.tbl_filter(function(n) return n ~= "" end,
		vim.tbl_map(function(b) return b.name end,
			vim.fn.getbufinfo({ buflisted = 1 })))
end

function M.create_float_window(size)
	local size_percentage = size or 0.95
	local buf = vim.api.nvim_create_buf(false, true)
	return vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.floor(vim.o.columns * size_percentage),
		height = math.floor(vim.o.lines * size_percentage),
		row = math.floor((vim.o.lines - math.floor(vim.o.lines * size_percentage)) / 2),
		col = math.floor((vim.o.columns - math.floor(vim.o.columns * size_percentage)) / 2),
		style = "minimal",
		border = "rounded",
	})
end

function M.open_file(selected_file, line_number)
	vim.cmd("edit " .. vim.fn.fnameescape(selected_file))

	if line_number ~= nil then
		vim.cmd(":" .. line_number)
	end
end

function M.filename_format(filename)
	local cropped_path, tail = filename:match("^(.*)/(.*)$")
	return string.format("%s - %s/", tail, cropped_path)
end

-- Get full path of current buffer
function M.get_full_path()
	return vim.fn.expand("%:p")
end

-- Get path from git repo root to file (fallback to full path if not in git repo)
function M.get_repo_relative_path()
	if not M.is_git_repo() then
		return M.get_full_path()
	end
	local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("%s+", "")
	local full_path = vim.fn.expand("%:p")
	if git_root ~= "" then
		return full_path:sub(#git_root + 2) -- +2 to remove leading slash
	end
	return full_path
end

-- Get filename only
function M.get_filename_only()
	return vim.fn.expand("%:t")
end

return M
