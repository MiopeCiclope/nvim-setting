return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				require("none-ls.formatting.eslint_d"),
				require("none-ls.diagnostics.eslint_d"),
				null_ls.builtins.formatting.stylua,
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
			},
		})

		vim.keymap.set("n", "<leader>p", vim.lsp.buf.format, {})
	end,
}
