return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				defaults = {
					exclude_files = { "*.png" },
				},
			})
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<C-p>", builtin.find_files, {})
			vim.keymap.set("n", "<C-z>", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>rr", builtin.lsp_references, {})
			vim.keymap.set("n", "<leader>,", builtin.keymaps, {})
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				defaults = {
					path_display = function(opts, path)
						local tail = require("telescope.utils").path_tail(path)
						local cropped_path = string.match(path, "^(.*)/") or ""
						return string.format("%s - %s/", tail, cropped_path)
					end,
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
