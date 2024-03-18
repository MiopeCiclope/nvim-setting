return {
	{
		"akinsho/bufferline.nvim",
		config = function()
			vim.opt.termguicolors = true
			require("bufferline").setup({})

			vim.keymap.set("n", "<C-m>", ":BufferLinePick<CR>", {})
		end,
	},
}
