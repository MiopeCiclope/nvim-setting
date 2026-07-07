local M = {}

-- Try retrobox first (nvim 0.10+), fall back to habamax (nvim 0.9+)
local ok = pcall(vim.cmd, "colorscheme retrobox")
if not ok then
	vim.cmd("colorscheme habamax")
end

-- Background / foreground
vim.cmd("highlight Normal guibg=#1c1c1c guifg=#e8e8e8")
vim.cmd("highlight NormalNC guibg=#1c1c1c")
vim.cmd("highlight NormalFloat guibg=#1c1c1c guifg=#e8e8e8")

-- Line numbers
vim.cmd("highlight LineNr guifg=#707070")
vim.cmd("highlight CursorLineNr guifg=#e8e8e8")

-- Cursor line: subtle
vim.cmd("highlight CursorLine cterm=NONE guibg=#252525")
-- Visual selection: distinct blue-teal so selected text is immediately obvious
vim.cmd("highlight Visual guibg=#1e3a5a")

-- Window separator
vim.cmd("highlight WinSeparator guifg=#505050")

-- Comments — bright enough to read in daylight, clearly secondary
vim.cmd("highlight Comment guifg=#aabbcc")

-- Float borders — neon green accent
vim.cmd("highlight FloatBorder guifg=#00FF00")
vim.cmd("highlight TelescopeBorder guifg=#00FF00")

-- Completion menu
vim.cmd("highlight Pmenu guibg=NONE guifg=#e8e8e8")
vim.cmd("highlight PmenuSel guibg=#2e2e2e guifg=#e8e8e8")
vim.cmd("highlight CursorLineBlink guifg=#e8e8e8 guibg=#2e2e2e")
vim.cmd("highlight NonText guifg=#484848")

-- Diagnostic underlines — neon green on the underline itself, text color unchanged
vim.cmd("highlight DiagnosticUnderlineError gui=underline guisp=#00FF00")
vim.cmd("highlight DiagnosticUnderlineWarn  gui=underline guisp=#00FF00")
vim.cmd("highlight DiagnosticUnderlineInfo  gui=underline guisp=#00FF00")
vim.cmd("highlight DiagnosticUnderlineHint  gui=underline guisp=#00FF00")

-- Treesitter: 4 color groups
-- Strings / constants → warm gold
vim.cmd("highlight @string guifg=#e8b860")
vim.cmd("highlight @string.special guifg=#e8b860")
vim.cmd("highlight @constant guifg=#e8b860")
vim.cmd("highlight @constant.builtin guifg=#e8b860")
-- Keywords → cadet-blue cyan bold (classic vim feel)
vim.cmd("highlight @keyword guifg=#7ecece gui=bold")
vim.cmd("highlight @keyword.function guifg=#7ecece gui=bold")
vim.cmd("highlight @keyword.return guifg=#7ecece gui=bold")
vim.cmd("highlight @keyword.operator guifg=#7ecece gui=bold")
vim.cmd("highlight @conditional guifg=#7ecece gui=bold")
vim.cmd("highlight @repeat guifg=#7ecece gui=bold")
vim.cmd("highlight @keyword.conditional guifg=#7ecece gui=bold")
vim.cmd("highlight @keyword.repeat guifg=#7ecece gui=bold")
-- Comments → bright slate blue-grey
vim.cmd("highlight @comment guifg=#aabbcc")
-- Types → brighter sage green
vim.cmd("highlight @type guifg=#66cc66")
vim.cmd("highlight @type.builtin guifg=#66cc66")
-- Override all base-colorscheme greens to white
vim.cmd("highlight @variable.builtin guifg=#e8e8e8")
vim.cmd("highlight @property      guifg=#e8e8e8")
vim.cmd("highlight Added          guifg=#e8e8e8")
vim.cmd("highlight Define         guifg=#e8e8e8")
vim.cmd("highlight DiagnosticOk   guifg=#e8e8e8")
vim.cmd("highlight Include        guifg=#e8e8e8")
vim.cmd("highlight Macro          guifg=#e8e8e8")
vim.cmd("highlight OkMsg          guifg=#e8e8e8")
vim.cmd("highlight Operator       guifg=#e8e8e8")
vim.cmd("highlight PreCondit      guifg=#e8e8e8")
vim.cmd("highlight PreProc        guifg=#e8e8e8")
vim.cmd("highlight SpellLocal     guifg=#e8e8e8")
vim.cmd("highlight Structure      guifg=#e8e8e8")

return M
