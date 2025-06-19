return {
	{
		"Kurama622/llm.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
		cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
		config = function()
			vim.env.LLM_KEY = "none"
			local tools = require("llm.tools")
			require("llm").setup({
				app_handler = {
					Completion = {
						handler = tools.completion_handler,
						opts = {
							url = "http://localhost:11434/v1/completions",
							model = "qwen2.5-coder:1.5b-base",
							api_type = "ollama",
							n_completions = 1,
							context_window = 512,
							max_tokens = 256,
							default_filetype_enabled = true,
							auto_trigger = true,
							only_trigger_by_keywords = true,
							style = "blink.cmp", -- nvim-cmp or blink.cmp
							timeout = 10, -- max request time
							throttle = 1000,
							debounce = 400,
							keymap = {
								toggle = {
									mode = "n",
									keys = "<leader>cp",
								},
							},
						},
					},
				},
			})
		end,
		keys = {
			{ "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>" },
			{
				"<leader>ae",
				mode = "v",
				"<cmd>LLMSelectedTextHandler please explain hte following code, in enclish<cr>",
			},
		},
	},
}
