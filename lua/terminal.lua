local utils = require("utils")

local M = {}

function M.open_terminal()
	utils.create_float_window()
	vim.cmd("terminal")
	vim.cmd("startinsert")
end

return M
