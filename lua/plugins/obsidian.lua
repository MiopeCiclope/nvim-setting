return {
	"epwalsh/obsidian.nvim",
	version = "v3.7.5", -- recommended, use latest release instead of latest commit
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
				nvim_cmp = true,
				min_chars = 2,
			},
			daily_notes = {
				folder = "jornal",
				date_format = "%Y-%m-%d",
				alias_format = "%B %-d, %Y",
				template = nil,
			},
		})
		vim.keymap.set("n", "<leader>o", ":ObsidianToday<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>oa", ":ObsidianTomorrow<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>oo", ":ObsidianYesterday<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>on", ":ObsidianNew ", { noremap = false })
		vim.keymap.set("n", "<leader>oww", ":ObsidianWorkspace work<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>owp", ":ObsidianWorkspace personal<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>ot", ":ObsidianTags<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>op", ":ObsidianSearc<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>ott", ":ObsidianTemplate<CR>", { noremap = false })
		vim.keymap.set("n", "<leader>og", function()
			if require("obsidian").util.cursor_on_markdown_link() then
				return ":ObsidianFollowLink<CR>"
			else
				return "gf"
			end
		end, { noremap = false, expr = true })
	end,
}
