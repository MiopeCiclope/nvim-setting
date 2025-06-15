return {
	"mrcjkb/rustaceanvim",
	dependencies = { "nvim-dap" },
	version = "^6", -- Recommended
	lazy = false, -- This plugin is already lazy
	config = function()
		local install_path = "/Users/romulotone/.local/share/nvim/mason/packages/codelldb" -- Correct way to get the install path:
		local extension_path = install_path .. "/extension/"
		local codelldb_path = extension_path .. "adapter/codelldb"
		local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
		-- Linux alternative:
		-- local liblldb_path = extension_path .. "lldb/lib/liblldb.so"

		vim.g.rustaceanvim = {
			dap = {
				adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path),
			},
		}
	end,
}
