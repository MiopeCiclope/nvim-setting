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

		null_ls.setup({
			sources = {
				-- JS/TS
				require("none-ls.diagnostics.eslint_d"),
				require("none-ls.formatting.eslint_d"),

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
