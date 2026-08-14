local M = {}

local function parse_file_log(lines)
	local entries = {}
	local current_sha, current_subject
	for _, line in ipairs(lines) do
		if line == "" then
		elseif not current_sha then
			local sha, subject = line:match("^([0-9a-f]+)\t(.+)$")
			if sha then
				current_sha = sha
				current_subject = subject
			end
		else
			local parts = vim.split(line, "\t", { trimempty = true })
			local st = parts[1] and parts[1]:sub(1, 1)
			if st and parts[2] then
				local path
				if st == "R" or st == "C" then
					path = parts[3]
				else
					path = parts[2]
				end
				local left_path = (st == "R" or st == "C") and parts[2] or path
				entries[#entries + 1] = {
					sha = current_sha,
					subject = current_subject,
					path = path,
					left_path = left_path,
					display = current_sha:sub(1, 7) .. " " .. current_subject,
				}
				current_sha, current_subject = nil, nil
			end
		end
	end
	return entries
end

_G._test_parse_file_log = parse_file_log

function M.open()
	local filepath = vim.fn.expand("%:p")
	local filename = vim.fn.expand("%:t")
	local raw = vim.fn.systemlist(
		"git log --follow --format=%H%x09%s --name-status -- " .. vim.fn.shellescape(filepath)
	)
	local entries = parse_file_log(raw)
	if #entries == 0 then
		vim.notify("No file history found", vim.log.levels.INFO)
		return
	end
	local function is_root(sha)
		vim.fn.system("git rev-parse --verify " .. vim.fn.shellescape(sha .. "^") .. " 2>/dev/null")
		return vim.v.shell_error ~= 0
	end
	local resolve = function(e)
		local left = not is_root(e.sha) and { ref = e.sha .. "^", path = e.left_path } or nil
		return { left = left, right = { ref = e.sha, path = e.path } }
	end
	_G._test_last_history_entries = entries
	_G._test_last_history_resolve = resolve
	require("git.diff").open({
		title = "File History: " .. filename,
		entries = entries,
		resolve = resolve,
	})
end

return M
