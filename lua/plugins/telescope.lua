return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-live-grep-args.nvim" },
    config = function()
      local lga_actions = require("telescope-live-grep-args.actions")
      local ignoreFolders = " -g '!**/__uitests__/**' -g '!**/__tests__/**' -g '!**/__generated__/**'"

      require("telescope").setup({
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt({ postfix = " -t ts" .. ignoreFolders }),
                ["<C-i>"] = lga_actions.quote_prompt({
                  postfix = " -t js -t ts -t html" .. ignoreFolders,
                }),
              },
            },
          },
        },
        defaults = {
          exclude_files = { "*.png" },
        },
      })

      require("telescope").load_extension("live_grep_args")
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files, {})
      vim.keymap.set("n", "<leader>z", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", {})
      -- vim.keymap.set("n", "<leader>r", builtin.lsp_references, {})
      vim.keymap.set("n", "<leader>b", ":Telescope buffers<CR>", { noremap = true, silent = true })
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        defaults = {
          path_display = function(opts, path)
            local tail = require("telescope.utils").path_tail(path)
            local cropped_path = string.match(path, "^(.*)/") or ""
            return string.format("%s - %s/", tail, cropped_path)
          end,
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}
