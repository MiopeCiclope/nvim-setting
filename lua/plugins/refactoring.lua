return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local ts_utils = require("nvim-treesitter.ts_utils")
		local get_master_node = function()
			local node = ts_utils.get_node_at_cursor()
			if node == nil then
				error("No Treesitter parser found")
			end

			local root = ts_utils.get_root_for_node(node)
			local start_row = node:start()
			local parent = node:parent()

			while parent ~= nil and parent ~= root and parent:start() == start_row do
				node = parent
				parent = node:parent()
			end

			return node
		end

		_G.select_block = function()
			local node = get_master_node()
			local buffer_number = vim.api.nvim_get_current_buf()
			local start_row, start_col, end_row, end_col = ts_utils.get_node_range(node)

			-- Get the buffer text
			local buffer_text = vim.api.nvim_buf_get_lines(buffer_number, end_row, end_row + 1, false)

			-- Extract the next character
			local next_char = buffer_text[1]:sub(end_col + 1, end_col + 1)
			
			-- Adjust the node's end column if the next character is a comma
			if next_char == "," then
				end_col = end_col + 1
			end

			ts_utils.update_selection(buffer_number, node)
			vim.api.nvim_win_set_cursor(0, { end_row +1, end_col -1})
		end

		vim.keymap.set("x", "<leader>rf", ":Refactor extract ")
		vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ")
		vim.keymap.set("n", "<leader>s", "*:%s//", { noremap = true, silent = true })
		require("refactoring").setup()
	end,
}
