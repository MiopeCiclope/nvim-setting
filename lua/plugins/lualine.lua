return {
	"nvim-lualine/lualine.nvim",
	config = function()
		local function show_macro_recording()
			local recording_register = vim.fn.reg_recording()
			if recording_register == "" then
				return ""
			else
				return "Recording @" .. recording_register
			end
		end

		local customTheme = require("lualine.themes.auto")
		local whiteColor = "#FFFFFF"
		local blackColor = "#000000"
		customTheme.normal.a.bg = "#C7A3FF"
		customTheme.normal.a.fg = blackColor
		customTheme.normal.b.fg = whiteColor
		customTheme.normal.c.bg = blackColor
		customTheme.command.c.bg = blackColor
		customTheme.insert.c.bg = blackColor
		customTheme.visual.c.bg = blackColor

		require("lualine").setup({
			options = { theme = customTheme },
			tabline = {
				lualine_a = {
					{
						"buffers",
						buffers_color = {
							active = { bg = blackColor, fg = whiteColor },
							inactive = { bg = whiteColor, fg = blackColor },
						},
					},
				},
				lualine_z = { { "branch", color = { bg = whiteColor } } },
			},
			sections = {
				lualine_a = { { "mode", right_padding = 2 } },
				lualine_b = { "filename", "location" },
				lualine_c = {},
				lualine_x = {},
				lualine_y = { "diagnostics" },
				lualine_z = {
					{
						"macro-recording",
						fmt = show_macro_recording,
					},
				},
			},
		})
	end,
}
