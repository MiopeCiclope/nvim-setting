return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local get_git_branch = function()
      local branch = vim.fn
          .system({
            "git",
            "rev-parse",
            "--abbrev-ref",
            "HEAD",
          })
          :gsub("%s+", "")

      return branch ~= "" and branch or "default"
    end

    local harpoon = require("harpoon")

    local getList = function()
      return harpoon:list(get_git_branch())
    end

    harpoon:setup({
      [get_git_branch()] = {
        display = function(list_item)
          local cropped_path, tail = list_item.value:match("^(.*)/(.*)$")
          return string.format("%s - %s/", tail, cropped_path)
        end,
      },
    })

    vim.keymap.set("n", "<leader>hh", function()
      harpoon.ui:toggle_quick_menu(getList(), { title = "Harpoon - " .. get_git_branch() })
    end)

    vim.keymap.set("n", "<leader>ha", function()
      getList():add()
    end)

    -- make quick selection from 1 to 5
    for i = 1, 5 do
      vim.keymap.set("n", "<leader>" .. i, function()
        getList():select(i)
      end)
    end
  end,
}
