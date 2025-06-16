vim.cmd("set expandtab")
vim.cmd("set number")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set ignorecase")
-- Use clipboard instead of registers
vim.cmd("set clipboard+=unnamedplus")
vim.cmd("set termguicolors")
vim.cmd("set relativenumber")
-- on vertical split put new pane in the right
vim.cmd("set splitright")
vim.o.mouse = ""

-- Center cursor on insert
vim.cmd("autocmd InsertEnter * norm zz")

-- Remove trailing white space
vim.cmd("autocmd BufWritePre * %s/\\s\\+$//e")

vim.cmd([[
    augroup jdtls_lsp
        autocmd!
        autocmd FileType java lua require'config.jdtls'.setup_jdtls()
    augroup end
]])

-- disable signcolumn
-- vim.cmd("set signcolumn=no")
vim.cmd("set signcolumn=yes")

vim.g.mapleader = " "

vim.opt.swapfile = false
vim.opt.conceallevel = 2
vim.opt.cursorline = true
vim.opt.scrolloff = 16

-- global status line instead of one per split
vim.opt.laststatus = 3

-- Navigate vim panes
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")

vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true, silent = true })
vim.keymap.set("n", "ö", ":bprevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "ä", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-e>", ":bnext | bd #<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-g>", ":DiffviewOpen<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-d>", ":DiffviewClose<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-v>", "<C-o>$", { noremap = true, silent = true })
vim.keymap.set({ "n", "o", "v" }, "t", "$", { noremap = true, silent = true })
vim.keymap.set("i", "<C-c>", "<C-o>0", { noremap = true, silent = true })
vim.keymap.set({ "n", "o", "v" }, "r", "^", { noremap = true, silent = true })
vim.keymap.set({ "n", "o", "v" }, "w", "b", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>%", ":vsplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", '<leader>"', ":split<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>l", "<Cmd>noh<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-x>", ":Explore<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<leader>:", ":CodeCompanionChat<CR>", { noremap = true, silent = true })

vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false,
})

_G.toggle_diagnostics = function()
	local currentValue = vim.diagnostic.config().virtual_text
	vim.diagnostic.config({ virtual_text = not currentValue })
end

vim.keymap.set("n", "<Leader>d", "<cmd>lua toggle_diagnostics()<CR>", { noremap = true, silent = true })
vim.keymap.set("x", "/", ":<C-u>/\\%V", { noremap = true, silent = true })

-- makes keymaps with less words
function _G.map(mode, keys, command)
	vim.api.nvim_set_keymap(mode, keys, command, { noremap = true })
end

--#region autopair replacer
-- create keymaps for automatically close brankets
local function makeTagKeymap(char, completion)
	local command = char .. completion .. "<Esc>ha"
	map("i", char, command)
end

local function setupTagCompletion(mapping_table)
	for char, completion in pairs(mapping_table) do
		makeTagKeymap(char, completion)
	end
end

-- Define your table of mappings
local mappings = {
	["{"] = "}",
	["["] = "]",
	["("] = ")",
	['"'] = '"',
	["´"] = "´",
	["`"] = "`",
}

setupTagCompletion(mappings)

vim.api.nvim_create_user_command("W", function()
	vim.cmd("write")
end, {})
--#endregion
