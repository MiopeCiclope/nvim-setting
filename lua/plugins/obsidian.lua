return {
	"epwalsh/obsidian.nvim",
	ft = "markdown",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("obsidian").setup({
			workspaces = {
				{
					name = "work",
					path = "~/vault/Work",
					strict = true,
				},
				{
					name = "personal",
					path = "~/vault/Personal",
					strict = true,
				},
			},
			templates = {
				subdir = "templates",
				date_format = "%Y-%m-%d",
				time_format = "%H:%M",
			},
			completion = {
				nvim_cmp = false,
				min_chars = 2,
			},
			daily_notes = {
				folder = "jornal",
				date_format = "%Y-%m-%d",
				alias_format = "%B %-d, %Y",
				template = nil,
			},
			ui = {
				enable = true, -- set to false to disable all additional syntax features
				checkboxes = {
					[" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
					["x"] = { char = "✔", hl_group = "ObsidianDone" },
					[">"] = { char = "", hl_group = "ObsidianRightArrow" },
					["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
					["!"] = { char = "", hl_group = "ObsidianImportant" },
				},
			},
		})
		vim.keymap.set("n", "<leader>on", ":ObsidianNew ", { noremap = false })
		vim.keymap.set("n", "<leader>op", function()
			local vault_path = require("obsidian").get_client().dir
			local fzf = require("fzf")

			local pattern = vim.fn.input("Obsidian Grep Search: ")
			if pattern == "" or pattern == nil then
				return
			end

			fzf.run({
				source  = string.format("grep -rl '%s' %s --include='*.md'", pattern, vault_path),
				display = "file",
				preview = "file",
				extract = "path",
				deps    = { "fzf", "bat" },
			})()
		end, { noremap = false })

		vim.keymap.set("n", "<leader>og", function()
			if require("obsidian").util.cursor_on_markdown_link() then
				return "<cmd>ObsidianFollowLink<CR>"
			else
				return "gf"
			end
		end, { noremap = false, expr = true })
	end,
}
