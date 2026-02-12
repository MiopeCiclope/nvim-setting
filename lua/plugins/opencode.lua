return {
	"sudo-tee/opencode.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				anti_conceal = { enabled = false },
				file_types = { "markdown", "opencode_output" },
			},
			ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
		},
		"saghen/blink.cmp",
		"folke/snacks.nvim",
	},
	config = function()
		require("opencode").setup({
			-- Default to architect for complex work
			default_mode = "plan",
			opencode_executable = "opencode",
			keymap_prefix = "<leader>a",

			ui = {
				position = "right",
				window_width = 0.40,
				display_model = true,
				display_cost = false,
			},

			context = {
				enabled = true,
				current_file = { enabled = true },
				diagnostics = {
					error = true,
					warn = true,
					info = false,
				},
				selection = { enabled = true },
			},

			keymap = {
				editor = {
					["<leader>aa"] = { "toggle" },
					["<leader>ai"] = { "open_input" },
					["<leader>ap"] = { "configure_provider" }, -- Switch between architect/assistant/coder
					["<leader>am"] = { "switch_mode" },
					["<leader>ad"] = { "diff_open" },
					["<leader>ar"] = { "diff_revert_all_last_prompt" },
				},
				input_window = {
					["<S-cr>"] = { "submit_input_prompt", mode = { "n", "i" } },
					["<C-c>"] = { "cancel" },
					["@"] = { "mention", mode = "i" },
					["/"] = { "slash_commands", mode = "i" },
				},
			},
		})
	end,
}
