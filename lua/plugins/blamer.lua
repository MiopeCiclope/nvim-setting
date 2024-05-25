return {
  "rhysd/git-messenger.vim",
  config = function()
    vim.g.git_messenger_include_diff = "current" -- Options: "none", "current", "all"
    vim.g.git_messenger_always_into_popup = true
    vim.g.git_messenger_floating_win_opts = { border = "single" }
  end,
}
