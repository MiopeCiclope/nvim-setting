return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	config = function()
		local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
		local workspace_dir = "/Users/romulotone/.local/share/jdtls-workspace/" .. project_name
		local config = {
			cmd = {
				"/Users/romulotone/.jenv/versions/21.0.4/bin/java",
				"-Declipse.application=org.eclipse.jdt.ls.core.id1",
				"-Dosgi.bundles.defaultStartLevel=4",
				"-Declipse.product=org.eclipse.jdt.ls.core.product",
				"-Dlog.protocol=true",
				"-Dlog.level=ALL",
				"--add-modules=ALL-SYSTEM",
				"--add-opens",
				"java.base/java.util=ALL-UNNAMED",
				"--add-opens",
				"java.base/java.lang=ALL-UNNAMED",
				"-jar",
				"/Users/romulotone/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250331-1702.jar",
				"-configuration",
				"/Users/romulotone/.local/share/nvim/mason/packages/jdtls/config_mac_arm",
				"-data",
				workspace_dir,
				"-Xmx12g",
				"-XX:ReservedCodeCacheSize=512m",
				"--XX:CICompilerCount=7",
			},

			root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),

			settings = {
				java = {},
			},

			init_options = {
				bundles = {},
			},
		}

		require("jdtls").start_or_attach(config)
	end,
}
