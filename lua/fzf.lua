local utils = require("utils")
local M = {}

M.PREVIEW_COMMAND = " --preview 'bat --color=always --style=numbers --line-range :500 {}'"
M.FZF_COMMAND = " | fzf --ansi --multi --height 100% --border"

function M.open_file(selected_file, line_number)
	vim.cmd("edit " .. vim.fn.fnameescape(selected_file))

	if line_number ~= nil then
		vim.cmd(":" .. line_number)
	end
end

-- Main fzf function for git files
function M.git_files()
	if not utils.check_dependencies() then
		return
	end

	if not utils.is_git_repo() then
		print("Not a git repository")
		return
	end

	M.fzf_command("git ls-files" .. M.FZF_COMMAND .. M.PREVIEW_COMMAND)
end

-- Buffer search using fzf
function M.buffers()
	if not utils.check_dependencies() then
		return
	end

	-- Get list of open buffers with better formatting
	local buffers = utils.get_open_buffers() or {}

	if #buffers == 0 then
		print("No buffers available")
		return
	end

	-- Create the fzf command with buffer list as input
	local buffers_input = table.concat(buffers, "\n")
	local fzf_cmd = string.format("echo %s ", vim.fn.shellescape(buffers_input)) .. M.FZF_COMMAND .. M.PREVIEW_COMMAND

	M.fzf_command(fzf_cmd)
end

function M.grep_search()
	if not utils.check_dependencies() then
		return
	end

	if not utils.is_git_repo() then
		print("Not a git repository")
		return
	end

	local pattern = vim.fn.input("Grep Search: ")
	if pattern == "" or pattern == nil then
		return
	end

	local fzf_cmd = "git grep -i --line-number --color=always "
		.. pattern
		.. M.FZF_COMMAND
		.. " --delimiter=':' --preview 'bat --style=numbers --color=always --highlight-line {2} --line-range {2}:+20 {1}'"

	print(fzf_cmd)
	M.fzf_command(fzf_cmd, function(selected)
		local parts = vim.split(selected, ":", { plain = true })

		local filename = parts[1]
		local line_number = parts[2]

		M.open_file(filename, line_number)
	end)
end

function M.fzf_command(cmd, callback)
	local temp_file = utils.get_temp_file("_fzf")
	local win = utils.create_float_window()

	local callback_function = callback or M.open_file
	local fzf_cmd = cmd .. " > " .. temp_file

	vim.fn.jobstart(fzf_cmd, {
		term = true,
		pty = true,
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
							return callback_function(selected)
						end
					end
				end

				utils.cleanup_temp(temp_file)
			end)
		end,
	})

	vim.cmd("startinsert")
end

return M
