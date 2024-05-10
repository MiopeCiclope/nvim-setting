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
				ensure_installed = { "lua_ls", "tsserver", "html", "cssls", "gopls", "jdtls", "gradle_ls", "jsonls" },
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

			vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>g", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "single",
			})
		end,
	},
}
