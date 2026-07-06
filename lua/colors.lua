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

-- Comments — dark enough to recede but still readable
vim.cmd("highlight Comment guifg=#555555")

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

-- Treesitter: 4 sober color groups
-- Strings → warm muted amber
vim.cmd("highlight @string guifg=#a89060")
vim.cmd("highlight @string.special guifg=#a89060")
-- Keywords → bold only, no color change (classic vim style)
vim.cmd("highlight @keyword guifg=#c0c0c0 gui=bold")
vim.cmd("highlight @keyword.function guifg=#c0c0c0 gui=bold")
vim.cmd("highlight @keyword.return guifg=#c0c0c0 gui=bold")
vim.cmd("highlight @keyword.operator guifg=#c0c0c0 gui=bold")
vim.cmd("highlight @conditional guifg=#c0c0c0 gui=bold")
vim.cmd("highlight @repeat guifg=#c0c0c0 gui=bold")
vim.cmd("highlight @keyword.conditional guifg=#c0c0c0 gui=bold")
vim.cmd("highlight @keyword.repeat guifg=#c0c0c0 gui=bold")
-- Comments → dark grey
vim.cmd("highlight @comment guifg=#555555")
-- Types → muted steel blue
vim.cmd("highlight @type guifg=#7a9999")
vim.cmd("highlight @type.builtin guifg=#7a9999")
-- Constants → same warm amber as strings
vim.cmd("highlight @constant guifg=#a89060")
vim.cmd("highlight @constant.builtin guifg=#a89060")

return M
