vim.cmd("set expandtab")
vim.cmd("set number")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set ignorecase")
vim.g.mapleader = " "

vim.keymap.set('n', '<C-a>', 'ggVG', {noremap = true})
vim.keymap.set('n', '<C-m>', ':bnext<CR>', {noremap = true})
vim.keymap.set('n', '<C-n>', ':bprevious<CR>', {noremap = true})
vim.keymap.set('n', '<C-w>', ':bd<CR>', {noremap = true})
