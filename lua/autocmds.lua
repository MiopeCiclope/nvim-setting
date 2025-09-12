-- Center cursor on insert
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  command = "norm zz",
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})
