vim.cmd("set expandtab")
vim.cmd("set number")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set ignorecase")
vim.g.mapleader = " "

vim.opt.swapfile = false
vim.diagnostic.config({
  virtual_text = false,
})
-- Navigate vim panes
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")

vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true })
vim.keymap.set("n", "<C-m>", ":bnext<CR>", { noremap = true })
vim.keymap.set("n", "<C-n>", ":bprevious<CR>", { noremap = true })
vim.keymap.set("n", "<C-e>", ":bd!<CR>", { noremap = true })
vim.keymap.set("n", "<C-g>", ":DiffviewOpen<CR>", { noremap = true })
vim.keymap.set("n", "<C-d>", ":DiffviewClose<CR>", { noremap = true })
vim.keymap.set("i", "<C-v>", "<C-o>$")
vim.keymap.set({"n", "o", "v"}, "t", "$")
vim.keymap.set("i", "<C-c>", "<C-o>0")
vim.keymap.set({"n", "o", "v"}, "r", "g0")
vim.keymap.set({"n", "o", "v"}, "w", "b")
