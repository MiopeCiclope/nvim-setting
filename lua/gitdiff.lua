local M = {}

function M._parse_name_status(lines)
	local entries = {}
	for _, line in ipairs(lines) do
		local parts = vim.split(line, "\t", { trimempty = true })
		if parts[2] then
			local st = parts[1]:sub(1, 1)
			if st == "R" or st == "C" then
				entries[#entries + 1] = {
					status = "R",
					left_path = parts[2],
					right_path = parts[3],
					display = string.format("R  %s → %s", parts[2], parts[3]),
				}
			elseif st == "A" then
				entries[#entries + 1] = {
					status = "A",
					left_path = nil,
					right_path = parts[2],
					display = string.format("A  %s", parts[2]),
				}
			elseif st == "D" then
				entries[#entries + 1] = {
					status = "D",
					left_path = parts[2],
					right_path = nil,
					display = string.format("D  %s", parts[2]),
				}
			else
				entries[#entries + 1] = {
					status = st,
					left_path = parts[2],
					right_path = parts[2],
					display = string.format("%s  %s", st, parts[2]),
				}
			end
		end
	end
	return entries
end

function M.name_status_entries(range)
	local root = vim.fn.system("git rev-parse --show-toplevel"):gsub("[\r\n]+$", "")
	local lines = vim.fn.systemlist(
		"git -C " .. vim.fn.shellescape(root) .. " diff --name-status -M " .. range
	)
	return M._parse_name_status(lines)
end

local state = nil

function _G.GitdiffQftf(info)
	local out = {}
	for i = info.start_idx, info.end_idx do
		out[#out + 1] = (state and state.entries[i] and state.entries[i].display) or ""
	end
	return out
end

local function layout_ok(qf_win)
	return state
		and state.left_win
		and state.right_win
		and state.left_win ~= state.right_win
		and state.left_win ~= qf_win
		and state.right_win ~= qf_win
		and vim.api.nvim_win_is_valid(state.left_win)
		and vim.api.nvim_win_is_valid(state.right_win)
end

local function build_layout(qf_win)
	local main
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if w ~= qf_win and vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= "qf" then
			main = w
			break
		end
	end
	if main then
		vim.api.nvim_set_current_win(main)
	else
		vim.cmd("aboveleft new")
		main = vim.api.nvim_get_current_win()
	end
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if w ~= main and w ~= qf_win and vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= "qf" then
			pcall(vim.api.nvim_win_close, w, false)
		end
	end
	vim.cmd("leftabove vnew")
	state.left_win = vim.api.nvim_get_current_win()
	state.right_win = main
end

local function resolve_side(side)
	if not side then
		local b = vim.api.nvim_create_buf(false, true)
		vim.bo[b].bufhidden = "wipe"
		return b, false, nil
	end
	if side.worktree then
		local abs = side.path:sub(1, 1) == "/" and side.path or (state.root .. "/" .. side.path)
		local b = vim.fn.bufadd(abs)
		vim.fn.bufload(b)
		return b, true, side.path
	end
	local b = vim.api.nvim_create_buf(false, true)
	vim.bo[b].bufhidden = "wipe"
	local lines = vim.fn.systemlist(
		"git -C " .. vim.fn.shellescape(state.root) .. " show " .. vim.fn.shellescape(side.ref .. ":" .. side.path)
	)
	if vim.v.shell_error ~= 0 then lines = {} end
	vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)
	vim.bo[b].modifiable = false
	pcall(vim.api.nvim_buf_set_name, b, side.ref .. ":" .. side.path)
	return b, false, side.path
end

local function set_side(win, buf, is_wt, path, wt_buf)
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_win_call(win, function()
		if vim.bo[buf].filetype == "" then
			local ft = (wt_buf and vim.bo[wt_buf].filetype ~= "" and vim.bo[wt_buf].filetype)
				or (path and vim.filetype.match({ filename = path }))
				or vim.filetype.match({ buf = buf })
			if ft then vim.bo[buf].filetype = ft end
		end
		if not is_wt then
			if wt_buf then
				for _, client in ipairs(vim.lsp.get_clients({ bufnr = wt_buf })) do
					pcall(vim.lsp.buf_attach_client, buf, client.id)
				end
			end
			pcall(vim.diagnostic.enable, false, { bufnr = buf })
		end
		vim.cmd("diffthis")
	end)
end

local function preview()
	if not state then return end
	local qf_win = vim.api.nvim_get_current_win()
	local entry = state.entries[vim.fn.line(".")]
	if not entry then return end
	local sides = state.resolve(entry)
	if not layout_ok(qf_win) then build_layout(qf_win) end
	vim.api.nvim_win_call(state.right_win, function() vim.cmd("diffoff") end)
	vim.api.nvim_win_call(state.left_win, function() vim.cmd("diffoff") end)
	local left_buf, left_wt, left_path = resolve_side(sides.left)
	local right_buf, right_wt, right_path = resolve_side(sides.right)
	local wt_buf = (right_wt and right_buf) or (left_wt and left_buf) or nil
	set_side(state.right_win, right_buf, right_wt, right_path, wt_buf)
	set_side(state.left_win, left_buf, left_wt, left_path, wt_buf)
	if vim.api.nvim_win_is_valid(qf_win) then
		vim.api.nvim_set_current_win(qf_win)
	end
end

local function preview_guarded()
	if not state or state.previewing then return end
	state.previewing = true
	pcall(preview)
	state.previewing = false
end

vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("GitdiffFollow", { clear = true }),
	callback = function()
		if state and vim.bo.filetype == "qf" and vim.fn.getqflist({ title = 0 }).title == state.title then
			preview_guarded()
		end
	end,
})

function M.open(opts)
	if #opts.entries == 0 then
		vim.notify("gitdiff: nada pra mostrar", vim.log.levels.INFO)
		return
	end
	state = {
		root = vim.fn.system("git rev-parse --show-toplevel"):gsub("[\r\n]+$", ""),
		title = opts.title,
		entries = opts.entries,
		resolve = opts.resolve,
		actions = opts.actions or {},
		previewing = false,
	}
	local qf = {}
	for i, e in ipairs(opts.entries) do
		qf[i] = { filename = "", lnum = 0, text = e.display }
	end
	vim.fn.setqflist({}, "r", { title = opts.title, items = qf, quickfixtextfunc = "v:lua.GitdiffQftf" })
	vim.cmd("copen")
	local qf_buf = vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win())
	for _, a in ipairs(state.actions) do
		vim.keymap.set("n", a.key, function()
			local entry = state.entries[vim.fn.line(".")]
			if entry then a.fn(entry) end
		end, { buffer = qf_buf, noremap = true })
	end
	preview_guarded()
end

return M
