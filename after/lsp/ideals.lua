local function is_listening()
	local out = vim.fn.system("lsof -nP -i tcp:8989 -sTCP:LISTEN 2>/dev/null")
	return out ~= ""
end

local function ideals_cmd(dispatchers)
	if not is_listening() then
		vim.notify("Starting IntelliJ LSP server (headless)...", vim.log.levels.INFO)
		vim.fn.jobstart({
			vim.fn.expand("~/Applications/IntelliJ IDEA.app/Contents/MacOS/idea"),
			"lsp-server",
			"tcp",
			"8989",
		}, {
			detach = true,
			env = {
				_JAVA_OPTIONS = "-Djava.awt.headless=true -Dapple.awt.UIElement=true",
			},
		})

		local ok = vim.fn.wait(30000, is_listening, 500)
		if ok ~= 0 then
			vim.notify("IntelliJ LSP server did not start in time", vim.log.levels.ERROR)
			return
		end
		vim.notify("IntelliJ LSP server ready, connecting...", vim.log.levels.INFO)
	end

	return vim.lsp.rpc.connect("127.0.0.1", 8989)(dispatchers)
end

return {
	cmd = ideals_cmd,
	filetypes = { "java", "kotlin" },
	root_markers = { ".idea" },
	capabilities = vim.tbl_deep_extend(
		"force",
		vim.lsp.protocol.make_client_capabilities(),
		require("blink.cmp").get_lsp_capabilities()
	),
	on_attach = function()
		vim.notify("Connected to IntelliJ (IdeaLS)", vim.log.levels.INFO)
	end,
}
