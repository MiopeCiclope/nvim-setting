local utils = require("utils")
local M = {}

local FZF = "| fzf --ansi --multi --cycle --height 100% --border --bind 'ctrl-q:select-all' --delimiter=' - ' --with-nth=1,2"

local STAGES = {
	display = {
		file = [[| awk -F'/' '{n=NF; filename=$n; if (n > 4) path=".../" $(n-2) "/" $(n-1) "/" $n; else path=$0; print filename " - " path " - " $0}']],
		grep = [[| awk -F':' '{filename=$1; rest=$0; sub(/[^:]*:/, "", rest); gsub(/:/, " - ", rest); split(filename, parts, "/"); print parts[length(parts)] " - " filename " - " rest}']],
	},
	preview = {
		file = "--preview 'bat --color=always --style=numbers --line-range :500 {3}'",
		grep = "--preview 'bat --color=always --style=numbers --highlight-line {3} --line-range {3}:+20 {2}'",
	},
	extract = {
		path      = "| awk -F' - ' '{print $3}'",
		path_line = "| awk -F' - ' '{print $2 \":\" $3}'",
	},
}

function M.run(spec)
	return function()
		if not utils.check_dependencies(spec.deps) then return end
		if spec.requires_git and not utils.is_git_repo() then
			print("Not a git repository")
			return
		end

		local source = type(spec.source) == "function" and spec.source() or spec.source
		if not source then return end

		local cmd = source
			.. " " .. STAGES.display[spec.display]
			.. " " .. FZF
			.. " " .. STAGES.preview[spec.preview]
			.. " " .. STAGES.extract[spec.extract]

		M.fzf_command(cmd)
	end
end

function M.single_file_callback(item)
	utils.open_file(item.filename, item.lnum)
end

function M.multi_file_callback(selected_list)
	vim.fn.setqflist(selected_list, "r")
	vim.cmd("copen")
end

function M.default_callback(selected_list)
	if #selected_list == 1 then
		M.single_file_callback(selected_list[1])
	elseif #selected_list > 1 then
		M.multi_file_callback(selected_list)
	end
end

function M.fzf_command(cmd, callback)
	local temp_file = utils.get_temp_file()
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
								table.insert(qflist, {
									filename = parts[1],
									lnum     = tonumber(parts[2]) or 1,
									text     = parts[3] or "",
								})
							end
							utils.cleanup_temp(temp_file)
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
