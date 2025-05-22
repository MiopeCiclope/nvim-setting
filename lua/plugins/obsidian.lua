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
		})
		vim.keymap.set("n", "<leader>oa", "<cmd>ObsidianTomorrow<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianYesterday<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>on", ":ObsidianNew ", { noremap = false })
		vim.keymap.set("n", "<leader>oww", "<cmd>ObsidianWorkspace work<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>owp", "<cmd>ObsidianWorkspace personal<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTags<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>op", "<cmd>ObsidianSearc<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>ott", "<cmd>ObsidianTemplate<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>og", function()
			if require("obsidian").util.cursor_on_markdown_link() then
				return "<cmd>ObsidianFollowLink<CR>"
			else
				return "gf"
			end
		end, { noremap = false, expr = true })
	end,
}
