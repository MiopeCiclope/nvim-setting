return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local treesitterConfig = require("nvim-treesitter.configs")
    treesitterConfig.setup({
      auto_install = true,
      ensure_installed = { "lua", "javascript", "typescript", "java", "go", "html", "css", "tsx", "http" },
      highlight = { enable = true },
      indent = { enable = true },
      additional_vim_regex_highlighting = false,
    })
  end,
}
