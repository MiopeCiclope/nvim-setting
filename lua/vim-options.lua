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

-- Center cursor on insert
vim.cmd("autocmd InsertEnter * norm zz")

-- Remove trailing white space
vim.cmd("autocmd BufWritePre * %s/\\s\\+$//e")

-- disable signcolumn
vim.cmd("set signcolumn=no")

vim.g.mapleader = " "

vim.opt.swapfile = false
vim.opt.conceallevel = 2
vim.opt.cursorline = true
vim.opt.scrolloff = 16

-- Navigate vim panes
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")

vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true, silent = true })
vim.keymap.set("n", "ö", ":bprevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "ä", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-e>", ":bnext | bd #<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-g>", ":DiffviewOpen<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-d>", ":DiffviewClose<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-v>", "<C-o>$", { noremap = true, silent = true })
vim.keymap.set({ "n", "o", "v" }, "t", "$", { noremap = true, silent = true })
vim.keymap.set("i", "<C-c>", "<C-o>0", { noremap = true, silent = true })
vim.keymap.set({ "n", "o", "v" }, "r", "^", { noremap = true, silent = true })
vim.keymap.set({ "n", "o", "v" }, "w", "b", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>%", ":vsplit<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>l", "<Cmd>noh<CR>", { noremap = true, silent = true })

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
--#endregion

-- colorscheme
vim.cmd("colorscheme desert_pastel")

-- Function to open diagnostics in a new buffer
function OpenDiagnosticsInNewBuffer()
	local diagnostics = vim.diagnostic.get()
	if vim.tbl_isempty(diagnostics) then
		print("No diagnostics to display")
		return
	end

	-- Create a new buffer
	vim.cmd("new")
	local buf = vim.api.nvim_get_current_buf()

	-- Set buffer options
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false

	-- Populate buffer with diagnostics
	local lines = {}
	for _, diagnostic in ipairs(diagnostics) do
		local clean_message = diagnostic.message:gsub("\n", " ")
		local line =
			string.format("%s:%d:%d: %s", diagnostic.source, diagnostic.lnum + 1, diagnostic.col + 1, clean_message)
		table.insert(lines, line)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- Create a command to open diagnostics in a new buffer
vim.api.nvim_create_user_command("OpenDiagnostics", OpenDiagnosticsInNewBuffer, {})
