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
          "tsserver",
          "html",
          "cssls",
          "gopls",
          "jdtls",
          "gradle_ls",
          "jsonls",
          "bufls",
          "csharp_ls",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mfussenegger/nvim-jdtls" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.lua_ls.setup({
        capabilities,
      })
      lspconfig.html.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.jdtls.setup({
        capabilities = capabilities,
        vmargs = {
          "-Xmx12g",
          "-XX:MaxMetaspaceSize=512m",
          "-XX:ReservedCodeCacheSize=512m",
          "-XX:CICompilerCount=7",
          "-Dfile.encoding=UTF-8",
        },
      })
      lspconfig.gradle_ls.setup({ capabilities = capabilities })
      lspconfig.jsonls.setup({ capabilities = capabilities })
      lspconfig.tsserver.setup({ capabilities = capabilities })
      lspconfig.clangd.setup({ capabilities = capabilities, filetypes = { "c", "cpp", "objc", "objcpp" } })
      lspconfig.bufls.setup({ capabilities = capabilities, filetypes = { "proto" } })
      lspconfig.csharp_ls.setup({ capabilities = capabilities })

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
