local M = {}

local function make_resolve()
	return function(e)
		return {
			left = e.left_path and { ref = "HEAD", path = e.left_path } or nil,
			right = e.right_path and { worktree = true, path = e.right_path } or nil,
		}
	end
end

local function make_actions(reload_fn)
	local gd = require("git.diff")

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
			local out, ok = gd.run("commit -F " .. vim.fn.shellescape(tmpfile))
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
					out, ok = gd.run("reset HEAD " .. vim.fn.shellescape(path))
				else
					local path = entry.right_path
					if path then
						out, ok = gd.run("add " .. vim.fn.shellescape(path))
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

function M.open()
	local gd = require("git.diff")
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
end

return M
