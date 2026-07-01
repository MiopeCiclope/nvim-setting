return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	dependencies = { "windwp/nvim-ts-autotag" },
	config = function()
		local langs = { "rust", "lua", "javascript", "typescript", "java", "go", "html", "css", "tsx", "http", "sql" }
		require("nvim-treesitter").install(langs)

		-- main branch does not auto-enable highlighting; start it per buffer
		-- when a parser is available (pcall guards filetypes with no parser).
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})

		require("nvim-ts-autotag").setup()
	end,
}
