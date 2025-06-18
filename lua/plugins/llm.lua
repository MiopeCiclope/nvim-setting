return {
	{
		"Kurama622/llm.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
		cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
		config = function()
			vim.env.LLM_KEY = "none"
			require("llm").setup({
				-- [[ local llm ]]
				url = "http://localhost:11434/api/chat",
				-- url = "http://localhost:11434/v1/completions",

				-- model = "qwen2.5-coder:1.5b",
				model = "deepseek-coder-v2",
				api_type = "ollama",
				temperature = 0.3,
				top_p = 0.7,

				prompt = "You are an AI assistant. Respond **only** in English. Never use Chinese or other languages unless the user explicitly requests it.",

				prefix = {
					user = { text = "😃 ", hl = "Title" },
					assistant = { text = "  ", hl = "Added" },
				},
				-- history_path = "/tmp/llm-history",
				save_session = true,
				max_history = 15,
				max_history_name_length = 20,
				-- Completion = {
				-- 	-- handler = tools.completion_handler,
				-- 	opts = {
				-- 		n_completions = 3, -- Number of suggestions to show
				-- 		context_window = 512, -- Context size (in tokens)
				-- 		max_tokens = 256, -- Max length per completion
				-- 		auto_trigger = true, -- Show suggestions automatically
				-- 		throttle = 1000, -- Delay between requests (ms)
				-- 		debounce = 400, -- Input stabilization delay
				--
				-- 		-- Filetype controls
				-- 		filetypes = {
				-- 			python = true,
				-- 			lua = true,
				-- 			sh = false, -- Disable for shell scripts
				-- 		},
				-- 		default_filetype_enabled = true, -- Enable for unlisted filetypes
				--
				-- 		-- Trigger behavior
				-- 		only_trigger_by_keywords = true, -- Activate on: @ . ( [ : space
				-- 		style = "blink.cmp", -- Integration with blink.cmp
				--
				-- 		-- Keymaps (for virtual_text mode)
				-- 		keymap = {
				-- 			virtual_text = {
				-- 				accept = { mode = "i", keys = "<A-a>" },
				-- 				next = { mode = "i", keys = "<A-n>" },
				-- 				prev = { mode = "i", keys = "<A-p>" },
				-- 				toggle = { mode = "n", keys = "<leader>cp" },
				-- 			},
				-- 		},
				-- 	},
				-- },
        -- stylua: ignore
        keys = {
          -- The keyboard mapping for the input window.
          ["Input:Submit"]      = { mode = "n", key = "<cr>" },
          ["Input:Cancel"]      = { mode = {"n", "i"}, key = "<C-c>" },
          ["Input:Resend"]      = { mode = {"n", "i"}, key = "<C-r>" },

          -- only works when "save_session = trueplease explain hte following code"
          ["Input:HistoryNext"] = { mode = {"n", "i"}, key = "<C-j>" },
          ["Input:HistoryPrev"] = { mode = {"n", "i"}, key = "<C-k>" },

          -- The keyboard mapping for the output window in "split" style.
          ["Output:Ask"]        = { mode = "n", key = "i" },
          ["Output:Cancel"]     = { mode = "n", key = "<C-c>" },
          ["Output:Resend"]     = { mode = "n", key = "<C-r>" },
          -- The keyboard mapping for the output and input windows in "float" style.
          ["Session:Toggle"]    = { mode = "n", key = "<leader>ac" },
          ["Session:Close"]     = { mode = "n", key = {"<esc>", "Q"} },

          -- Scroll
          ["PageUp"]            = { mode = {"i","n"}, key = "<C-b>" },
          ["PageDown"]          = { mode = {"i","n"}, key = "<C-f>" },
          ["HalfPageUp"]        = { mode = {"i","n"}, key = "<C-u>" },
          ["HalfPageDown"]      = { mode = {"i","n"}, key = "<C-d>" },
          ["JumpToTop"]         = { mode = "n", key = "gg" },
          ["JumpToBottom"]      = { mode = "n", key = "G" },
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
			{ "<leader>ts", mode = "x", "<cmd>LLMSelectedTextHandler 英译汉<cr>" },
		},
	},
}
