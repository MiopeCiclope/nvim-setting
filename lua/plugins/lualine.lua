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
		customTheme.normal.a.bg = "#C7A3FF"
		customTheme.normal.a.fg = "#000000"
		customTheme.normal.b.fg = "#FFFFFF"

		require("lualine").setup({
			options = { theme = customTheme },
			sections = {},
			tabline = {
				lualine_a = { { "mode", right_padding = 2 } },
				lualine_b = { "filename", "location" },
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
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
