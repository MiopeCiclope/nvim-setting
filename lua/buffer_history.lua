local M = {}

local back = {}
local forward = {}
local navigating = false

local function valid(buf)
	return buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= ""
end

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if navigating then
			return
		end
		local buf = vim.api.nvim_get_current_buf()
		if not valid(buf) then
			return
		end
		if back[#back] == buf then
			return
		end
		table.insert(back, buf)
		forward = {}
	end,
})

local function remove_buf(stack, buf)
	local out = {}
	for _, b in ipairs(stack) do
		if b ~= buf then
			table.insert(out, b)
		end
	end
	return out
end

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
	callback = function(args)
		back = remove_buf(back, args.buf)
		forward = remove_buf(forward, args.buf)
	end,
})

local function jump(buf)
	navigating = true
	vim.api.nvim_set_current_buf(buf)
	navigating = false
end

function M.back()
	while #back >= 2 do
		local current = table.remove(back)
		local prev = back[#back]
		if valid(prev) then
			table.insert(forward, current)
			jump(prev)
			return
		end
	end
end

function M.forward()
	while #forward > 0 do
		local next_buf = table.remove(forward)
		if valid(next_buf) then
			table.insert(back, next_buf)
			jump(next_buf)
			return
		end
	end
end

return M
