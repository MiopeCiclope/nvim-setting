return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup({
      default = {
        display = function(list_item)
          local cropped_path, tail = list_item.value:match("^(.*)/(.*)$")
          return string.format("%s - %s/", tail, cropped_path)
        end,
      }
    })

    vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

    vim.keymap.set("n", "<leader>ha", function()
      harpoon:list():add()
    end)

    vim.keymap.set("n", "<leader>1", function()
      harpoon:list():select(1)
    end)
    vim.keymap.set("n", "<leader>2", function()
      harpoon:list():select(2)
    end)
    vim.keymap.set("n", "<leader>3", function()
      harpoon:list():select(3)
    end)
    vim.keymap.set("n", "<leader>4", function()
      harpoon:list():select(4)
    end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<leader>hn", function()
      harpoon:list():prev()
    end)

    vim.keymap.set("n", "<leader>hm", function()
      harpoon:list():next()
    end)
  end,
}
