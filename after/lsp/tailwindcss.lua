return {
	filetypes = {
		"html", "css", "scss", "javascript", "javascriptreact",
		"typescript", "typescriptreact", "vue", "svelte", "astro",
	},
	settings = {
		tailwindCSS = {
			experimental = {
				classRegex = {
					{ "[\"'`]([^\"'`]*)[\"'`]" },
					{ "\\[([^\\]]*)\\]", "[\"'`]([^\"'`]*)[\"'`]" },
				},
			},
		},
	},
}
