local M = {}

-- Try retrobox first (nvim 0.10+), fall back to habamax (nvim 0.9+)
local ok = pcall(vim.cmd, "colorscheme retrobox")
if not ok then
	vim.cmd("colorscheme habamax")
end

-- Background / foreground
vim.cmd("highlight Normal guibg=#1c1c1c guifg=#ffffff")
vim.cmd("highlight NormalNC guibg=#1c1c1c")

-- Line numbers
vim.cmd("highlight LineNr guifg=#ffffff")
vim.cmd("highlight CursorLineNr guifg=yellow")

-- Cursor line and selection (dark teal accent)
vim.cmd("highlight CursorLine cterm=NONE guibg=#385f54")
vim.cmd("highlight! link Visual CursorLine")

-- Window separator
vim.cmd("highlight WinSeparator guifg=#ffffff")

-- Comments
vim.cmd("highlight Comment guifg=#666666")

-- Float borders — neon green accent
vim.cmd("highlight FloatBorder guifg=#00FF00")
vim.cmd("highlight TelescopeBorder guifg=#00FF00")

-- Completion menu
vim.cmd("highlight Pmenu guibg=NONE guifg=#ffffff")
vim.cmd("highlight PmenuSel guibg=#45475a guifg=#ffffff")
vim.cmd("highlight CursorLineBlink guifg=#FF8800 guibg=#385f54")
vim.cmd("highlight NonText guifg=#CCAA00")

-- Treesitter: 4 color groups only
-- Strings → yellow
vim.cmd("highlight @string guifg=#CCAA00")
vim.cmd("highlight @string.special guifg=#CCAA00")
-- Keywords → white bold
vim.cmd("highlight @keyword guifg=#ffffff gui=bold")
vim.cmd("highlight @keyword.function guifg=#ffffff gui=bold")
vim.cmd("highlight @keyword.return guifg=#ffffff gui=bold")
vim.cmd("highlight @keyword.operator guifg=#ffffff gui=bold")
vim.cmd("highlight @conditional guifg=#ffffff gui=bold")
vim.cmd("highlight @repeat guifg=#ffffff gui=bold")
-- Comments → grey
vim.cmd("highlight @comment guifg=#666666")
-- Types / constants → neon green
vim.cmd("highlight @type guifg=#00FF00")
vim.cmd("highlight @type.builtin guifg=#00FF00")
vim.cmd("highlight @constant guifg=#00FF00")
vim.cmd("highlight @constant.builtin guifg=#00FF00")

return M
