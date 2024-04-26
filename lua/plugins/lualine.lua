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
        theme = "dracula",
      },
      tabline = {
        lualine_a = { "buffers" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "filename", "location" },
        lualine_c = {
          {
            "macro-recording",
            fmt = show_macro_recording,
          },
        },
        lualine_x = {
          {
            require("noice").api.status.command.get,
            cond = require("noice").api.status.command.has,
            color = { fg = "white" },
          },
        },
        lualine_y = {
          {
            require("noice").api.status.search.get,
            cond = require("noice").api.status.search.has,
            color = { fg = "white" },
          },
        },
        lualine_z = {
          {
            require("noice").api.status.message.get_hl,
            cond = require("noice").api.status.message.has,
          },
        },
      },
    })
  end,
}
