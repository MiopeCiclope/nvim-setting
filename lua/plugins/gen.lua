-- Custom Parameters (with defaults)
return {
  "David-Kunz/gen.nvim",
  config = function()
    require("gen").setup({
      model = "codellama",    -- The default model to use.
      display_mode = "split", -- The display mode. Can be "float" or "split".
      show_prompt = true,     -- Shows the prompt submitted to Ollama.
    })

    require('gen').prompts['Enhance_Code'] =
    {
      prompt =
      "Enhance the following code, only output the result in format ```$filetype\n...\n```:\n```$filetype\n$text\n```",
      replace = false,
      extract = "```$filetype\n(.-)```",
    }

    vim.keymap.set("n", "<leader>ai", "<cmd>Gen Chat<CR>")
    vim.keymap.set("v", "<leader>ai", "<cmd>Gen Enhance_Code<CR>")
  end,
}
