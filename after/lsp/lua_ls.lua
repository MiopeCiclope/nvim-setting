return {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = { [vim.env.VIMRUNTIME] = true },
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
}
