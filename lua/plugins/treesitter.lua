return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = { "windwp/nvim-ts-autotag" },
	config = function()
		local treesitterConfig = require("nvim-treesitter.configs")
		treesitterConfig.setup({
			auto_install = true,
			ensure_installed = { "rust", "lua", "javascript", "typescript", "java", "go", "html", "css", "tsx", "http", "sql" },
			highlight = { enable = true },
			indent = { enable = true },
			additional_vim_regex_highlighting = false,
		})
		require("nvim-ts-autotag").setup()
	end,
}
