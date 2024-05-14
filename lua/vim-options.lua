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
vim.keymap.set("n", "<Leader>l", "<Cmd>noh<CR>", { noremap = true, silent = true })

vim.diagnostic.config({
  virtual_text = true,
  virtual_lines = false,
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

vim.keymap.set("n", "<Leader>d", "<cmd>lua toggle_virtual_text()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>dd", "<cmd>lua disableDiagnostics()<CR>", { noremap = true, silent = true })
vim.keymap.set("x", "/", ":<C-u>/\\%V", { noremap = true, silent = true })
vim.keymap.set("n", "s", "<cmd>lua select_block()<CR>", { noremap = true, silent = true })

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
  ["'"] = "'",
  ["`"] = "`",
}

-- Example usage:
setupTagCompletion(mappings)

--#endregion

--#region auto-tag
-- Define your tag function
_G.extract_last_html_tag = function()
  -- Get the current line text
  local text = vim.api.nvim_get_current_line()
  -- Match the last HTML tag and extract the tag name
  local tag = text:match("<(%a+)")
  return "></" .. tag .. ">"
end

vim.cmd([[
  augroup jsx_tsx_mappings
    autocmd!
    autocmd FileType jsx,tsx lua setupAutoTag()
  augroup END
]])

local function setupAutoTag()
  vim.api.nvim_buf_set_keymap(0, "i", ">", "v:lua._G.extract_last_html_tag()", { noremap = true, expr = true })
end

--#endregion

--#region
vim.cmd("colorscheme torte")

-- Set the highlight for FloatBorder
vim.api.nvim_command('highlight FloatBorder guifg=white guibg=#1f2335')
--#endregion

--#region Commenter
--check the mode and find the lines to comment
-- function M.operator(mode)
--   local line1, line2
--   if not mode then
--     line1 = vim.api.nvim_win_get_cursor(0)[1]
--     line2 = line1
--   elseif mode:match("[vV]") then
--     line1 = vim.api.nvim_buf_get_mark(0, "<")[1]
--     line2 = vim.api.nvim_buf_get_mark(0, ">")[1]
--   else
--     line1 = vim.api.nvim_buf_get_mark(0, "[")[1]
--     line2 = vim.api.nvim_buf_get_mark(0, "]")[1]
--   end
--
--   M.comment_toggle(line1, line2)
-- end
--
-- _G.comment = function()
--   -- find the comment characters
--   local commentString = vim.api.nvim_buf_get_option(0, "cms")
--   local commentChars = commentString:match("^(.*)%%s(.*)")
--
--   print(commentChars)
-- end
-- map("n", "<leader>pp", "<cmd>lua comment()<CR>")
--

--#endregion
