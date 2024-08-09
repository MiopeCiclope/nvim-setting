return {
  "nvim-lualine/lualine.nvim",
  after = "~/projects/job-notifier",
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

    local job_notifier = require("job-notifier")
    local function getReact()
      return job_notifier.getState("react")
    end

    local function getWatcher()
      return job_notifier.getState("watcher")
    end

    local function removeNil(str)
      if str == nil or str == "nil" then
        return ""
      end
      return str
    end

    require("lualine").setup({
      options = { theme = customTheme },
      sections = {
        lualine_a = {
          { "mode", right_padding = 2 },
        },
        lualine_b = { "filename", "location" },
        lualine_c = { {
          "macro-recording",
          fmt = show_macro_recording,
        } },
        lualine_x = { "diagnostics" },
        lualine_y = {
          {
            getWatcher,
            fmt = removeNil,
            color = function(section)
              return { fg = job_notifier.getColor("watcher"), bg = "white" }
            end,
            icon = { "\u{ea70}", color = { fg = "black", bg = "white" } },
            separator = { left = "|" },
          },
        },
        lualine_z = {
          {
            getReact,
            fmt = removeNil,
            color = function(section)
              local font_color = "black"
              local status_color = job_notifier.getColor("react")
              if status_color ~= nil and status_color ~= "nil" then
                font_color = status_color
              end
              return { fg = font_color, bg = "#f5dbc9" }
            end,
            icon = { "\u{e7ba}", color = { fg = "black", bg = "#f5dbc9" } },
            separator = { left = "|" },
          },
        },
      },
    })
  end,
}
