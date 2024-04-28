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

    require("lualine").setup({
      options = {
        component_separators = "",
        section_separators = { left = "", right = "" },
      },
      tabline = {
        lualine_a = { "buffers" },
      },
      sections = {
        lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
        lualine_b = { "filename", "location" },
        lualine_c = {
          {
            require("noice").api.status.message.get_hl,
            cond = require("noice").api.status.message.has,
          },
        },
        lualine_x = {
          {
            require("noice").api.status.command.get,
            cond = require("noice").api.status.command.has,
            color = { fg = "green" },
          },
        },
        lualine_y = {
          {
            "macro-recording",
            fmt = show_macro_recording,
          },

        },
        lualine_z = {
          {
            require("noice").api.status.search.get,
            cond = require("noice").api.status.search.has,
            color = { fg = "white" },
          }
        }
      },
    })
  end,
}
