local M = {}

local ns = vim.api.nvim_create_namespace("claude_review")

local state = { concern_files = {}, entries_all = {}, base = nil, only = false }

local function default_path()
	return "/tmp/nvim-review-" .. (vim.env.REPO_NAME or "default") .. ".json"
end

function M.detect_base()
	local out = vim.fn.system("git rev-parse --abbrev-ref origin/HEAD 2>/dev/null"):gsub("%s+", "")
	local base = out:gsub("^origin/", "")
	return "origin/" .. (base ~= "" and base or "master")
end

function M.clear()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		end
	end
end

function M.apply_concerns(concerns)
	M.clear()
	local files = {}
	local cwd = vim.fn.getcwd()
	for _, c in ipairs(concerns or {}) do
		files[c.file] = true
		local abs = c.file:sub(1, 1) == "/" and c.file or (cwd .. "/" .. c.file)
		local buf = vim.fn.bufadd(abs)
		vim.fn.bufload(buf)
		local last = vim.api.nvim_buf_line_count(buf)
		local row = math.max(0, math.min(c.line, last) - 1)
		vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
			virt_lines = { { { c.message, "DiagnosticWarn" } } },
			virt_lines_above = true,
		})
	end
	return files
end

local function mark_display(entries, concern_files)
	for _, e in ipairs(entries) do
		local path = e.right_path or e.left_path
		e._base_display = e._base_display or e.display
		if path and concern_files[path] then
			e.display = "● " .. e._base_display
		else
			e.display = "  " .. e._base_display
		end
	end
	return entries
end

local function filtered_entries()
	if not state.only then
		return state.entries_all
	end
	local out = {}
	for _, e in ipairs(state.entries_all) do
		local path = e.right_path or e.left_path
		if path and state.concern_files[path] then
			out[#out + 1] = e
		end
	end
	return out
end

local function resolve(e)
	return {
		left = e.left_path and { ref = state.base, path = e.left_path } or nil,
		right = e.right_path and { worktree = true, path = e.right_path } or nil,
	}
end

local function open_engine()
	local gd = require("gitdiff")
	local entries = mark_display(filtered_entries(), state.concern_files)
	gd.open({
		title = "Claude Review",
		entries = entries,
		resolve = resolve,
		actions = {
			{
				key = "t",
				desc = "toggle only concerns",
				fn = function()
					state.only = not state.only
					open_engine()
				end,
			},
		},
	})
end

function M.branch_review(base, concerns)
	state.base = base or M.detect_base()
	state.only = false
	state.entries_all = require("gitdiff").name_status_entries(state.base .. "...HEAD")
	if #state.entries_all == 0 then
		M.clear()
		vim.notify("review: sem arquivos na branch", vim.log.levels.INFO)
		return
	end
	state.concern_files = M.apply_concerns(concerns)
	open_engine()
end

function M.load(path)
	path = path or default_path()
	local lines = vim.fn.readfile(path)
	if vim.tbl_isempty(lines) then
		vim.notify("review: arquivo vazio ou inexistente: " .. path, vim.log.levels.WARN)
		return
	end
	local ok, data = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not ok then
		vim.notify("review: JSON inválido: " .. path, vim.log.levels.ERROR)
		return
	end
	M.branch_review(data.base, data.concerns or {})
end

vim.api.nvim_create_user_command("ClaudeReview", function()
	M.load()
end, {})

return M
