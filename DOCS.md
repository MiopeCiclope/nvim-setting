# Neovim Config — Human Reference

## Plugin List

| Plugin | Repo | Category |
|--------|------|----------|
| lazy.nvim | `folke/lazy.nvim` | Plugin manager |
| catppuccin | `catppuccin/nvim` | Colorscheme |
| harpoon | `ThePrimeagen/harpoon` | File navigation |
| vim-tmux-navigator | `christoomey/vim-tmux-navigator` | Pane navigation |
| diffview.nvim | `sindrets/diffview.nvim` | Git diff / merge |
| mason.nvim | `williamboman/mason.nvim` | LSP installer |
| mason-lspconfig.nvim | `williamboman/mason-lspconfig.nvim` | Mason/lspconfig bridge |
| nvim-lspconfig | `neovim/nvim-lspconfig` | LSP client config |
| nvim-treesitter | `nvim-treesitter/nvim-treesitter` | Syntax parsing |
| sqls.nvim | `nanotee/sqls.nvim` | SQL execution |
| blink.cmp | `saghen/blink.cmp` | Completion engine |
| LuaSnip | `L3MON4D3/LuaSnip` | Snippet engine |
| friendly-snippets | `rafamadriz/friendly-snippets` | Snippet collection |
| none-ls.nvim | `nvimtools/none-ls.nvim` | Formatter/linter bridge |
| none-ls-extras.nvim | `nvimtools/none-ls-extras.nvim` | Extra none-ls sources |
| kulala.nvim | `mistweaverco/kulala.nvim` | HTTP client |
| obsidian.nvim | `epwalsh/obsidian.nvim` | Markdown / notes |
| autotag | `MiopeCiclope/autotag` | HTML/JSX tag completion |
| blame.nvim | `FabijanZulj/blame.nvim` | Git blame overlay |
| trouble.nvim | `folke/trouble.nvim` | Diagnostics panel |
| plenary.nvim | `nvim-lua/plenary.nvim` | Lua utility library (dep) |

---

## How It Loads

On startup, `init.lua` bootstraps lazy.nvim if missing, then loads modules in order: `options` → `autocmds` → `keymaps` → `statusline` → `terminal` → `utils.setup_autopairs()` → all plugin specs in `lua/plugins/`.

---

## External Programs Required

| Program | Purpose |
|---------|---------|
| `fzf` | Fuzzy finder — powers the file picker, buffer switcher, and grep UI |
| `git` | Version control — used for file listing (`git ls-files`), grep (`git grep`), branch detection, and blame |
| `bat` | File previewer with syntax highlighting — used inside fzf preview panes |
| `ripgrep` (`rg`) | Fast recursive grep — recommended but optional, used via none-ls/eslint_d |
| `node` / `npm` | Required by Mason to install JS/TS language servers and eslint_d |
| `python3` | Required by Mason for pyright; also used in `swagger.lua` to pretty-print JSON via `json.dumps` |
| `curl` | Used by `swagger.lua` to fetch OpenAPI specs from running servers |
| `rustfmt` | Rust code formatter — called directly by none-ls |
| `stylua` | Lua code formatter — called by none-ls |
| `eslint_d` | JS/TS linter/formatter daemon — called by none-ls (faster than eslint) |
| `black` | Python code formatter — called by none-ls |
| `buf` | Protobuf linter and formatter — called by none-ls for `.proto` files |
| `jq` | JSON pretty-printer — used by kulala.nvim to format HTTP response bodies |
| `sqls` | SQL language server — provides completions and query execution for `.sql` files |
| `tmux` | Terminal multiplexer — optional, enables seamless pane navigation with vim-tmux-navigator |
| `ollama` | Local AI model server — serves deepseek-coder-v2 and qwen2.5-coder on `localhost:11434` for inline completions |

---

## Local Modules (`lua/`)

### `fzf.lua`
Custom fuzzy finder integration. Does **not** use Telescope. Spawns shell jobs via `vim.fn.jobstart()`, renders them in a floating terminal, writes selection to a temp file, then parses results on exit.

- `git_files()` — lists tracked + untracked files via `git ls-files`
- `buffers()` — fuzzy pick from open buffers
- `grep_search()` — prompts for a pattern, runs `git grep`, previews matches with bat
- Multi-select sends results to the quickfix list; single select opens the file directly
- `Ctrl-Q` inside fzf selects all results

### `utils.lua`
Shared helpers used by other modules.

- `check_dependencies()` — validates `fzf`, `git`, `bat` are in PATH
- `create_float_window(size)` — creates a centered floating window (default 95% of screen)
- `is_git_repo()` — detects if cwd is inside a git repo
- `get_open_buffers()` — returns list of listed buffer names
- `get_repo_relative_path()` / `get_full_path()` / `get_filename_only()` — path helpers used by clipboard commands
- `setup_autopairs()` — inserts basic autopair keymaps for `{`, `[`, `(`, `"`, `` ` ``

### `terminal.lua`
Opens a floating terminal window using `utils.create_float_window()`, then runs `terminal` + `startinsert`.

### `statusline.lua`
Custom statusline (no plugin). Shows: filename (togglable full path), modified flag, LSP diagnostics (errors/warnings/hints/info with icons), and cursor position. `:ToggleFullPath` switches between filename-only and full path.

### `autocmds.lua`
Auto-behaviors on file events:
- Center cursor on insert enter (`zz`)
- Strip trailing whitespace on save
- `:W` as alias for `:write`
- `:CopyFullPath`, `:CopyRepoPath`, `:CopyFileName` — copy path variants to system clipboard

### `keymaps.lua`
Global keymaps (non-plugin). Notable remaps:

| Key | Action |
|-----|--------|
| `t` | `$` (end of line) |
| `r` | `^` (first non-blank) |
| `w` | `b` (word backward) |
| `<C-p>` | FZF git files |
| `<Leader>b` | FZF buffers |
| `<Leader>z` | FZF grep |
| `<Leader>t` | Floating terminal |
| `<Leader>d` | Toggle diagnostics virtual text |
| `ö` / `ä` | Previous/next buffer (Swedish keyboard layout) |
| `<C-e>` | Close current buffer, move to next |
| `x` (visual) | Search within selection |

### `swagger.lua`
Fetches an OpenAPI/Swagger spec from a running server (tries `/v3/api-docs`, `/v2/api-docs`, etc.), generates a `.http` file with all endpoints grouped by tag, and creates/merges `http-client.env.json` with discovered variables. Used via `:SwaggerImport [base_url]` or `<Leader>ri` in `.http` files.

### `options.lua`
Core Neovim settings: 2-space tabs, relative+absolute line numbers, system clipboard, no swapfile, `conceallevel=2`, `scrolloff=16`, diagnostics virtual text off by default.

---

## Plugins

### UI & Colorscheme

**catppuccin** (`catppuccin/nvim`)
Colorscheme (mocha variant) with customized highlights: dark background (`#1c1c1c`), green float borders, orange completion highlights, custom cursor line color.

### File Navigation

**harpoon** (`ThePrimeagen/harpoon`, branch: harpoon2)
Branch-aware quick file bookmarks. Each git branch gets its own list. `<Leader>ha` adds current file, `<Leader>hh` opens the menu, `<Leader>1-5` jump to slots.

**vim-tmux-navigator** (`christoomey/vim-tmux-navigator`)
Allows `<C-h/j/k/l>` to move between Neovim splits and tmux panes seamlessly. Requires tmux to be running.

**diffview** (`sindrets/diffview.nvim`)
Git diff viewer with a 3-way merge layout (`diff3_mixed`) for conflict resolution.

### LSP & Language Support

**mason.nvim** (`williamboman/mason.nvim`)
GUI installer for LSP servers, formatters, and linters. Run `:Mason` to manage.

**nvim-lspconfig** (`neovim/nvim-lspconfig`)
Configured servers: `ts_ls`, `lua_ls`, `pyright`, `gopls`, `clangd`, `html`, `cssls`, `jsonls`, `omnisharp`, `tailwindcss`, `sqls`. Also connects to IntelliJ via IdeaLS TCP on port 8989 for Java/Kotlin.

Key LSP bindings:

| Key | Action |
|-----|--------|
| `<Leader>h` | Hover docs (dashed border) |
| `<Leader>g` | Go to definition |
| `<Leader>G` | Go to definition in vertical split |
| `<Leader>ca` | Code actions |
| `<Leader>p` | Format file (null-ls only) |
| `<Leader>L` | Toggle LSP debug logging |

**nvim-treesitter** (`nvim-treesitter/nvim-treesitter`)
Syntax tree parsing for: Rust, Lua, JS, TS, Java, Go, HTML, CSS, TSX, HTTP, SQL. Enables better highlighting, indentation, and structural editing.

**sqls.nvim** (`nanotee/sqls.nvim`)
SQL query execution inside Neovim. `<Leader>sq` in normal mode executes the statement under cursor via treesitter detection; visual `<Leader>sq` executes selection.

### Completion

**blink.cmp** (`saghen/blink.cmp`)
Completion engine. Sources in priority order: AI (llm.nvim) → LSP → path → snippets → buffer. Menu is hidden by default (ghost text shows inline). `<Tab>` confirms or jumps through snippet fields.

**LuaSnip** (`L3MON4D3/LuaSnip`)
Snippet engine. Loads VSCode-format snippets from `friendly-snippets` and your local `snippets/` directory. Blocks `react-es7.json` snippets explicitly.

**llm.nvim** (`Kurama622/llm.nvim`)
AI completion source for blink.cmp. Connects to local Ollama instance at `localhost:11434`. Completions appear in the menu as a separate source with a robot icon.

### Formatting & Linting

**none-ls** (`nvimtools/none-ls.nvim`)
Bridges external tools into the LSP format/diagnostic pipeline:
- **eslint_d** — JS/TS linting and formatting
- **rustfmt** — Rust formatting
- **stylua** — Lua formatting
- **black** — Python formatting
- **buf** — Protobuf linting and formatting

### HTTP / REST

**kulala.nvim** (`mistweaverco/kulala.nvim`)
HTTP client for `.http` files. `<Leader>rr` runs the request under cursor, response shown in a vertical split. Uses `jq` to pretty-print JSON responses.

**swagger.lua** (local)
Companion to kulala. `<Leader>ri` (or `:SwaggerImport`) fetches a live OpenAPI spec and generates `api-calls.http` + `http-client.env.json` with all endpoints and variables.

### Notes

**obsidian.nvim** (`epwalsh/obsidian.nvim`)
Markdown note-taking integrated with Obsidian vaults at `~/vault/Work` and `~/vault/Personal`. `<Leader>on` creates a new note, `<Leader>op` fuzzy-searches note content via the custom fzf integration, `<Leader>og` follows markdown links.

### Editing Helpers

**autotag** (`MiopeCiclope/autotag`)
Auto-closes and renames HTML/JSX tags in `.tsx`, `.jsx`, `.html` files.

**blame.nvim** (`FabijanZulj/blame.nvim`)
Git blame overlay. Run `:BlameToggle` to show inline git blame for every line.

**trouble.nvim** (`folke/trouble.nvim`)
Structured diagnostic and reference viewer.

| Key | Action |
|-----|--------|
| `<Leader>x` | Buffer diagnostics panel |
| `<Leader>r` | LSP references panel |
