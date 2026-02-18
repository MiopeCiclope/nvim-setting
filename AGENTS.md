# AGENTS.md - Neovim Configuration Guide

This document provides guidance for agentic coding agents working on this Neovim configuration repository.

## Project Overview

This is a modular Neovim configuration using lazy.nvim for plugin management. The configuration is written in Lua and follows a minimal, functional approach with custom FZF integration and LSP support.

Key features:
- Plugin management via lazy.nvim
- Custom FZF-based file/telescope functionality
- LSP support with blink.cmp completion
- Modular Lua architecture
- External tool dependencies (fzf, git, bat, tmux)

## Development Commands

### Plugin Management
```bash
# Update all plugins
nvim --headless "+Lazy sync" +qa

# Install new plugins
nvim --headless "+Lazy install" +qa

# Check plugin status
nvim --headless "+Lazy status" +qa

# Clean unused plugins
nvim --headless "+Lazy clean" +qa
```

### Configuration Validation
```bash
# Check Lua syntax (requires luac)
luac -p lua/**/*.lua

# Test configuration startup
nvim --headless -c "lua print('Config loaded successfully')" -c "qa"

# Check LSP configuration
nvim --headless -c "lua print(vim.inspect(vim.lsp.get_active_clients()))" -c "qa"
```

### External Dependencies
```bash
# Check required tools
which fzf git bat tmux

# Install missing dependencies (macOS)
brew install fzf bat ripgrep

# Install language servers
nvim --headless "+Mason" +qa
```

## Code Style Guidelines

### Lua Module Pattern
All modules should follow this pattern:
```lua
local M = {}

-- Module functions here
function M.some_function()
    -- implementation
end

return M
```

### Naming Conventions
- **Files/Modules**: snake_case (e.g., `utils.lua`, `statusline.lua`)
- **Functions**: snake_case for module functions (`function M.get_diagnostics()`)
- **Variables**: snake_case for local variables
- **Constants**: UPPER_SNAKE_CASE for configuration constants
- **Global variables**: Use vim.g prefix for Neovim globals (`vim.g.mapleader`)

### Import/Require Patterns
```lua
-- Local modules use relative paths
local utils = require("utils")

-- Plugin configs require full path
local lspconfig = require("lspconfig")

-- Vim API usage
local map = vim.keymap.set
local opts = { noremap = true }
```

### Function Organization
- Keep functions focused and single-purpose
- Use table.insert for array operations
- Prefer vim.fn.* over vim.fn["*"] when possible
- Use vim.cmd() for Vim commands, vim.api.* for API calls

### Error Handling
```lua
-- Check dependencies before execution
if not utils.check_dependencies() then
    return
end

-- Check git repository status
if not utils.is_git_repo() then
    print("Not a git repository")
    return
end

-- Safe file operations
local file = io.open(temp_file, "r")
if file then
    local content = file:read("*a")
    file:close()
    return content
end
```

## Module Structure

### Core Files
- `init.lua` - Entry point, loads all modules
- `lua/options.lua` - Neovim options and settings
- `lua/keymaps.lua` - Global key mappings
- `lua/autocmds.lua` - Automatic commands
- `lua/utils.lua` - Utility functions and helpers
- `lua/statusline.lua` - Statusline configuration
- `lua/terminal.lua` - Terminal management
- `lua/fzf.lua` - FZF integration and file management

### Plugin Configuration
- `lua/plugins/*.lua` - Individual plugin configurations
- Each plugin config returns a table following lazy.nvim spec
- Group related plugins in separate files (e.g., lsp-config.lua)

## Plugin Development Guidelines

### Adding New Plugins
1. Create new file in `lua/plugins/` or add to existing file
2. Follow lazy.nvim plugin specification:
```lua
return {
    "plugin-author/plugin-name",
    version = "*",
    dependencies = { "dependency/plugin" },
    config = function()
        -- Plugin configuration here
    end,
}
```

### Plugin Configuration Patterns
- Use local variables for plugin instances
- Configure capabilities for LSP plugins: `require("blink.cmp").get_lsp_capabilities()`
- Use version constraints for stability
- Group related settings under `opts` table
- Prefer plugin's `config` function over separate setup calls

### LSP Server Setup
```lua
lspconfig.server_name.setup({
    capabilities = capabilities,
    settings = {
        -- Server-specific settings
    },
})
```

## External Dependencies

### Required CLI Tools
- `fzf` - Fuzzy finding for file selection
- `git` - Version control and file operations
- `bat` - Syntax highlighting for file previews
- `tmux` - Terminal multiplexer (optional but recommended)

### Language Servers (via Mason)
- `lua_ls` - Lua language server
- `ts_ls` - TypeScript/JavaScript
- `pyright` - Python
- `gopls` - Go
- `clangd` - C/C++
- `html`, `cssls`, `jsonls` - Web development

## Configuration Patterns

### Key Mapping
```lua
local map = vim.keymap.set
local opts = { noremap = true }

-- Simple mapping
map("n", "<leader>k", ":command<CR>", opts)

-- Function mapping
map("n", "<leader>d", function()
    require("utils").toggle_diagnostics()
end, opts)
```

### Floating Windows
```lua
local function create_float_window()
    local buf = vim.api.nvim_create_buf(false, true)
    return vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.95),
        height = math.floor(vim.o.lines * 0.95),
        border = "rounded",
    })
end
```

### Command Creation
```lua
vim.api.nvim_create_user_command("ToggleFullPath", function()
    vim.g.show_full_path = not vim.g.show_full_path
    vim.cmd("redrawstatus")
end, {})
```

### Autocommands
```lua
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = [[%s/\s\+$//e]],
})
```

## Common Operations

### File Operations
- Use `vim.fn.fnameescape()` for safe file paths
- Check file existence with `vim.fn.filereadable()`
- Use temporary files for external command output

### Buffer Management
- Get buffer list with `vim.fn.getbufinfo()`
- Switch buffers with `vim.cmd("buffer " .. bufnr)`
- Check buffer validity before operations

### Job Management
- Use `vim.fn.jobstart()` for async operations
- Clean up temporary files in job exit callbacks
- Schedule UI updates with `vim.schedule()`

## Debugging Tips

### Configuration Debugging
- Use `print()` for simple debugging
- Check `:lua =vim.something` for runtime values
- Use `:messages` to see printed output
- Enable verbose mode: `nvim -V2`

### LSP Debugging
- `:LspInfo` - Show active servers
- `:lua vim.lsp.get_active_clients()` - List clients
- Check diagnostics with `:lua =vim.diagnostic.get(0)`

## File Organization Best Practices

1. Keep core configuration in separate modules
2. Group related functionality in the same file
3. Use descriptive function names
4. Add error checking for external dependencies
5. Prefer vim API over shell commands when possible
6. Keep plugin configurations focused and minimal

This configuration prioritizes simplicity, performance, and maintainability while providing powerful functionality through external tool integration.