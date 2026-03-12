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
			local configs = require("lspconfig.configs") -- Required for custom servers
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- 1. DEFINE IDEALS (Custom Server Injection)
			if not configs.ideals then
				configs.ideals = {
					default_config = {
						-- Connect to IntelliJ via the TCP port you specified (8989)
						cmd = vim.lsp.rpc.connect("127.0.0.1", 8989),
						filetypes = { "java", "kotlin" },
						-- Marker for IntelliJ projects
						root_dir = lspconfig.util.root_pattern(".idea", "pom.xml", "build.gradle"),
						settings = {},
					},
				}
			end

			-- 2. SETUP IDEALS
			lspconfig.ideals.setup({
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					-- Confirmation message in your status line
					vim.notify("Connected to IntelliJ (IdeaLS)", vim.log.levels.INFO)
				end,
			})

			-- --- Your existing servers below ---

			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				settings = {
					typescript = { format = { enable = false } },
					javascript = { format = { enable = false } },
				},
			})

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = { [vim.env.VIMRUNTIME] = true },
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

			-- UI & Keymaps
			local opts = {}
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
			vim.keymap.set("n", "<leader>G", function()
				vim.cmd("vsplit")
				vim.lsp.buf.definition()
			end, opts)
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

			vim.keymap.set("n", "<leader>L", function()
				local current = vim.lsp.log.get_level()
				if current == vim.log.levels.DEBUG then
					vim.lsp.set_log_level("warn")
					vim.notify("LSP log: OFF (warn)")
				else
					vim.lsp.set_log_level("debug")
					vim.notify("LSP log: ON (debug)")
					vim.cmd("LspLog")
				end
			end, { desc = "Toggle LSP debug log" })

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

			local servers = { "html", "cssls", "gopls", "jsonls", "omnisharp", "clangd" }
			for _, server in ipairs(servers) do
				lspconfig[server].setup({ capabilities = capabilities })
			end
		end,
	},
}
