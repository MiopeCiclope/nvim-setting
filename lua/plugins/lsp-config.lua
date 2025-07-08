return {
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = true,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			lspconfig.jdtls.setup = {
				capabilities = capabilities,
			}

			-- LSP servers configuration
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
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

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT", -- Tell lua_ls you're using LuaJIT (Neovim's runtime)
						},
						diagnostics = {
							globals = { "vim" }, -- Tell lua_ls that 'vim' is a global
						},
						workspace = {
							library = {
								[vim.env.VIMRUNTIME] = true,
								-- vim.api.nvim_get_runtime_file("", true),
							},
							-- Prevent the server from suggesting third-party Lua modules
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

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

			lspconfig.pyright.setup({
				capabilities = capabilities,
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							diagnosticMode = "openFilesOnly",
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			local servers = {
				"html",
				"cssls",
				"gopls",
				"jsonls",
				"omnisharp",
				"clangd",
			}

			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					capabilities = capabilities,
				})
			end
		end,
	},
}
