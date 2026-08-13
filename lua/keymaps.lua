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

map("n", "<Leader>u", function()
	local gd = require("gitdiff")
	local entries = gd.status_entries()
	gd.open({
		title = "Save Work",
		entries = entries,
		resolve = function(e)
			return {
				left = e.left_path and { ref = "HEAD", path = e.left_path } or nil,
				right = e.right_path and { worktree = true, path = e.right_path } or nil,
			}
		end,
	})
end, opts)

-- Fechar diff e quickfix, sobrando só o arquivo de trabalho
map("n", "<Leader>q", function()
	vim.cmd("diffoff!")
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		-- fecha janelas não-normais: quickfix, scratch base (nofile), fugitive
		if vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "" then
			pcall(vim.api.nvim_win_close, win, false)
		end
	end
end, opts)

-- Quickfix navigation — j/k na própria lista já move e o diff segue
map("n", "<Leader>j", "<cmd>silent! cnext<CR>", opts)
map("n", "<Leader>k", "<cmd>silent! cprev<CR>", opts)

map("n", "<Leader>rc", function()
	require("review").clear()
end, opts)
