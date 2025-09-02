return {
  dir = "~/projects/personal/vim-plugins/swedish_chat",
  name = "swedish_chat",
  config = function()
    require("swedish_chat").setup()

    -- Optional: add a user command
    vim.api.nvim_create_user_command("SwedishChat", function()
      require("swedish_chat").open_chat()
    end, {})
  end,
}
