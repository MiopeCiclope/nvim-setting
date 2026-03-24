return {
	"mistweaverco/kulala.nvim",
	ft = { "http" },
	keys = {
		{
			"<leader>rr",
			function()
				require("kulala").run()
			end,
			desc = "Run request under cursor",
		},
		{
			"<leader>ri",
			function()
				require("swagger").import()
			end,
			desc = "Import from Swagger",
		},
		{
			"<leader>re",
			function()
				local env = vim.fn.getcwd() .. "/http-client.env.json"
				if vim.fn.filereadable(env) == 0 then
					vim.notify("[swagger] No http-client.env.json found in cwd", vim.log.levels.WARN)
					return
				end
				vim.cmd("vsplit " .. vim.fn.fnameescape(env))
			end,
			desc = "Edit REST env variables",
		},
	},
	config = function()
		require("kulala").setup({
			default_view = "body",
			display_mode = "split",
			split_direction = "vertical",
			default_env = "dev",
			formatters = {
				json = { "jq", "." },
			},
		})

		vim.api.nvim_create_user_command("SwaggerImport", function(opts)
			require("swagger").import(opts.args ~= "" and opts.args or nil)
		end, { nargs = "?", desc = "Generate .http file from OpenAPI/Swagger spec" })
	end,
}
