return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		{ "windwp/nvim-ts-autotag" },
	},
	build = ":TSUpdate",
	config = function()
		local treesitterConfig = require("nvim-treesitter.configs")
		treesitterConfig.setup({
			auto_install = true,
			ensure_installed = { "lua", "javascript", "typescript", "java", "go", "html", "css" },
			highlight = { enable = true },
			indent = { enable = true },
			autotag = {
				enable = true,
			},
		})
	end,
}
