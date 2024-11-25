return {
	"rest-nvim/rest.nvim",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"manoelcampos/xml2lua",
		"j-hui/fidget.nvim",
		"nvim-lua/plenary.nvim", -- Ensure Plenary is loaded as a dependency
	},
	opts = {
		curl = {
			verbose = false, -- Set this to false if it’s enabled
		},
		rocks = {
			hererocks = true, -- Use hererocks to install LuaRocks dependencies
		},
		result_split_horizontal = false, -- Result window splits horizontally.
		skip_ssl_verification = false, -- Skip SSL verification for self-signed certs.
		encode_url = true, -- Encode URLs automatically.
		highlight = {
			enabled = true, -- Enable request syntax highlighting.
			timeout = 150, -- Duration of highlighting in ms.
		},
		env = {
			enable = true,
			pattern = ".*%.env.*", -- Pattern for environment variable files
		},
		render = {
			json = {
				enabled = true, -- Enable JSON formatting
				syntax = "json", -- Use json syntax for highlighting
				line_numbers = true, -- Show line numbers in the response
			},
		},
	},
	config = function(_, opts)
		require("rest-nvim").setup(opts)

    -- this is necessary to make curl output formatting to work
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "json" },
			callback = function()
				vim.api.nvim_set_option_value("formatprg", "jq", { scope = "local" })
			end,
		})
		-- Check if mimetypes is available
		local has_mimetypes, mimetypes = pcall(require, "mimetypes")
		if not has_mimetypes then
			vim.notify("Dependency 'mimetypes' is missing. Attempting to install it...", vim.log.levels.WARN)

			-- Try to install mimetypes via LuaRocks
			local install_output = vim.fn.system("luarocks install mimetypes")

			-- If installation fails, use fallback
			if not install_output:match("successfully installed") then
				vim.notify(
					"Failed to install 'mimetypes' via LuaRocks. Using a local fallback...",
					vim.log.levels.ERROR
				)

				-- Fallback implementation for MIME types
				mimetypes = {
					get_mime_type = function(filename)
						local mime_map = {
							html = "text/html",
							json = "application/json",
							xml = "application/xml",
							txt = "text/plain",
						}
						local ext = filename:match("^.+%.(.+)$")
						return mime_map[ext] or "application/octet-stream"
					end,
				}
			end
		end

		-- Make mimetypes globally available
		_G.mimetypes = mimetypes

		vim.keymap.set(
			"n",
			"<leader>ö",
			"<cmd>Rest run <cr>",
			{ noremap = true, silent = true, desc = "Run REST request" }
		)
	end,
}
