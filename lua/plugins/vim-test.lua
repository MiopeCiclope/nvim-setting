return {
	"vim-test/vim-test",
	dependencies = {
		"preservim/vimux",
	},
	vim.keymap.set("n", "<leader>tn", ":TestNearest<CR>"),
	vim.keymap.set("n", "<leader>tf", ":TestFile<CR>"),
	vim.keymap.set("n", "<leader>ta", ":TestSuite<CR>"),
	vim.keymap.set("n", "<leader>tl", ":TestLast<CR>"),
	vim.keymap.set("n", "<leader>tg", ":TestVisit<CR>"),
	vim.cmd("let test#strategy = 'vimux'"),
	vim.cmd("let g:VimuxOrientation = 'h'"),
	vim.cmd("let g:VimuxHeight = '40'"),
	vim.cmd("let g:test#javascript#jest#executable= 'npm run test'"),
}
