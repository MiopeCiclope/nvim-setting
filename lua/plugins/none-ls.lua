return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        -- Add stylelint diagnostics and formatting
        null_ls.builtins.diagnostics.stylelint.with({
          command = "stylelint",                                                                                             -- Ensure stylelint is installed globally or in your project
          extra_args = { "--config", "~/projects/eti-web/packages/products/src/fast-track/components/stylelint.config.js" }, -- Adjust path if necessary
        }),
        null_ls.builtins.formatting.stylelint.with({
          command = "stylelint",
          extra_args = { "--config", "~/projects/eti-web/packages/products/src/fast-track/components/stylelint.config.js", "--fix" },
        }),

        -- Existing configurations
        require("none-ls.formatting.eslint_d"),
        require("none-ls.diagnostics.eslint_d"),
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.buf.with({
          command = "buf",
          args = { "lint", "--path", "$FILENAME" },
          filetypes = { "proto" },
        }),
        null_ls.builtins.formatting.buf.with({
          command = "buf",
          args = { "format", "-w", "$FILENAME" },
          filetypes = { "proto" },
        }),
      },
    })

    -- Bind format to a key (optional)
    vim.keymap.set("n", "<leader>p", vim.lsp.buf.format, {})
  end,
}
