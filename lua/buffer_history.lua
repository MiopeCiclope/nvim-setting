local M = {}

local function valid(bufnr)
	return bufnr
		and vim.api.nvim_buf_is_valid(bufnr)
		and vim.bo[bufnr].buflisted
		and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

function M.back()
	local list, current_idx = unpack(vim.fn.getjumplist())
	local cur_buf = vim.api.nvim_get_current_buf()
	for i = current_idx, 1, -1 do
		local entry = list[i]
		if valid(entry.bufnr) and entry.bufnr ~= cur_buf then
			-- ponytail: \15 = <C-o>, count jumps to skip same-buffer noise
			vim.cmd("normal! " .. (current_idx - i + 1) .. "\15")
			return
		end
	end
end

function M.forward()
	local list, current_idx = unpack(vim.fn.getjumplist())
	local cur_buf = vim.api.nvim_get_current_buf()
	for i = current_idx + 2, #list do
		local entry = list[i]
		if valid(entry.bufnr) and entry.bufnr ~= cur_buf then
			-- ponytail: \9 = <C-i>
			vim.cmd("normal! " .. (i - current_idx - 1) .. "\9")
			return
		end
	end
end

return M
