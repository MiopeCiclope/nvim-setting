local M = {}

local ns = vim.api.nvim_create_namespace("claude_review")

local function default_path()
	return "/tmp/nvim-review-" .. (vim.env.REPO_NAME or "default") .. ".json"
end

function M.clear()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		end
	end
end

function M.load(path)
	path = path or default_path()
	local lines = vim.fn.readfile(path)
	if vim.tbl_isempty(lines) then
		vim.notify("review: arquivo vazio ou inexistente: " .. path, vim.log.levels.WARN)
		return 0
	end
	local concerns = vim.json.decode(table.concat(lines, "\n"))
	M.clear()
	local cwd = vim.fn.getcwd()
	local qf = {}
	for _, c in ipairs(concerns) do
		local abs = c.file:sub(1, 1) == "/" and c.file or (cwd .. "/" .. c.file)
		local buf = vim.fn.bufadd(abs)
		vim.fn.bufload(buf)
		local last = vim.api.nvim_buf_line_count(buf)
		local row = math.max(0, math.min(c.line, last) - 1)
		vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
			virt_text = { { "  ▍ " .. c.message, "DiagnosticWarn" } },
			virt_text_pos = "eol",
		})
		qf[#qf + 1] = { filename = abs, lnum = c.line, text = c.message }
	end
	vim.fn.setqflist({}, "r", { title = "Claude Review", items = qf })
	vim.cmd("copen")
	return #concerns
end

vim.api.nvim_create_user_command("ClaudeReview", function()
	M.load()
end, {})

return M
