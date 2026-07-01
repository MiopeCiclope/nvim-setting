local M = {}

-- Collect diagnostics
function M.get_diagnostics()
	if not next(vim.lsp.get_clients({ bufnr = 0 })) then
		return ""
	end

	local severities = vim.diagnostic.severity
	local counts = {
		errors = #vim.diagnostic.get(0, { severity = severities.ERROR }),
		warnings = #vim.diagnostic.get(0, { severity = severities.WARN }),
		hints = #vim.diagnostic.get(0, { severity = severities.HINT }),
		info = #vim.diagnostic.get(0, { severity = severities.INFO }),
	}

	local diagnostics = ""
	if counts.errors > 0 then
		diagnostics = diagnostics .. "  " .. counts.errors
	end
	if counts.warnings > 0 then
		diagnostics = diagnostics .. "  " .. counts.warnings
	end
	if counts.hints > 0 then
		diagnostics = diagnostics .. " 󰌶 " .. counts.hints
	end
	if counts.info > 0 then
		diagnostics = diagnostics .. "  " .. counts.info
	end
	return diagnostics
end

vim.g.show_full_path = false
function M.get_dynamic_filename()
	return vim.g.show_full_path and vim.fn.expand("%:f") or vim.fn.expand("%:t")
end

vim.opt.statusline = table.concat({
	" %{v:lua.require'statusline'.get_dynamic_filename()}",
	" %m",
	" %{v:lua.require'statusline'.get_diagnostics()} ",
	" %=%=%l:%c ",
})

return M
