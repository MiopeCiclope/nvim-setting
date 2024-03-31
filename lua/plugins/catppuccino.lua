return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			highlight_overrides = {
				mocha = function()
					return {
						LineNr = { fg = "white" },
					}
				end,
			},
		})
		vim.cmd.colorscheme("catppuccin-mocha")
	end,
}
