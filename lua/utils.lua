local M = {}

-- Minimal helper for keymaps (optional, can be skipped if you use vim.keymap.set)
function M.map(mode, keys, command)
	vim.api.nvim_set_keymap(mode, keys, command, { noremap = true })
end

-- Toggle diagnostics
function M.toggle_diagnostics()
	local currentValue = vim.diagnostic.config().virtual_text
	vim.diagnostic.config({ virtual_text = not currentValue })
end

-- Simple autopair setup
function M.setup_autopairs()
	local function makeTagKeymap(char, completion)
		M.map("i", char, char .. completion .. "<Esc>ha")
	end

	local mappings = {
		["{"] = "}",
		["["] = "]",
		["("] = ")",
		['"'] = '"',
		["´"] = "´",
		["`"] = "`",
	}

	for char, completion in pairs(mappings) do
		makeTagKeymap(char, completion)
	end
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

-- Create a unique temporary file for fzf selection
function M.get_temp_file(name)
	local temp_dir = vim.fn.tempname() .. name
	vim.fn.mkdir(temp_dir, "p")
	return temp_dir .. "/tmp"
end

-- Clean up temporary files
function M.cleanup_temp(temp_file)
	if vim.fn.filereadable(temp_file) == 1 then
		os.remove(temp_file)
	end
	local temp_dir = vim.fn.fnamemodify(temp_file, ":h")
	if vim.fn.isdirectory(temp_dir) == 1 then
		vim.fn.delete(temp_dir, "rf")
	end
end

-- Check if we're in a git repository
function M.is_git_repo()
	local result = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
	return vim.v.shell_error == 0 and result:match("true") ~= nil
end

function M.get_open_buffers()
	local buffers = {}
	for i = 1, vim.fn.bufnr("$") do
		if vim.fn.buflisted(i) == 1 and vim.fn.bufexists(i) == 1 then
			local buf_name = vim.fn.bufname(i)
			if buf_name ~= "" then
				table.insert(buffers, buf_name)
			end
		end
	end
	return buffers
end

function M.create_float_window()
	local buf = vim.api.nvim_create_buf(false, true)
	return vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.8),
		height = math.floor(vim.o.lines * 0.6),
		row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.6)) / 2),
		col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.8)) / 2),
		style = "minimal",
		border = "rounded",
	})
end

return M
