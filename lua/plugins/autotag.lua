return {
	{
		dir = "~/projects/autotag",
		dev = true,
		config = function()
			require("autotag").setup({
				patterns = { "*.tsx", "*.jsx", "*.html" },
			})
		end,
	},
}
