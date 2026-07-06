local M = {}

-- Try retrobox first (nvim 0.10+), fall back to habamax (nvim 0.9+)
local ok = pcall(vim.cmd, "colorscheme retrobox")
if not ok then
	vim.cmd("colorscheme habamax")
end

-- Background / foreground — off-white fg for contrast without glare
vim.cmd("highlight Normal guibg=#1c1c1c guifg=#c0c0c0")
vim.cmd("highlight NormalNC guibg=#1c1c1c")

-- Line numbers
vim.cmd("highlight LineNr guifg=#585858")
vim.cmd("highlight CursorLineNr guifg=#c0c0c0")

-- Cursor line: very subtle, just barely distinguishable
vim.cmd("highlight CursorLine cterm=NONE guibg=#252525")
vim.cmd("highlight! link Visual CursorLine")

-- Window separator
vim.cmd("highlight WinSeparator guifg=#3c3c3c")

-- Comments — slate blue-grey: readable but clearly secondary
vim.cmd("highlight Comment guifg=#8899aa")

-- Float borders — neon green accent
vim.cmd("highlight FloatBorder guifg=#00FF00")
vim.cmd("highlight TelescopeBorder guifg=#00FF00")

-- Completion menu
vim.cmd("highlight Pmenu guibg=NONE guifg=#c0c0c0")
vim.cmd("highlight PmenuSel guibg=#2e2e2e guifg=#c0c0c0")
vim.cmd("highlight CursorLineBlink guifg=#c0c0c0 guibg=#2e2e2e")
vim.cmd("highlight NonText guifg=#383838")

-- Diagnostic underlines — neon green on the underline itself, text color unchanged
vim.cmd("highlight DiagnosticUnderlineError gui=underline guisp=#00FF00")
vim.cmd("highlight DiagnosticUnderlineWarn  gui=underline guisp=#00FF00")

-- Treesitter: 4 color groups
-- Strings / constants → warm gold
vim.cmd("highlight @string guifg=#c8a050")
vim.cmd("highlight @string.special guifg=#c8a050")
vim.cmd("highlight @constant guifg=#c8a050")
vim.cmd("highlight @constant.builtin guifg=#c8a050")
-- Keywords → cadet-blue cyan bold (classic vim feel)
vim.cmd("highlight @keyword guifg=#5f9ea0 gui=bold")
vim.cmd("highlight @keyword.function guifg=#5f9ea0 gui=bold")
vim.cmd("highlight @keyword.return guifg=#5f9ea0 gui=bold")
vim.cmd("highlight @keyword.operator guifg=#5f9ea0 gui=bold")
vim.cmd("highlight @conditional guifg=#5f9ea0 gui=bold")
vim.cmd("highlight @repeat guifg=#5f9ea0 gui=bold")
vim.cmd("highlight @keyword.conditional guifg=#5f9ea0 gui=bold")
vim.cmd("highlight @keyword.repeat guifg=#5f9ea0 gui=bold")
-- Comments → slate blue-grey
vim.cmd("highlight @comment guifg=#8899aa")
-- Types → muted sage green
vim.cmd("highlight @type guifg=#8fbc8f")
vim.cmd("highlight @type.builtin guifg=#8fbc8f")

return M
