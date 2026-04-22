return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	config = function()
		local null_ls = require("null-ls")

		local rustfmt = {
			method = null_ls.methods.FORMATTING,
			filetypes = { "rust" },
			generator = null_ls.formatter({
				command = "rustfmt",
				args = { "--emit=stdout" },
				to_stdin = true,
			}),
		}

		local severity_map = {
			warning = vim.diagnostic.severity.WARN,
			error = vim.diagnostic.severity.ERROR,
		}

		local oxlint = {
			method = null_ls.methods.DIAGNOSTICS,
			filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
			generator = null_ls.generator({
				command = "/opt/homebrew/bin/oxlint",
				args = { "--format", "json", "$FILENAME" },
				to_stdin = false,
				check_exit_code = function(code)
					return code <= 1
				end,
				on_output = function(params)
					local diagnostics = {}
					local ok, parsed = pcall(vim.json.decode, params.output)
					if not ok or not parsed or not parsed.diagnostics then
						return diagnostics
					end
					for _, d in ipairs(parsed.diagnostics) do
						local label = d.labels and d.labels[1]
						if label then
							table.insert(diagnostics, {
								row = label.span.line,
								col = label.span.column - 1,
								message = d.message,
								code = d.code,
								severity = severity_map[d.severity] or vim.diagnostic.severity.WARN,
								source = "oxlint",
							})
						end
					end
					return diagnostics
				end,
			}),
		}

		null_ls.setup({
			sources = {
				-- JS/TS
				oxlint,
				null_ls.builtins.formatting.prettier,

				-- Rust
				rustfmt,

				-- Lua
				null_ls.builtins.formatting.stylua,

				-- Protobuf
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

				-- Python
				null_ls.builtins.formatting.black,
			},
		})

		vim.keymap.set("n", "<leader>p", function()
			vim.lsp.buf.format({
				async = true,
				filter = function(client)
					return client.name == "null-ls"
				end,
			})
		end, {})
	end,
}
