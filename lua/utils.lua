local M = {}

-- Minimal helper for keymaps (optional, can be skipped if you use vim.keymap.set)
function M.map(mode, keys, command)
	vim.api.nvim_set_keymap(mode, keys, command, { noremap = true })
end

-- Toggle diagnostics
function M.toggle_diagnostics()
	local currentValue = vim.diagnostic.config().virtual_text
	vim.diagnostic.config({ virtual_text = not currentValue })
end

-- Simple autopair setup
function M.setup_autopairs()
	local function makeTagKeymap(char, completion)
		M.map("i", char, char .. completion .. "<Esc>ha")
	end

	local mappings = {
		["{"] = "}",
		["["] = "]",
		["("] = ")",
		['"'] = '"',
		["´"] = "´",
		["`"] = "`",
	}

	for char, completion in pairs(mappings) do
		makeTagKeymap(char, completion)
	end
end

-- Provide a :W command (write file)
vim.api.nvim_create_user_command("W", function()
	vim.cmd("write")
end, {})

function M.is_executable(cmd)
	return vim.fn.executable(cmd) == 1
end

function M.check_dependencies()
	local deps = { "fzf", "git", "bat" }
	local missing = {}

	for _, dep in ipairs(deps) do
		if not M.is_executable(dep) then
			table.insert(missing, dep)
		end
	end

	if #missing > 0 then
		print("Missing dependencies: " .. table.concat(missing, ", "))
		return false
	end
	return true
end

return M
