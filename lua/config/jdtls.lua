local function get_jdtls()
	-- Find the JDTLS package in the Mason Regsitry
	local jdtls_path = "/Users/romulotone/.local/share/nvim/mason/packages/jdtls" -- Correct way to get the install path:
	-- Obtain the path to the jar which runs the language server
	local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
	-- Declare white operating system we are using, windows use win, macos use mac
	local SYSTEM = "mac"
	-- Obtain the path to configuration files for your specific operating system
	local config = jdtls_path .. "/config_" .. SYSTEM
	-- Obtain the path to the Lomboc jar
	local lombok = jdtls_path .. "/lombok.jar"
	return launcher, config, lombok
end

local function get_workspace()
	-- Get the home directory of your operating system
	local home = os.getenv("HOME")
	-- Declare a directory where you would like to store project information
	local workspace_path = home .. "/code/workspace/"
	-- Determine the project name
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	-- Create the workspace directory by concatenating the designated workspace path and the project name
	local workspace_dir = workspace_path .. project_name
	return workspace_dir
end

local function setup_jdtls()
	-- Get access to the jdtls plugin and all of its functionality
	local jdtls = require("jdtls")

	-- Get the paths to the jdtls jar, operating specific configuration directory, and lombok jar
	local launcher, os_config, lombok = get_jdtls()

	-- Get the path you specified to hold project information
	local workspace_dir = get_workspace()

	-- Determine the root directory of the project by looking for these specific markers
	local root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })

	-- Tell our JDTLS language features it is capable of
	local capabilities = {
		workspace = {
			configuration = true,
		},
		textDocument = {
			completion = {
				snippetSupport = false,
			},
		},
	}

	local lsp_capabilities = require("blink.cmp").get_lsp_capabilities()
	for k, v in pairs(lsp_capabilities) do
		capabilities[k] = v
	end

	-- Get the default extended client capablities of the JDTLS language server
	local extendedClientCapabilities = jdtls.extendedClientCapabilities
	-- Modify one property called resolveAdditionalTextEditsSupport and set it to true
	extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

	-- Set the command that starts the JDTLS language server jar
	local cmd = {
		"java",
		"-Xmx12g",
		"-XX:ReservedCodeCacheSize=512m",
		"-XX:CICompilerCount=7", -- Limit JIT compiler threads (adjust based on CPU cores)
		"-jar",
		launcher,
		"-configuration",
		os_config,
		"-data",
		workspace_dir,
	}

	-- Configure settings in the JDTLS server
	local settings = {
		java = {
			configuration = {
				runtimes = {
					{
						name = "Java21",
						path = "/Library/Java/JavaVirtualMachines/jdk-21.jdk",
						default = true,
					},
				},
			},
			format = {
				enabled = true,
				settings = {
					url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
					profile = "GoogleStyle",
				},
			},
			references = {
				includeDecompiledSources = false,
			},
			implementationsCodeLens = {
				enabled = false,
			},
			imports = {
				exclusions = {
					"**/node_modules/**",
					"**/build/**",
					"**/target/**",
					"**/.metadata/**",
					"**/archetype-resources/**",
					"**/META-INF/**",
				},
			},
		},
	}

	local init_options = {
		extendedClientCapabilities = extendedClientCapabilities,
	}

	local on_attach = function(_, bufnr)
		require("jdtls.setup").add_commands()
		vim.lsp.codelens.refresh()

		-- Setup a function that automatically runs every time a java file is saved to refresh the code lens
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.java" },
			callback = function()
				local _, _ = pcall(vim.lsp.codelens.refresh)
			end,
		})
	end

	-- Create the configuration table for the start or attach function
	local config = {
		cmd = cmd,
		root_dir = root_dir,
		settings = settings,
		capabilities = capabilities,
		init_options = init_options,
		on_attach = on_attach,
	}

	-- Start the JDTLS server
	require("jdtls").start_or_attach(config)
end

return {
	setup_jdtls = setup_jdtls,
}
