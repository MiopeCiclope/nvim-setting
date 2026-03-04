return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	config = function()
		local perf_cores = tonumber((vim.fn.system("sysctl -n hw.perflevel0.logicalcpu 2>/dev/null"):gsub("%s+", "")))
			or tonumber((vim.fn.system("sysctl -n hw.logicalcpu 2>/dev/null"):gsub("%s+", "")))
			or 4
		local ci_count = math.max(2, perf_cores - 1)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("jdtls_attach", { clear = true }),
			pattern = "java",
			callback = function()
				if vim.b.jdtls_attached then
					return
				end
				vim.b.jdtls_attached = true

				local root_dir = require("jdtls.setup").find_root({ "build.gradle.kts", "build.gradle", "pom.xml" })
					or require("jdtls.setup").find_root({ ".git", "gradlew" })
				local project_name = root_dir and vim.fn.fnamemodify(root_dir, ":t")
					or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
				local workspace_dir = "/Users/romulotone/.local/share/jdtls-workspace/" .. project_name

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
						-- Nuke ALL capabilities so jdtls never enters capability-based routing
						client.server_capabilities.completionProvider = nil
						client.server_capabilities.definitionProvider = false
						client.server_capabilities.typeDefinitionProvider = false
						client.server_capabilities.implementationProvider = false
						client.server_capabilities.referencesProvider = false
						client.server_capabilities.documentHighlightProvider = false
						client.server_capabilities.documentSymbolProvider = false
						client.server_capabilities.workspaceSymbolProvider = false
						client.server_capabilities.codeActionProvider = false
						client.server_capabilities.codeLensProvider = nil
						client.server_capabilities.documentFormattingProvider = false
						client.server_capabilities.documentRangeFormattingProvider = false
						client.server_capabilities.renameProvider = false
						client.server_capabilities.signatureHelpProvider = nil
						client.server_capabilities.inlayHintProvider = false
						client.server_capabilities.hoverProvider = false

						-- Call jdtls hover directly by client id, bypassing capability routing
						vim.keymap.set("n", "<leader>h", function()
							local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
							client:request("textDocument/hover", params, function(err, result, ctx)
								if err or not result or not result.contents then
									return
								end
								vim.lsp.handlers["textDocument/hover"](err, result, ctx, {
									border = {
										{ "┌", "FloatBorder" },
										{ "╌", "FloatBorder" },
										{ "┐", "FloatBorder" },
										{ "┆", "FloatBorder" },
										{ "┘", "FloatBorder" },
										{ "╌", "FloatBorder" },
										{ "└", "FloatBorder" },
										{ "┆", "FloatBorder" },
									},
								})
							end, bufnr)
						end, { buffer = bufnr, desc = "Java hover (jdtls)" })
					end,
				}

				require("jdtls").start_or_attach(config)
			end,
		})
	end,
}
