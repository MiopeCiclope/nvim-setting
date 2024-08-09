return {
  dir = "~/projects/job-notifier",
  dev = true,
  config = function()
    require("job-notifier").setup({
      meta = {
        {
          name = "react",
          cmd = "npm start",
          log_file = "reactLog.txt",
          stages = {
            ["Compiling"] = {
              text = "Building",
              color = "black",
            },
            ["No issues found"] = {
              text = "Success",
              color = "green",
            },
            ["ERROR in"] = {
              text = "Fail",
              color = "red",
            },
          },
        },
        {
          name = "watcher",
          cmd = "npm run watch",
          log_file = "watcherLog.txt",
          stages = {
            ["Executing command"] = {
              text = "Watching",
              color = "black",
            },
            ["NODE_ENV=production"] = {
              text = "Building",
              color = "black",
            },
            ["Nx read the output"] = {
              text = "Success",
              color = "green",
            },
            ["ERROR"] = {
              text = "Fail",
              color = "red",
            },
          },
        },
      },
    })

    vim.api.nvim_set_keymap(
      "n",
      "<leader>rs",
      ':lua require("job-notifier").run("react")<CR>',
      { noremap = true, silent = true }
    )

    vim.api.nvim_set_keymap(
      "n",
      "<leader>rw",
      ':lua require("job-notifier").run("watcher")<CR>',
      { noremap = true, silent = true }
    )

    vim.api.nvim_set_keymap(
      "n",
      "<leader>ro",
      ':lua require("job-notifier").open_output_fils("react")<CR>',
      { noremap = true, silent = true }
    )

    vim.api.nvim_set_keymap(
      "n",
      "<leader>st",
      ':lua require("job-notifier").stop_script("react")<CR>',
      { noremap = true, silent = true }
    )
  end,
}
