return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		vim.keymap.set("n", "<C-x>", "<cmd>Neotree right toggle<CR>", {})
		vim.keymap.set("n", "<leader>r", "<cmd>Neotree right reveal<CR>", {})
	end,
}
