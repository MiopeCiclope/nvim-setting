return {
	"terrortylor/nvim-comment",
	config = function()
		require("nvim_comment").setup()
		vim.keymap.set({"n", "x"}, "<leader>b", ":CommentToggle<CR>", {})
	end,
}
