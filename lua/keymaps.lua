local map = vim.keymap.set
local opts = { noremap = true }

-- Pane navigation
map("n", "<c-k>", ":wincmd k<CR>", opts)
map("n", "<c-j>", ":wincmd j<CR>", opts)
map("n", "<c-l>", ":wincmd l<CR>", opts)
map("n", "<c-h>", ":wincmd h<CR>", opts)

-- Buffer navigation (history-based, like browser back/forward)
map("n", "ö", function()
	require("buffer_history").back()
end, opts)
map("n", "ä", function()
	require("buffer_history").forward()
end, opts)
map("n", "<C-e>", ":bnext | bd #<CR>", opts)

-- Quick commands
map("n", "<C-a>", "ggVG", opts)
map("n", "<Leader>%", ":vsplit<CR>", opts)
map("n", '<Leader>"', ":split<CR>", opts)
map("n", "<Leader>l", "<Cmd>noh<CR>", opts)
map("n", "<C-x>", ":Explore<CR>", opts)

-- Movement remaps
map("i", "<C-v>", "<C-o>$", opts)
map("i", "<C-c>", "<C-o>0", opts)
map({ "n", "o", "v" }, "t", "$", opts)
map({ "n", "o", "v" }, "r", "^", opts)
map({ "n", "o", "v" }, "w", "b", opts)

-- Toggle diagnostics (from utils)
map("n", "<Leader>d", function()
	require("utils").toggle_diagnostics()
end, opts)

-- Search inside visual selection
map("x", "/", ":<C-u>/\\%V", opts)

-- fzf integration
map("n", "<C-p>", '<cmd>lua require("fzf_searches").git_files()<CR>', opts)
map("n", "<Leader>b", '<cmd>lua require("fzf_searches").buffers()<CR>', opts)
map("n", "<Leader>z", '<cmd>lua require("fzf_searches").grep_search()<CR>', opts)

map("n", "<Leader>c", "<cmd>CopyRepoPath<CR>", opts)

local function parse_file_log(lines)
	local entries = {}
	local current_sha, current_subject
	for _, line in ipairs(lines) do
		if line == "" then
			current_sha, current_subject = nil, nil
		elseif not current_sha then
			local sha, subject = line:match("^([0-9a-f]+)\t(.+)$")
			if sha then
				current_sha = sha
				current_subject = subject
			end
		else
			local parts = vim.split(line, "\t", { trimempty = true })
			local st = parts[1] and parts[1]:sub(1, 1)
			if st and parts[2] then
				local path
				if st == "R" or st == "C" then
					path = parts[3]
				else
					path = parts[2]
				end
				local left_path = (st == "R" or st == "C") and parts[2] or path
				entries[#entries + 1] = {
					sha = current_sha,
					subject = current_subject,
					path = path,
					left_path = left_path,
					display = current_sha:sub(1, 7) .. " " .. current_subject,
				}
				current_sha, current_subject = nil, nil
			end
		end
	end
	return entries
end

_G._test_parse_file_log = parse_file_log

map("n", "<Leader>u", function()
	local gd = require("gitdiff")

	local function git_run(root, args)
		local cmd = "git -C " .. vim.fn.shellescape(root) .. " " .. args
		local out = vim.fn.system(cmd)
		return out, vim.v.shell_error == 0
	end

	local function make_resolve()
		return function(e)
			return {
				left = e.left_path and { ref = "HEAD", path = e.left_path } or nil,
				right = e.right_path and { worktree = true, path = e.right_path } or nil,
			}
		end
	end

	local function make_actions(reload_fn)
		local root = vim.fn.system("git rev-parse --show-toplevel"):gsub("%s+", "")

		local function commit_action()
			local msg_buf = vim.api.nvim_create_buf(false, true)
			vim.bo[msg_buf].buftype = "acwrite"
			vim.bo[msg_buf].bufhidden = "wipe"
			vim.bo[msg_buf].swapfile = false
			vim.cmd("botright split")
			vim.api.nvim_win_set_buf(0, msg_buf)

			local function confirm_commit()
				local lines = vim.api.nvim_buf_get_lines(msg_buf, 0, -1, false)
				local trimmed = {}
				for _, l in ipairs(lines) do
					if l:match("%S") then trimmed[#trimmed + 1] = l end
				end
				if #trimmed == 0 then
					pcall(vim.api.nvim_buf_delete, msg_buf, { force = true })
					return
				end
				local tmpfile = vim.fn.tempname()
				vim.fn.writefile(lines, tmpfile)
				local out, ok = git_run(root, "commit -F " .. vim.fn.shellescape(tmpfile))
				vim.fn.delete(tmpfile)
				if not ok then
					vim.notify(out, vim.log.levels.ERROR)
					return
				end
				pcall(vim.api.nvim_buf_delete, msg_buf, { force = true })
				reload_fn()
			end

			vim.keymap.set("n", "<CR>", confirm_commit, { buffer = msg_buf, noremap = true })
			vim.keymap.set("n", "q", function()
				pcall(vim.api.nvim_buf_delete, msg_buf, { force = true })
			end, { buffer = msg_buf, noremap = true })
			vim.api.nvim_create_autocmd("BufWriteCmd", {
				buffer = msg_buf,
				callback = confirm_commit,
			})
		end

		return {
			{
				key = "-",
				fn = function(entry)
					local out, ok
					if entry.stage_state == "staged" then
						local path = entry.right_path or entry.left_path
						out, ok = git_run(root, "reset HEAD " .. vim.fn.shellescape(path))
					else
						local path = entry.right_path
						if path then
							out, ok = git_run(root, "add " .. vim.fn.shellescape(path))
						end
					end
					if ok == false then
						vim.notify(out, vim.log.levels.ERROR)
					end
					reload_fn()
				end,
			},
			{
				key = "cc",
				fn = function(_)
					commit_action()
				end,
			},
		}
	end

	local cursor_line = { 1 }

	local function reload()
		local new_entries = gd.status_entries()
		local line = math.min(cursor_line[1], math.max(1, #new_entries))
		gd.reload("Save Work", new_entries, make_resolve(), make_actions(reload))
		vim.fn.setpos(".", { 0, line, 1, 0 })
	end

	local entries = gd.status_entries()
	gd.open({
		title = "Save Work",
		entries = entries,
		resolve = make_resolve(),
		actions = make_actions(reload),
	})

	vim.api.nvim_create_autocmd("CursorMoved", {
		group = vim.api.nvim_create_augroup("SaveWorkCursor", { clear = true }),
		callback = function()
			if vim.bo.filetype == "qf" and vim.fn.getqflist({ title = 0 }).title == "Save Work" then
				cursor_line[1] = vim.fn.line(".")
			end
		end,
	})
end, opts)

-- Fechar diff e quickfix, sobrando só o arquivo de trabalho
map("n", "<Leader>q", function()
	vim.cmd("diffoff!")
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		-- fecha janelas não-normais: quickfix, scratch base (nofile)
		if vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "" then
			pcall(vim.api.nvim_win_close, win, false)
		end
	end
end, opts)

-- Quickfix navigation — j/k na própria lista já move e o diff segue
map("n", "<Leader>j", "<cmd>silent! cnext<CR>", opts)
map("n", "<Leader>k", "<cmd>silent! cprev<CR>", opts)

map("n", "<Leader>m", function()
	require("review").branch_review(nil, {})
end, opts)

map("n", "<Leader>å", function()
	require("review").clear()
end, opts)
