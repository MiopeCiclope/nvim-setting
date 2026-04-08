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
						client.id,
						"executeQuery",
						{ split = "belowright" },
						args.range ~= 0,
						nil,
						args.line1,
						args.line2
					)
				end, { range = true })

				-- Normal mode: find statement node under cursor via treesitter
				vim.keymap.set("n", "<leader>sq", function()
					local cursor = vim.api.nvim_win_get_cursor(0)
					local row, col = cursor[1] - 1, cursor[2]
					local parser = vim.treesitter.get_parser(bufnr, "sql")
					local tree = parser:parse()[1]
					local root = tree:root()
					-- walk direct children of root to find the statement containing the cursor
					local start_line, end_line
					for node in root:iter_children() do
						local sr, _, er, _ = node:range()
						if sr <= row and row <= er then
							start_line = sr + 1 -- convert to 1-based
							end_line = er + 1
							break
						end
					end
					if not start_line then
						vim.notify("sqls: no statement at cursor", vim.log.levels.WARN)
						return
					end
					require("sqls.commands").exec(
						client.id,
						"executeQuery",
						{ split = "belowright" },
						true,
						nil,
						start_line,
						end_line
					)
				end, { noremap = true, buffer = bufnr, desc = "Execute statement" })

				-- Visual mode: use : to preserve selection range
				vim.keymap.set(
					"x",
					"<leader>sq",
					":SqlsExecuteQuery<cr>",
					{ noremap = true, buffer = bufnr, desc = "Execute selection" }
				)
			end,
		})
	end,
}
