return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp", -- if you're on windows remove this line
		init = function()
			-- Patch the loader to skip specific files
			local original_lazy_load = require("luasnip.loaders.from_vscode").lazy_load
			require("luasnip.loaders.from_vscode").lazy_load = function(opts)
				opts = opts or {}
				opts.filter = function(file)
					return not file:match("react%-es7%.json") -- Blocks the file
				end
				original_lazy_load(opts)
			end
		end,
		dependencies = {
			"rafamadriz/friendly-snippets",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load({
					paths = { vim.fn.stdpath("config") .. "/snippets" },
				})

				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
	},
	{
		"saghen/blink.cmp",
		dependencies = { "Kurama622/llm.nvim" },
		version = "*",
		opts = {
			cmdline = {
				keymap = { preset = "inherit" },
				completion = {
					menu = {
						auto_show = function()
							local type = vim.fn.getcmdtype()
							if type == "/" or type == "?" then
								return { "buffer" }
							end
							if type == ":" or type == "@" then
								return { "cmdline" }
							end
							return {}
						end,
					},
				},
			},
			sources = {
				default = { "llm", "lsp", "path", "snippets", "buffer" },
				providers = {
					llm = {
						name = "llm",
						module = "llm.common.completion.frontends.blink",
						timeout_ms = 10000,
						score_offset = 100,
						async = true,
					},
				},
			},
			completion = {
				documentation = {
					window = {
						border = "single",
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:CursorLine,Search:NONE",
					},
				},
				ghost_text = { enabled = true, show_with_menu = false },
				menu = {
					auto_show = false,
					border = "single",
					winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:CursorLineBlink,Search:NONE,PmenuExtra:Pmenu",
					draw = {
						components = {
							kind_icon = {
								text = function(ctx)
									if ctx.item.kind_name == "llm" then
										return " "
									else
										return ctx.kind_icon
									end
								end,
								highlight = function(ctx)
									if ctx.item.kind_name == "llm" then
										return "BlinkCmpKindSnippet"
									else
										return ctx.kind_hl
									end
								end,
							},
						},
						columns = function(ctx)
							if ctx.mode == "cmdline" then
								return { { "label" } }
							else
								return { { "kind_icon" }, { "source_name" }, { "label", "label_description", gap = 1 } }
							end
						end,
					},
				},
			},
			keymap = {
				["<TAB>"] = {
					function(cmp)
						if cmp.snippet_active() then
							return cmp.accept()
						else
							return cmp.select_and_accept()
						end
					end,
					"snippet_forward",
					"fallback",
				},
			},
			signature = {
				enabled = true,
				window = {
					border = "single",
					winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:CursorLine,Search:NONE",
				},
			},
		},
	},
}
