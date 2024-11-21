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

    local job_notifier = require("job-notifier")
    local function getReact()
      return job_notifier:getStageData("react", "text")
      -- return job_notifier:getStageData("build", "text")
    end

    local function getWatcher()
      return job_notifier:getStageData("watcher", "text")
    end

    local function removeNil(str)
      if str == nil or str == "nil" then
        return ""
      end
      return str
    end

    require("lualine").setup({
      sections = {
        lualine_a = {
          { "mode", right_padding = 2 },
        },
        lualine_b = { "filename", "location" },
        lualine_c = {
        },
        lualine_x = { "diagnostics" },
        lualine_y = {
          {
            getWatcher,
            fmt = removeNil,
            color = function(section)
              return { fg = job_notifier:getStageData("watcher", "color"), bg = "white", gui = "bold" }
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
              -- return { fg = job_notifier:getStageData("build", "color"), bg = "#f5dbc9", gui = "bold" }
              return { fg = job_notifier:getStageData("react", "color"), bg = "#f5dbc9", gui = "bold" }
            end,
            icon = { "\u{e7ba}", color = { fg = "black", bg = "#f5dbc9" } },
            separator = { left = "|" },
          },
        },
      },
    })
  end,
}
