return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		vim.cmd("colorscheme catppuccin-mocha")
		vim.cmd([[highlight NormalNC guibg=#1c1c1c]])
		vim.cmd([[highlight Normal guibg=#1c1c1c guifg=#ffffff]])

		-- line number color
		vim.cmd([[highlight LineNr guifg=white]])

		-- current line number
		vim.cmd([[highlight CursorLineNr guifg=yellow]])

		-- cursor line higlight
		vim.cmd([[highlight CursorLine cterm=NONE guibg=#385f54]])

		-- make selection become same color as cursor line
		vim.cmd([[highlight! link Visual CursorLine]])

		-- window separator color
		vim.cmd([[highlight WinSeparator guifg=white]])
		-- comment font color
		vim.cmd([[highlight Comment      guifg=#B1C4DE]])

		-- float window color
		vim.cmd([[highlight FloatBorder guifg=#00FF00]])
		vim.cmd([[highlight TelescopeBorder guifg=#00FF00]])

		-- menu suggestion selection color
		vim.cmd([[highlight PmenuSel guibg=#45475a guifg=#ffffff]])
		vim.cmd([[highlight Pmenu guibg=NONE guifg=#ffffff]])
	end,
}
