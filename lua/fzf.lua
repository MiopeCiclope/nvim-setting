local M = {}

-- Create a unique temporary file for fzf selection
local function get_temp_file()
	local temp_dir = vim.fn.tempname() .. "_fzf"
	vim.fn.mkdir(temp_dir, "p")
	return temp_dir .. "/selection"
end

-- Clean up temporary files
local function cleanup_temp(temp_file)
	if vim.fn.filereadable(temp_file) == 1 then
		os.remove(temp_file)
	end
	local temp_dir = vim.fn.fnamemodify(temp_file, ":h")
	if vim.fn.isdirectory(temp_dir) == 1 then
		vim.fn.delete(temp_dir, "rf")
	end
end

-- Check if we're in a git repository
local function is_git_repo()
	local result = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
	return vim.v.shell_error == 0 and result:match("true") ~= nil
end

-- Main fzf function for git files
function M.git_files()
	if not is_git_repo() then
		print("Not a git repository")
		return
	end

	local temp_file = get_temp_file()
	local buf = vim.api.nvim_create_buf(false, true)

	-- Create floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.8),
		height = math.floor(vim.o.lines * 0.6),
		row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.6)) / 2),
		col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.8)) / 2),
		style = "minimal",
		border = "rounded",
	})

	-- Build fzf command with preview
	local fzf_cmd = "git ls-files | fzf --height 100% --border --preview 'bat --color=always --style=numbers --line-range :500 {}' > "
		.. temp_file

	vim.fn.termopen(fzf_cmd, {
		on_exit = function(_, code, _)
			vim.schedule(function()
				-- Close the window
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end

				-- Process selection if fzf exited successfully
				if code == 0 then
					local file = io.open(temp_file, "r")
					if file then
						local selected_file = file:read("*a"):gsub("^%s+", ""):gsub("%s+$", "")
						file:close()

						if selected_file ~= "" and vim.fn.filereadable(selected_file) == 1 then
							vim.cmd("edit " .. vim.fn.fnameescape(selected_file))
						end
					end
				end

				-- Clean up temporary files
				cleanup_temp(temp_file)
			end)
		end,
	})

	vim.cmd("startinsert")
end

-- Generic fzf function for any command
function M.fzf_command(cmd, preview_cmd)
	local temp_file = get_temp_file()
	local buf = vim.api.nvim_create_buf(false, true)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.8),
		height = math.floor(vim.o.lines * 0.6),
		row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.6)) / 2),
		col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.8)) / 2),
		style = "minimal",
		border = "rounded",
	})

	local fzf_cmd = cmd .. " | fzf --height 100% --border"
	if preview_cmd then
		fzf_cmd = fzf_cmd .. " --preview '" .. preview_cmd .. "'"
	end
	fzf_cmd = fzf_cmd .. " > " .. temp_file

	vim.fn.termopen(fzf_cmd, {
		on_exit = function(_, code, _)
			vim.schedule(function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end

				if code == 0 then
					local file = io.open(temp_file, "r")
					if file then
						local selected = file:read("*a"):gsub("^%s+", ""):gsub("%s+$", "")
						file:close()

						if selected ~= "" then
							return selected
						end
					end
				end

				cleanup_temp(temp_file)
			end)
		end,
	})

	vim.cmd("startinsert")
end

-- Buffer search using fzf
function M.buffers()
	local temp_file = get_temp_file()
	local buf = vim.api.nvim_create_buf(false, true)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.8),
		height = math.floor(vim.o.lines * 0.6),
		row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.6)) / 2),
		col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.8)) / 2),
		style = "minimal",
		border = "rounded",
	})

	local fzf_cmd = "ls -1 | fzf --height 100% --border --preview 'bat --color=always --style=numbers --line-range :500 {}' > "
		.. temp_file

	vim.fn.termopen(fzf_cmd, {
		on_exit = function(_, code, _)
			vim.schedule(function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end

				if code == 0 then
					local file = io.open(temp_file, "r")
					if file then
						local selected_file = file:read("*a"):gsub("^%s+", ""):gsub("%s+$", "")
						file:close()

						if selected_file ~= "" and vim.fn.filereadable(selected_file) == 1 then
							vim.cmd("edit " .. vim.fn.fnameescape(selected_file))
						end
					end
				end

				cleanup_temp(temp_file)
			end)
		end,
	})

	vim.cmd("startinsert")
end

return M
