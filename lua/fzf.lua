local utils = require("utils")
local M = {}

M.PREVIEW_COMMAND = " --preview 'bat --color=always --style=numbers --line-range :500 {}'"
M.FZF_COMMAND = " | fzf --ansi --multi --height 100% --border --bind 'ctrl-q:select-all'"

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

	M.fzf_command(fzf_cmd)
end

function M.default_callback(selected_list)
	if #selected_list > 2 then
		vim.fn.setqflist(selected_list, "r")
		vim.cmd("copen")
	end

	if #selected_list == 1 then
		utils.open_file(selected_list[1].filename)
	end
end

function M.fzf_command(cmd, callback)
	local temp_file = utils.get_temp_file("_fzf")
	local win = utils.create_float_window()

	local callback_function = callback or M.default_callback
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
							local qflist = {}

							for line in string.gmatch(selected, "[^\n]+") do
								local parts = vim.split(line, ":", { plain = true })

								local filename = parts[1]
								local line_number = parts[2] or 1
								local text = parts[3] or ""

								table.insert(qflist, { filename = filename, lnum = line_number, text = text })
							end

							return callback_function(qflist)
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
