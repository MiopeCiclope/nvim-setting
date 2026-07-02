local utils = require("utils")
local M = {}

---@class FzfSourceResult
---@field cmd string
---@field query string?

---@class FzfBinding
---@field key string
---@field reload string

---@class FzfSpec
---@field source string | fun(): string | FzfSourceResult | nil
---@field display "file" | "grep"
---@field preview "file" | "grep"
---@field extract "path" | "path_line" | "path_line_text"
---@field deps string[]
---@field requires_git boolean?
---@field bindings FzfBinding[]?

local FZF = "| fzf --ansi --multi --cycle --height 100% --border"
	.. " --bind 'ctrl-q:select-all' --delimiter=' - ' --with-nth=1,2"
	.. " --color 'hl:yellow:bold,hl+:cyan:bold'"

local STAGES = {
	display = {
		file = [[| awk -F'/' '{n=NF; filename=$n; if (n==1) dir="."; else if (n<=4) { dir=$1; for(i=2;i<n;i++) dir=dir"/"$i } else dir=".../"$(n-3)"/"$(n-2)"/"$(n-1); print filename " - " dir " - " $0}']],
		grep = [[| awk -F':' '{filename=$1; rest=$0; sub(/[^:]*:/, "", rest); gsub(/:/, " - ", rest); split(filename, parts, "/"); print parts[length(parts)] " - " filename " - " rest}']],
	},
	preview = {
		file = "--preview 'bat --color=always --style=numbers --line-range :500 {3}'",
		grep = "--preview 'bat --color=always --style=numbers --highlight-line {3} --line-range {3}:+20 {2}'",
	},
	extract = {
		path           = "| awk -F' - ' '{print $3}'",
		path_line      = "| awk -F' - ' '{print $2 \":\" $3}'",
		path_line_text = "| awk -F' - ' '{print $2 \":\" $3 \":\" $4}'",
	},
}

---@param spec FzfSpec
---@return fun()
function M.run(spec)
	return function()
		if not utils.check_dependencies(spec.deps) then return end
		if spec.requires_git and not utils.is_git_repo() then
			print("Not a git repository")
			return
		end

		local result = type(spec.source) == "function" and spec.source() or spec.source
		if not result then return end
		local source_cmd   = type(result) == "table" and result.cmd   or result
		local source_query = type(result) == "table" and result.query or nil

		local fzf_flags = FZF
			.. (source_query and " --query " .. vim.fn.shellescape(source_query) or "")

		for _, b in ipairs(spec.bindings or {}) do
			fzf_flags = fzf_flags .. " --bind '" .. b.key .. ":reload(" .. b.reload .. ")'"
		end

		local cmd = source_cmd
			.. " " .. STAGES.display[spec.display]
			.. " " .. fzf_flags
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

---@param cmd string
---@param callback (fun(list: table[]))?
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
						local selected = vim.trim(file:read("*a"))
						file:close()

						if selected ~= "" then
							local qflist = {}
							for line in string.gmatch(selected, "[^\n]+") do
								local parts = vim.split(line, ":", { plain = true })
								table.insert(qflist, {
									filename = parts[1],
									lnum     = tonumber(parts[2]) or 1,
									text     = #parts >= 3 and table.concat(parts, ":", 3) or "",
								})
							end
							callback_function(qflist)
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
