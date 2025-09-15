local map = vim.keymap.set
local opts = opts

-- Pane navigation
map("n", "<c-k>", ":wincmd k<CR>", opts)
map("n", "<c-j>", ":wincmd j<CR>", opts)
map("n", "<c-l>", ":wincmd l<CR>", opts)
map("n", "<c-h>", ":wincmd h<CR>", opts)

-- Buffer navigation
map("n", "ö", ":bprevious<CR>", opts)
map("n", "ä", ":bnext<CR>", opts)
map("n", "<C-e>", ":bnext | bd #<CR>", opts)

-- Quick commands
map("n", "<C-a>", "ggVG", opts)
map("n", "<Leader>%", ":vsplit<CR>", opts)
map("n", '<Leader>"', ":split<CR>", opts)
map("n", "<Leader>l", "<Cmd>noh<CR>", opts)
map("n", "<C-x>", ":Explore<CR>", opts)

-- Movement remaps
map("i", "<C-v>", "<C-o>$", opts)
map("i", "<C-c>", "<C-o>0", opts)
map({ "n", "o", "v" }, "t", "$", opts)
map({ "n", "o", "v" }, "r", "^", opts)
map({ "n", "o", "v" }, "w", "b", opts)

-- Toggle diagnostics (from utils)
map("n", "<Leader>d", function()
	require("utils").toggle_diagnostics()
end, opts)

-- Search inside visual selection
map("x", "/", ":<C-u>/\\%V", opts)

-- fzf integration
map("n", "<C-p>", '<cmd>lua require("fzf").git_files()<CR>', opts)
map("n", "<Leader>b", '<cmd>lua require("fzf").buffers()<CR>', opts)
map("n", "<Leader>z", '<cmd>lua require("fzf").grep_search()<CR>', opts)

-- terminal
map("n", "<Leader>t", '<cmd>lua require("terminal").open_terminal()<CR>', opts)
