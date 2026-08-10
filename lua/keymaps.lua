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

-- Fugitive (git) — space + right hand
-- u: git status  i: diff arquivo  o: blame  n: log  m: diff PR (origin/main...HEAD)
map("n", "<Leader>u", "<cmd>G<CR>", opts)
map("n", "<Leader>i", function()
	if vim.bo.filetype == "qf" then vim.cmd("cc") end
	vim.cmd("Gvdiffsplit")
end, opts)
map("n", "<Leader>o", "<cmd>G blame<CR>", opts)
map("n", "<Leader>n", "<cmd>G log --oneline<CR>", opts)
map("n", "<Leader>m", function()
	local base = vim.fn.system("git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}'"):gsub("\n", "")
	if base == "" then base = "main" end
	local root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
	local files = vim.fn.systemlist("git diff --name-only origin/" .. base .. "...HEAD")
	if #files == 0 then
		vim.notify("Sem arquivos alterados em relação a origin/" .. base, vim.log.levels.INFO)
		return
	end
	local items = {}
	for _, f in ipairs(files) do
		table.insert(items, { filename = root .. "/" .. f, lnum = 1, text = f })
	end
	vim.fn.setqflist(items, "r")
	vim.cmd("copen")
end, opts)

-- Fechar vimdiff e voltar ao arquivo
map("n", "<Leader>q", function()
	vim.cmd("diffoff!")
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
		if win ~= vim.api.nvim_get_current_win() and ft ~= "qf" then
			pcall(vim.api.nvim_win_close, win, false)
		end
	end
end, opts)

-- Quickfix navigation (Claude review concerns) — j: próximo  k: anterior
map("n", "<Leader>j", "<cmd>cnext<CR>", opts)
map("n", "<Leader>k", "<cmd>cprev<CR>", opts)
