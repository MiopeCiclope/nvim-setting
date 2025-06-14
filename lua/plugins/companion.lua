local DEFAULT_MODEL = "deepseek-coder-v2:latest"
-- local DEFAULT_MODEL = "codestral"

local defaultSetting = {
	adapter = "ollama",
	model = DEFAULT_MODEL,
}

return {
	"olimorris/codecompanion.nvim",
	opts = {
		adapters = {
			ollama = function()
				return require("codecompanion.adapters").extend("ollama", {
					schema = {
						model = {
							default = DEFAULT_MODEL,
						},
					},
				})
			end,
		},
		strategies = {
			chat = {
				adapter = "ollama",
				model = DEFAULT_MODEL, -- Use the default model here
				keymaps = {
					send = {
						modes = {
							n = "<CR>",
							i = "<C-CR>",
						},
						index = 1,
						callback = "keymaps.send",
						description = "Send",
					},
				},
			},
			inline = defaultSetting,
			agent = defaultSetting,
		},
	},
}
