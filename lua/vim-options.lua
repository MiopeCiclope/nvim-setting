vim.cmd("set expandtab")
vim.cmd("set number")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set ignorecase")
vim.cmd("set clipboard+=unnamedplus")
vim.g.mapleader = " "

vim.opt.swapfile = false
vim.opt.conceallevel = 2

-- Navigate vim panes
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")

vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true, silent = true })
vim.keymap.set("n", "<C-m>", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-n>", ":bprevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-e>", ":bd!<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-g>", ":DiffviewOpen<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-d>", ":DiffviewClose<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-v>", "<C-o>$", { noremap = true, silent = true })
vim.keymap.set({ "n", "o", "v" }, "t", "$", { noremap = true, silent = true })
vim.keymap.set("i", "<C-c>", "<C-o>0", { noremap = true, silent = true })
vim.keymap.set({ "n", "o", "v" }, "r", "^", { noremap = true, silent = true })
vim.keymap.set({ "n", "o", "v" }, "w", "b", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>%", ":vsplit<CR>", { noremap = true, silent = true })

vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = false
})

_G.toggle_virtual_text = function()
  local current_value = vim.diagnostic.config().virtual_text
  if current_value then
    vim.diagnostic.config({ virtual_text = false })
    vim.diagnostic.config({ virtual_lines = true })
    print("Virtual line mode")
  else
    vim.diagnostic.config({ virtual_text = true })
    vim.diagnostic.config({ virtual_lines = false })
    print("Virtual text mode")
  end
end

_G.disableDiagnostics = function()
  vim.diagnostic.config({ virtual_text = false, virtual_lines = false })
end

vim.keymap.set('n', '<Leader>d', '<cmd>lua toggle_virtual_text()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>dd', '<cmd>lua disableDiagnostics()<CR>', { noremap = true, silent = true })
vim.keymap.set("x", "/", ":<C-u>/\\%V", { noremap = true, silent = true })
