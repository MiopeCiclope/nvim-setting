return {
	"saghen/blink.cmp",
	version = "*",
	opts = {
		keymap = {
			preset = "default",
			["<C-space>"] = { "accept" },
		},

		appearance = {
			use_nvim_cmp_as_default = true, -- Ensure blink.cmp uses nvim-cmp
			nerd_font_variant = "mono",
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			cmdline = {},
		},
		completion = {
			menu = { border = "single" },
			documentation = { window = { border = "single" } },
		},
		signature = { window = { border = "single" } },
	},

	opts_extend = { "sources.default" },
}
