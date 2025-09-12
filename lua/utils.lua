local M = {}

-- Minimal helper for keymaps (optional, can be skipped if you use vim.keymap.set)
function M.map(mode, keys, command)
  vim.api.nvim_set_keymap(mode, keys, command, { noremap = true })
end

-- Toggle diagnostics
function M.toggle_diagnostics()
  local currentValue = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not currentValue })
end

-- Simple autopair setup
function M.setup_autopairs()
  local function makeTagKeymap(char, completion)
    M.map("i", char, char .. completion .. "<Esc>ha")
  end

  local mappings = {
    ["{"] = "}",
    ["["] = "]",
    ["("] = ")",
    ['"'] = '"',
    ["´"] = "´",
    ["`"] = "`",
  }

  for char, completion in pairs(mappings) do
    makeTagKeymap(char, completion)
  end
end

-- Provide a :W command (write file)
vim.api.nvim_create_user_command("W", function()
  vim.cmd("write")
end, {})

return M
