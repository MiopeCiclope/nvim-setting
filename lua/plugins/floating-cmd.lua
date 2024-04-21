return {
  "VonHeikemen/fine-cmdline.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim"
  },
  config = function()
    require("fine-cmdline").setup({
      cmdline = {
        prompt = 'CMD -> '
      },
      popup = {
        size = {
          width = '40%',
        },
      }
    })
    vim.api.nvim_set_keymap('n', ':', '<cmd>FineCmdline<CR>', { noremap = true })
  end
}
