return {
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = true,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- LSP servers (Mason package names)
					"lua-language-server",
					"typescript-language-server",
					"pyright",
					"html-lsp",
					"css-lsp",
					"gopls",
					"json-lsp",
					"clangd",
					"tailwindcss-language-server",
					"sqls",
					"omnisharp",
					"rust-analyzer",
					-- linters / formatters
					"oxlint",
					"prettier",
					"stylua",
					-- black is installed via Homebrew (Mason needs python >=3.10, system has 3.9)
					"buf",
				},
				run_on_start = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

			vim.lsp.enable({
				"ts_ls",
				"lua_ls",
				"pyright",
				"html",
				"cssls",
				"gopls",
				"jsonls",
				"omnisharp",
				"clangd",
				"tailwindcss",
				"sqls",
				"rust_analyzer",
				"ideals",
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
		end,
	},
}
