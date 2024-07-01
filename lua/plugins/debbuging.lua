return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "leoluz/nvim-dap-go",
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    require("dapui").setup()
    require("dap-go").setup()

    dap.adapters.chrome = {
      type = "executable",
      command = "node",
      args = { os.getenv("HOME") .. "/projects/vscode-chrome-debug/out/src/chromeDebug.js" }, -- TODO adjust
    }

    dap.configurations.javascriptreact = { -- change this to javascript if needed
      {
        type = "chrome",
        request = "attach",
        program = "${file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = "inspector",
        port = 9222,
        webRoot = "${workspaceFolder}",
      },
    }

    dap.configurations.typescriptreact = { -- change to typescript if needed
      {
        type = "chrome",
        request = "launch",
        url = "http://localhost:3000",
        webRoot = "${workspaceFolder}",
      },
    }

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {})
    vim.keymap.set("n", "<leader>dc", dap.continue, {})
    vim.keymap.set("n", "<leader>ui", require("dapui").toggle, {})
  end,
}
