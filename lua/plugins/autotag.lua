return {

	{
		"MiopeCiclope/autotag",
		config = function()
			require("autotag").setup({
				patterns = { "*.tsx", "*.jsx", "*.html" },
			})
		end,
	},
}
