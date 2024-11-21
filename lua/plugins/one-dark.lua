return {
  "olimorris/onedarkpro.nvim",
  priority = 1001,
  config = function()
    vim.cmd("colorscheme onedark_dark")

    -- line number color
    vim.cmd([[highlight LineNr guifg=white]])

    -- current line number
    vim.cmd([[highlight CursorLineNr guifg=yellow]])

    -- cursor line higlight
    vim.cmd([[highlight CursorLine cterm=NONE guibg=#385f54]])

    -- make selection become same color as cursor line
    vim.cmd([[highlight! link Visual CursorLine]])

    -- window separator color
    vim.cmd([[highlight WinSeparator guifg=white]])

    -- unfocused pane/window
    vim.cmd([[highlight NormalNC guibg=#444444]])
    vim.cmd([[set winhighlight=NormalNC:NormalNC]])

    -- comment font color
    vim.cmd([[highlight Comment      guifg=#B1C4DE]])
  end
}
