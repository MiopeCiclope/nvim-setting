return {
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"buf_ls",
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
				automatic_enable = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Common on_attach function
			local on_attach = function()
				local opts = {}
				-- Custom borders for LSP handlers
				local dashed_border = {
					{ "┌", "FloatBorder" },
					{ "╌", "FloatBorder" },
					{ "┐", "FloatBorder" },
					{ "┆", "FloatBorder" },
					{ "┘", "FloatBorder" },
					{ "╌", "FloatBorder" },
					{ "└", "FloatBorder" },
					{ "┆", "FloatBorder" },
				}

				vim.keymap.set("n", "<leader>h", function()
					vim.lsp.buf.hover({ border = dashed_border })
				end, opts)
				vim.keymap.set("n", "<leader>g", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
			end

			-- LSP servers configuration
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					typescript = {
						format = {
							enable = false,
						},
					},
					javascript = {
						format = {
							enable = false,
						},
					},
				},
			})

			lspconfig.pyright.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "strict",
							diagnosticMode = "workspace",
						},
					},
				},
			})

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							checkThirdParty = false,
						},
					},
				},
			})

			-- Other LSP configurations
			local servers = {
				"html",
				"cssls",
				"gopls",
				"jsonls",
				"omnisharp",
				"ruff",
				"clangd",
			}

			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})
			end

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {})
		end,
	},
	{
		"mfussenegger/nvim-jdtls",
	},
}
