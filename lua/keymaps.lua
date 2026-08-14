local map = vim.keymap.set
local opts = { noremap = true }

-- Pane navigation
map("n", "<c-k>", ":wincmd k<CR>", opts)
map("n", "<c-j>", ":wincmd j<CR>", opts)
map("n", "<c-l>", ":wincmd l<CR>", opts)
map("n", "<c-h>", ":wincmd h<CR>", opts)

-- Buffer navigation (history-based, like browser back/forward)
map("n", "ö", function()
	require("buffer_history").back()
end, opts)
map("n", "ä", function()
	require("buffer_history").forward()
end, opts)
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
map("n", "<C-p>", '<cmd>lua require("fzf_searches").git_files()<CR>', opts)
map("n", "<Leader>b", '<cmd>lua require("fzf_searches").buffers()<CR>', opts)
map("n", "<Leader>z", '<cmd>lua require("fzf_searches").grep_search()<CR>', opts)

map("n", "<Leader>c", "<cmd>CopyRepoPath<CR>", opts)

map("n", "<Leader>o", function()
	require("git.history").open()
end, opts)

map("n", "<Leader>u", function()
	require("git.save").open()
end, opts)

-- Fechar diff e quickfix, sobrando só o arquivo de trabalho
map("n", "<Leader>q", function()
	vim.cmd("diffoff!")
	vim.cmd("cclose")
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if
			vim.api.nvim_win_is_valid(win)
			and #vim.api.nvim_list_wins() > 1
			and vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= ""
		then
			pcall(vim.api.nvim_win_close, win, false)
		end
	end
	if vim.bo[vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())].buftype ~= "" then
		vim.cmd("enew")
	end
end, opts)

-- Quickfix navigation — j/k na própria lista já move e o diff segue
map("n", "<Leader>j", "<cmd>silent! cnext<CR>", opts)
map("n", "<Leader>k", "<cmd>silent! cprev<CR>", opts)

map("n", "<Leader>m", function()
	require("git.review").branch_review(nil, {})
end, opts)

map("n", "<Leader>å", function()
	require("git.review").clear()
end, opts)

map("n", "<Leader>n", function()
	require("git.commits").open()
end, opts)

-- so um teste
