-- Core options
vim.g.mapleader = " "

vim.cmd("set expandtab")
vim.cmd("set number")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set ignorecase")
vim.cmd("set clipboard+=unnamedplus")
vim.cmd("set termguicolors")
vim.cmd("set relativenumber")
vim.cmd("set splitright")
vim.cmd("set signcolumn=yes")

vim.o.mouse = ""
vim.opt.swapfile = false
vim.opt.conceallevel = 2
vim.opt.cursorline = true
vim.opt.scrolloff = 16
vim.opt.laststatus = 3

-- vim.opt.wildmenu = true
-- vim.opt.wildmode = "longest:full,full"

-- Diagnostics
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = false,
})

-- vim.cmd("set showtabline=2")
