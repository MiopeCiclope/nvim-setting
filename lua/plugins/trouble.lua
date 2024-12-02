return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  keys = {
    {
      "<leader>x",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>r",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
  },
  config = function()
    require("trouble").setup({
      win = {
        size = {
          width = 80,
        },
      },
    })
  end,
}
