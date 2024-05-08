return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			current_line_blame = false,
		})
		vim.cmd([[highlight GitSignsCurrentLineBlame guifg=#ffffff gui=bold]])
	end,
}
