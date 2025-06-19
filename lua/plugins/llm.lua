return {
	{
		"Kurama622/llm.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
		cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
		config = function()
			vim.env.LLM_KEY = "none"
			local tools = require("llm.tools")
			require("llm").setup({
				prompt = "You are a professional programmer.",
				url = "http://localhost:11434/api/chat",
				model = "deepseek-coder-v2",
				api_type = "ollama",
				style = "right",
				keys = {
					["Input:Submit"] = { mode = "n", key = "<cr>" },
					["Input:Cancel"] = { mode = { "n", "i" }, key = "<C-c>" },
					["Input:Resend"] = { mode = { "n", "i" }, key = "<C-r>" },
					-- only works when "save_session = true"
					["Input:HistoryNext"] = { mode = { "n", "i" }, key = "<C-n>" },
					["Input:HistoryPrev"] = { mode = { "n", "i" }, key = "<C-p>" },

					-- -- The keyboard mapping for the output window in "split" style.
					["Output:Ask"] = { mode = "n", key = "i" },
					["Output:Cancel"] = { mode = "n", key = "<C-c>" },
					["Output:Resend"] = { mode = "n", key = "<C-r>" },

					-- The keyboard mapping for the output and input windows in "float" style.
					["Session:Toggle"] = { mode = "n", key = "<leader>ac" },
					["Session:Close"] = { mode = "n", key = { "<esc>", "Q" } },

					-- Scroll
					["PageUp"] = { mode = { "i", "n" }, key = "<C-b>" },
					["PageDown"] = { mode = { "i", "n" }, key = "<C-f>" },
					["HalfPageUp"] = { mode = { "i", "n" }, key = "<C-u>" },
					["HalfPageDown"] = { mode = { "i", "n" }, key = "<C-d>" },
					["JumpToTop"] = { mode = "n", key = "gg" },
					["JumpToBottom"] = { mode = "n", key = "G" },
				},
				app_handler = {
					-- 					TestCode = {
					-- 						handler = tools.side_by_side_handler,
					-- 						style = "right",
					-- 						prompt = [[ Write some test cases for the following code, only return the test cases.
					-- Give the code content directly, do not use code blocks or other tags to wrap it. ]],
					-- 						opts = {
					-- 							right = {
					-- 								title = " Test Cases ",
					-- 							},
					-- 						},
					-- 					},
					AttachToChat = {
						handler = tools.attach_to_chat_handler,
						opts = {
							is_codeblock = true,
							inline_assistant = true,
							language = "English",
							-- display diff
							display = {
								mapping = {
									mode = "n",
									keys = { "d" },
								},
								action = nil,
							},
							-- accept diff
							accept = {
								mapping = {
									mode = "n",
									keys = { "Y", "y" },
								},
								action = nil,
							},
							-- reject diff
							reject = {
								mapping = {
									mode = "n",
									keys = { "N", "n" },
								},
								action = nil,
							},
							-- close diff
							close = {
								mapping = {
									mode = "n",
									keys = { "<esc>" },
								},
								action = nil,
							},
						},
					},
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
							style = "blink.cmp",
							timeout = 10,
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
			{ "<leader>:", mode = "n", "<cmd>LLMSessionToggle<cr>" },
			{
				"<leader>ae",
				mode = "v",
				"<cmd>LLMSelectedTextHandler please explain hte following code, in english<cr>",
			},
			{
				"<leader>tt",
				mode = "v",
				"<cmd>LLMSelectedTextHandler give me the english translation of this text, no explanation, just the text <cr>",
			},
		},
	},
}
