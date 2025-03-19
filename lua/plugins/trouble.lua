return {
	"folke/trouble.nvim",
	opts = {},
	cmd = "Trouble",
	keys = {
		{
			"<leader>x",
			"<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>",
			desc = "Buffer Diagnostics (Trouble)",
		},
		{
			"<leader>r",
			"<cmd>Trouble lsp_references toggle focus=true win.position=right win.size.width=80<cr>",
			desc = "LSP Definitions / references / ... (Trouble)",
		},
	},
}
