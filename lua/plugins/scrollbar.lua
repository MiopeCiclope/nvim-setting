return {
	"petertriho/nvim-scrollbar",
	dependencies = {
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	config = function()
		require("scrollbar").setup()
		require("scrollbar.handlers.gitsigns").setup()
	end,
}
