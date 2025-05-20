return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "html",
          "cssls",
          "gopls",
          "gradle_ls",
          "jsonls",
          "csharp_ls",
          "ts_ls",
          "jdtls",
          "ruff",
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("blink.cmp").get_lsp_capabilities()


      lspconfig.pyright.setup({
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "strict", -- Keep type checking
              diagnosticMode = "workspace", -- Reduce noise
            },
          },
        },
      })

      lspconfig.ruff.setup({ capabilities = capabilities })
      lspconfig.lua_ls.setup({
        capabilities,
      })
      lspconfig.html.setup({ capabilities = capabilities })
      lspconfig.ts_ls.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.gradle_ls.setup({ capabilities = capabilities })
      lspconfig.jsonls.setup({ capabilities = capabilities })
      lspconfig.clangd.setup({ capabilities = capabilities, filetypes = { "c", "cpp", "objc", "objcpp" } })
      lspconfig.csharp_ls.setup({ capabilities = capabilities })
      lspconfig.jdtls.setup({})

      vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>g", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

      local dashed_border = {
        { "┌", "FloatBorder" },
        { "╌", "FloatBorder" }, -- Dashed horizontal line
        { "┐", "FloatBorder" },
        { "┆", "FloatBorder" }, -- Dashed vertical line
        { "┘", "FloatBorder" },
        { "╌", "FloatBorder" }, -- Dashed horizontal line
        { "└", "FloatBorder" },
        { "┆", "FloatBorder" }, -- Dashed vertical line
      }
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = dashed_border,
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = dashed_border,
      })
    end,
  },
}
