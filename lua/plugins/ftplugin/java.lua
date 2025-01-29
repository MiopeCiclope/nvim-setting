local jdtls = require("jdtls")

local home = os.getenv("HOME")
local workspace_dir = home .. "/.cache/jdtls/workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
print("Workspace directory: " .. workspace_dir) -- Debugging line

local config = {
	cmd = {
		home .. "/.local/share/nvim/mason/bin/jdtls",
		"-data",
		workspace_dir,
		"--jvm-args",
		"-Xmx12g",
		"-XX:MaxMetaspaceSize=512m",
		"-XX:ReservedCodeCacheSize=512m",
		"-XX:CICompilerCount=7",
		"-Dfile.encoding=UTF-8",
	},
	root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]) or vim.fn.getcwd(),
	settings = {
		java = {
			format = { enabled = false },
			signatureHelp = { enabled = true },
			contentProvider = { preferred = "fernflower" },
			completion = {
				favoriteStaticMembers = {
					"org.junit.Assert.*",
					"org.mockito.Mockito.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.assertj.core.api.Assertions.*",
				},
				filteredTypes = { "com.sun.*", "java.awt.*", "jdk.internal.*" },
			},
		},
	},
	init_options = {
		bundles = {},
	},
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
}

-- Print to check the full command
print(vim.inspect(config.cmd)) -- Debugging line

jdtls.start_or_attach(config)
