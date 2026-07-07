local M = {}

local function apply_overrides()
	-- Group 1: Background / foreground
	vim.cmd("highlight Normal guibg=#1c1c1c guifg=#e8e8e8")
	vim.cmd("highlight NormalNC guibg=#1c1c1c")
	vim.cmd("highlight NormalFloat guibg=#1c1c1c guifg=#e8e8e8")

	-- Group 2: Line numbers
	vim.cmd("highlight LineNr guifg=#707070")
	vim.cmd("highlight CursorLineNr guifg=#e8e8e8")

	-- Group 4: Window separator
	vim.cmd("highlight WinSeparator guifg=#00FF00")

	-- Group 6: Float borders
	vim.cmd("highlight FloatBorder guifg=#00FF00")

	-- Group 7: Completion menu
	vim.cmd("highlight Pmenu guibg=NONE guifg=#e8e8e8")
	vim.cmd("highlight PmenuSel guibg=#2e2e2e guifg=#e8e8e8")
	vim.cmd("highlight CursorLineBlink guifg=#e8e8e8 guibg=#2e2e2e")
	vim.cmd("highlight NonText guifg=#484848")
	vim.cmd("highlight BlinkCmpGhostText guifg=#FF8800")

	-- Group 8: Diagnostic underlines — neon per severity
	vim.cmd("highlight DiagnosticUnderlineError gui=underline guisp=#FF0055")
	vim.cmd("highlight DiagnosticUnderlineWarn  gui=underline guisp=#FF8800")
	vim.cmd("highlight DiagnosticUnderlineInfo  gui=underline guisp=#00CCFF")
	vim.cmd("highlight DiagnosticUnderlineHint  gui=underline guisp=#00FF00")
end

vim.cmd("colorscheme lunaperche")
apply_overrides()

return M
