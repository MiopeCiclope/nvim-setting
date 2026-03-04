return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	config = function()
		-- Detect performance cores: Apple Silicon exposes perflevel0, Intel falls back to logicalcpu
		local perf_cores = tonumber((vim.fn.system("sysctl -n hw.perflevel0.logicalcpu 2>/dev/null"):gsub("%s+", "")))
			or tonumber((vim.fn.system("sysctl -n hw.logicalcpu 2>/dev/null"):gsub("%s+", "")))
			or 4
		local ci_count = math.max(2, perf_cores - 1)

		-- Re-run start_or_attach for every Java buffer so that files opened via
		-- go-to-definition also get jdtls attached (the lazy.nvim config function
		-- only runs once, not per-buffer).
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = function()
				local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })
				local project_name = root_dir and vim.fn.fnamemodify(root_dir, ":t") or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
				local workspace_dir = "/Users/romulotone/.local/share/jdtls-workspace/" .. project_name

				local config = {
					cmd = {
						"/Users/romulotone/.jenv/versions/21.0.4/bin/java",

						-- JVM flags MUST come before -jar or they are passed to the launcher as args, not to the JVM
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

						-- Required Eclipse/OSGi args
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

							completion = {
								maxResults = 30,
								importOrder = { "java", "javax", "org", "com", "" },
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

							signatureHelp = { enabled = true },
							references = { includeDecompiledSources = true },
						},
					},

					init_options = {
						bundles = {},
					},
				}

				require("jdtls").start_or_attach(config)

				vim.api.nvim_buf_create_user_command(0, "JavaRename", function()
					vim.lsp.buf.rename()
				end, { desc = "Rename symbol across project" })

				vim.api.nvim_buf_create_user_command(0, "JavaImplementations", function()
					vim.lsp.buf.implementation()
				end, { desc = "Show all implementations of symbol" })
			end,
		})
	end,
}
