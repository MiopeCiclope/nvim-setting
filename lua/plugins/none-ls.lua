return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				-- Existing formatters & linters
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

				-- 🔥 Add Python Formatters
				null_ls.builtins.formatting.black,  -- Black for formatting
				null_ls.builtins.formatting.isort,  -- isort for sorting imports
				null_ls.builtins.formatting.ruff,   -- Ruff for fast linting + formatting
			},
		})

		-- Bind format to a key (optional)
		vim.keymap.set("n", "<leader>p", vim.lsp.buf.format, {})
	end,
}
