return {
  "epwalsh/obsidian.nvim",
  version = "v3.7.5", -- recommended, use latest release instead of latest commit
  ft = "markdown",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("obsidian").setup({
      workspaces = {
        {
          name = "personal",
          path = "~/vaults/personal",
        },
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      daily_notes = {
        folder = "notes/jornal",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
        template = nil
      },
    })
  end,
}
