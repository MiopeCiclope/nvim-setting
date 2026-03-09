local jdtls = require("jdtls")

-- 1. Calculate cores
local perf_cores = tonumber((vim.fn.system("sysctl -n hw.perflevel0.logicalcpu 2>/dev/null"):gsub("%s+", "")))
	or tonumber((vim.fn.system("sysctl -n hw.logicalcpu 2>/dev/null"):gsub("%s+", "")))
	or 4
local ci_count = math.max(2, perf_cores - 1)

-- 2. Root Dir & Workspace
local root_dir = jdtls.setup.find_root({ ".git", "gradlew", "mvnw" })
	or jdtls.setup.find_root({ "build.gradle", "pom.xml" })

-- 2. Fallback to CWD if still not found (prevents 'nil' errors)
root_dir = root_dir or vim.fn.getcwd()

local project_name = vim.fn.fnamemodify(root_dir, ":t")
local workspace_dir = "/Users/romulotone/.local/share/jdtls-workspace/" .. project_name

-- 3. Configuration
local config = {
	cmd = {
		"/Users/romulotone/.jenv/versions/21.0.9/bin/java",
		"-Xms4g",
		"-Xmx20g",
		"-XX:ReservedCodeCacheSize=512m",
		"-XX:CICompilerCount=" .. ci_count,
		"-XX:+UseG1GC",
		"-XX:G1HeapRegionSize=32m",
		"-XX:InitiatingHeapOccupancyPercent=25",
		"-XX:GCTimeRatio=4",
		"-XX:AdaptiveSizePolicyWeight=90",
		"-XX:+UseStringDeduplication",
		"-XX:+AlwaysPreTouch",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ERROR",
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
	},
	root_dir = root_dir,
	flags = {
		debounce_text_changes = 500,
		allow_incremental_sync = true,
	},

	settings = {
		java = {
			autobuild = { enabled = false },
			format = { enabled = false },
			completion = {
				maxResults = 30,
				importOrder = { "java", "javax", "org", "com", "" },
				guessMethodArguments = false,
			},
			import = {
				exclusions = {
					"**/.git/**",
					"**/target/**",
					"**/build/**",
					"**/.gradle/**",
					"**/generated/**",
					"**/generated-sources/**",
					"**/node_modules/**",
				},
			},
			eclipse = { downloadSources = true },
			maven = { downloadSources = true },
			signatureHelp = { enabled = false },
			references = { includeDecompiledSources = true },
		},
	},

	init_options = { bundles = {} },

	handlers = {
		["textDocument/publishDiagnostics"] = function() end,
	},

	on_attach = function(client, bufnr)
		local caps = client.server_capabilities
		for key, _ in pairs(caps) do
			if key:find("Provider") then
				caps[key] = false
			end
		end
		caps.completionProvider = nil
		caps.signatureHelpProvider = nil
		caps.textDocumentSync = nil

		-- 4. MANUALLY BIND HOVER ONLY
		vim.keymap.set("n", "<leader>h", function()
			print("fucking hoveer")
			local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
			client:request("textDocument/hover", params, function(err, result, ctx)
				if err or not result then
					return
				end
				vim.lsp.handlers["textDocument/hover"](err, result, ctx, { border = "rounded" })
			end, bufnr)
		end, { buffer = bufnr, desc = "JDTLS Hover ONLY" })
	end,
}

-- 4. Execute
-- jdtls.start_or_attach(config)
