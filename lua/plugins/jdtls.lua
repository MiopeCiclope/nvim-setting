return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	enable = false,
	config = function()
		local jdtls = require("jdtls")

		local home = vim.fn.expand("~")
		local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
		-- local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

		local workspace_dir = home .. "/.local/share/jdtls-workspace/" .. project_name

		local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
		local root_dir = require("jdtls.setup").find_root(root_markers)
		if not root_dir then
			print("⚠️ No valid Java project root found.")
			return
		end

		local config = {
			cmd = { "jdtls", "-data", workspace_dir },
			root_dir = root_dir,
			settings = {
				java = {
					configuration = {
						updateBuildConfiguration = "interactive", -- ask when needed
					},
					project = {
						referencedLibraries = {
							"build/libs/**/*.jar",
							"lib/**/*.jar",
						},
					},
				},
			},
			on_attach = function(client, bufnr)
				print("✅ JDTLS attached to buffer " .. bufnr)
				require("jdtls.setup").add_commands()
			end,
		}

		jdtls.start_or_attach(config)
	end,
}
