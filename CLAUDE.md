# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

Modular Neovim config in Lua using **lazy.nvim** for plugin management.

**Load order** (`init.lua`):
1. Bootstrap lazy.nvim
2. `require("options")` → `require("autocmds")` → `require("keymaps")` → `require("statusline")` → `require("colors")`
3. `require("utils").setup_autopairs()`
4. `require("lazy").setup("plugins")` — auto-loads all files in `lua/plugins/`

**Core modules** (`lua/`):
- `fzf.lua` — Custom FZF integration (git files, buffer search, grep). Spawns terminal jobs via `vim.fn.jobstart()`, writes results to temp files, opens results in a full-screen tab.
- `utils.lua` — Shared helpers: dependency checks (`fzf`, `git`, `bat`), temp file management, git repo detection, path utilities.
- `colors.lua` — Built-in colorscheme setup (retrobox/habamax fallback) with custom highlights; neon green #00FF00 as the sole accent.
- `statusline.lua` — Custom statusline with diagnostics and dynamic filename display.

**Plugin configs** (`lua/plugins/`): Each file returns a lazy.nvim plugin spec table. Key ones:
- `lsp-config.lua` — Mason + nvim-lspconfig for ts_ls, lua_ls, pyright, gopls, clangd, html, cssls, jsonls
- `completions.lua` — blink.cmp with LuaSnip
- `none-ls.lua` — Formatting/linting (eslint, stylua, black, rustfmt, buf)
- `harpoon.lua` — Branch-aware quick file navigation

## Commands

```bash
# Syntax check
luac -p lua/**/*.lua

# Test config loads
nvim --headless -c "lua print('ok')" -c "qa"

# Plugin management
nvim --headless "+Lazy sync" +qa
nvim --headless "+Lazy install" +qa
nvim --headless "+Lazy clean" +qa

# Required CLI deps
which fzf git bat
brew install fzf bat ripgrep   # macOS
```

## Code Conventions

All modules use the `local M = {}` / `return M` pattern.

Naming: `snake_case` for files, functions, and variables; `UPPER_SNAKE_CASE` for constants; `vim.g.*` for Neovim globals.

Key mapping pattern:
```lua
local map = vim.keymap.set
local opts = { noremap = true }
map("n", "<leader>x", function() require("module").fn() end, opts)
```

Plugin spec pattern:
```lua
return {
    "author/plugin",
    dependencies = { "dep/plugin" },
    config = function()
        require("plugin").setup({ ... })
    end,
}
```

LSP capabilities must use: `require("blink.cmp").get_lsp_capabilities()`

## FZF Integration

`fzf.lua` pipes shell commands through a fixed pipeline:

1. Source command (e.g. `git ls-files`)
2. `awk` to format as `filename - path`
3. `fzf` with preview via `bat`
4. `awk` to extract `path:line` for the result

Results are written to a temp file and parsed in `on_exit`. Single selection opens the file directly; multiple selections go to the quickfix list.

## External Dependencies

Required: `fzf`, `git`, `bat`
Required for treesitter (`main` branch): `tree-sitter` CLI — used to compile
parsers. Install with `npm i -g tree-sitter-cli` (the Homebrew `tree-sitter`
formula ships only the library, not the CLI binary).
Optional: `tmux` (pane navigation via vim-tmux-navigator)
AI: Ollama on `localhost:11434` (models: deepseek-coder-v2, qwen2.5-coder:1.5b-base)

LSP servers and most linters/formatters auto-install on startup via
`mason-tool-installer` (see `lua/plugins/lsp-config.lua`). Exceptions installed
via Homebrew: `black` (Mason requires Python >=3.10), `stylua`.

## Key Mappings Reference

| Key | Action |
|-----|--------|
| `<C-p>` | FZF git files |
| `<Leader>b` | FZF buffer list |
| `<Leader>z` | FZF grep search |
| `<Leader>d` | Toggle diagnostics |
| `<Leader>g` | Go to definition |
| `<Leader>G` | Go to definition (split) |
| `<Leader>ca` | Code actions |
| `<Leader>p` | Format file |
| `<Leader>hh` | Harpoon quick menu |
| `<Leader>1-5` | Harpoon jump to file |
| `t` / `r` | Remap of `$` / `^` |
| `w` | Remap of `b` (word back) |
