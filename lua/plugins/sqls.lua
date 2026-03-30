return {
	"nanotee/sqls.nvim",
	ft = { "sql" },
	config = function()
		vim.lsp.config("sqls", {
			on_attach = function(client, bufnr)
				client.server_capabilities.executeCommandProvider = true
				client.server_capabilities.codeActionProvider = { resolveProvider = false }
				client.commands = require("sqls").commands

				vim.api.nvim_buf_create_user_command(bufnr, "SqlsExecuteQuery", function(args)
					require("sqls.commands").exec(
						client.id, "executeQuery", args.smods,
						args.range ~= 0, args.line1, args.line2
					)
				end, { range = true })

				vim.keymap.set({ "n", "x" }, "<leader>sq", "<cmd>SqlsExecuteQuery<cr>",
					{ noremap = true, buffer = bufnr, desc = "Execute query" })
			end,
		})
	end,
}
