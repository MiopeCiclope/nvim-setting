local utils = require("utils")
local M = {}

M.PREVIEW_COMMAND = "bat --color=always --style=numbers --line-range :500 {}"

function M.open_file(selected_file)
	vim.cmd("edit " .. vim.fn.fnameescape(selected_file))
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

	M.fzf_command("git ls-files")
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
	local fzf_cmd = string.format("echo %s", vim.fn.shellescape(buffers_input))

	M.fzf_command(fzf_cmd)
end

function M.fzf_command(cmd, preview_cmd, callback)
	local temp_file = utils.get_temp_file("_fzf")
	local win = utils.create_float_window()

	local preview = preview_cmd or M.PREVIEW_COMMAND
	local callback_function = callback or M.open_file

	local fzf_cmd = cmd .. " | fzf --height 100% --border"
	fzf_cmd = fzf_cmd .. " --preview '" .. preview .. "'"
	fzf_cmd = fzf_cmd .. " > " .. temp_file

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
