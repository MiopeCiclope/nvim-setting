local M = {}

function M._parse_name_status(lines)
	local entries = {}
	for _, line in ipairs(lines) do
		local parts = vim.split(line, "\t", { trimempty = true })
		if parts[2] then
			local st = parts[1]:sub(1, 1)
			if st == "R" or st == "C" then
				entries[#entries + 1] = {
					status = "R",
					left_path = parts[2],
					right_path = parts[3],
					display = string.format("R  %s → %s", parts[2], parts[3]),
				}
			elseif st == "A" then
				entries[#entries + 1] = {
					status = "A",
					left_path = nil,
					right_path = parts[2],
					display = string.format("A  %s", parts[2]),
				}
			elseif st == "D" then
				entries[#entries + 1] = {
					status = "D",
					left_path = parts[2],
					right_path = nil,
					display = string.format("D  %s", parts[2]),
				}
			else
				entries[#entries + 1] = {
					status = st,
					left_path = parts[2],
					right_path = parts[2],
					display = string.format("%s  %s", st, parts[2]),
				}
			end
		end
	end
	return entries
end

function M.name_status_entries(range)
	local root = vim.fn.system("git rev-parse --show-toplevel"):gsub("%s+", "")
	local lines = vim.fn.systemlist(
		"git -C " .. vim.fn.shellescape(root) .. " diff --name-status -M " .. range
	)
	return M._parse_name_status(lines)
end

return M
