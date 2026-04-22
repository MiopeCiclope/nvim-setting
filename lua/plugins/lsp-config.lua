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
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Set capabilities globally for all servers
			vim.lsp.config("*", { capabilities = capabilities })

			-- 1. DEFINE & ENABLE IDEALS (Custom Server for IntelliJ via TCP)
			-- Merge default nvim capabilities with blink's so IdeaLS gets workspaceFolders
			-- and other fields it needs to resolve symbols correctly.
			local ideals_caps = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				capabilities
			)
			local function ideals_cmd(dispatchers)
				local function is_listening()
					local out = vim.fn.system("lsof -nP -i tcp:8989 -sTCP:LISTEN 2>/dev/null")
					return out ~= ""
				end

				if not is_listening() then
					vim.notify("Starting IntelliJ LSP server...", vim.log.levels.INFO)
					vim.fn.jobstart({
						vim.fn.expand("~/Applications/IntelliJ IDEA.app/Contents/MacOS/idea"),
						"lsp-server", "tcp", "8989",
					}, { detach = true })

					-- Wait up to 30s for port to open (processes UI events between checks)
					local ok = vim.fn.wait(30000, is_listening, 500)
					if ok ~= 0 then
						vim.notify("IntelliJ LSP server did not start in time", vim.log.levels.ERROR)
						return
					end
					vim.notify("IntelliJ LSP server ready, connecting...", vim.log.levels.INFO)
				end

				return vim.lsp.rpc.connect("127.0.0.1", 8989)(dispatchers)
			end

			vim.lsp.config("ideals", {
				cmd = ideals_cmd,
				filetypes = { "java", "kotlin" },
				root_markers = { ".idea" },
				capabilities = ideals_caps,
				on_attach = function(client, bufnr)
					vim.notify("Connected to IntelliJ (IdeaLS)", vim.log.levels.INFO)
				end,
			})
			vim.lsp.enable("ideals")

			vim.lsp.config("ts_ls", {
				settings = {
					typescript = { format = { enable = false } },
					javascript = { format = { enable = false } },
				},
			})

			vim.lsp.config("lua_ls", {
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

			vim.lsp.config("pyright", {
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

			vim.lsp.config("tailwindcss", {
			filetypes = {
				"html", "css", "scss",
				"javascript", "javascriptreact", "typescript", "typescriptreact",
				"vue", "svelte", "astro",
			},
			settings = {
				tailwindCSS = {
					experimental = {
						classRegex = {
							-- bare string literals: "flex items-center"
							{ '["\'`]([^"\'`]*)["\'`]' },
							-- array items: ["flex", "items-center"]
							{ '\\[([^\\]]*)\\]', '["\'`]([^"\'`]*)["\'`]' },
						},
					},
				},
			},
		})


		vim.lsp.enable({ "ts_ls", "lua_ls", "pyright", "html", "cssls", "gopls", "jsonls", "omnisharp", "clangd", "tailwindcss", "sqls" })

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
