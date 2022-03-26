local M = {}
M.fabn_version = "0.0.1"
M.default_opts = {
	snippet_engine = "luasnip",
	enable_autopairs = true,
	lspkind = true,
	git = true,
	path = true,
	lsp = true,
}
M.vanilla_deps = function(opts)
	local dependencies = {}
	if opts.snippet_engine == "luasnip" then
		table.insert(dependencies, "luasnip")
	end
	if opts.lspkind then
		table.insert(dependencies, "lspkind")
	end
	if opts.git then
		table.insert(dependencies, "cmp-git")
	end
	if opts.path then
		table.insert(dependencies, "cmp-path")
	end
	if opts.lsp then
		table.insert(dependencies, "cmp-lsp")
	end
	return dependencies
end
-- Admittedly, more complicated plugins will be more difficult to handle due to their many and complicated plugin options. For now, I will base the configs off my config, leaving the rest as a TODO add full customization
M.setup = function(opts)
	local formatting = nil
	if opts.lspkind then
		local lspkind = require("lspkind")
		formatting = {
			format = lspkind.cmp_format({ mode = "symbol_text" }),
		}
	end
	local snippet = nil
	if opts.snippet_engine == "luasnip" then
		local luasnip = require("luasnip")
		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		}
		require("luasnip.loaders.from_snipmate").lazy_load()
	end
	local cmp = require("cmp")
	if opts.enable_autopairs then
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")

		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))

		-- add a lisp filetype (wrap my-function), FYI: Hardcoded = { "clojure", "clojurescript", "fennel", "janet" }
		cmp_autopairs.lisp[#cmp_autopairs.lisp + 1] = "racket"
	end
	local has_words_before = function()
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	end
	-- Set completeopt to have a better completion experience
	vim.o.completeopt = "menu,menuone,noselect"
	require("luasnip.loaders.from_vscode").lazy_load()
	cmp.setup({
		formatting = formatting,
		snippet = snippet,
		window = {
			completion = {
				border = "single",
			},
			documentation = {
				border = "single",
			},
		},
		mapping = {
			["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
			["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
			["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
			["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
			["<C-e>"] = cmp.mapping({
				i = cmp.mapping.abort(),
				c = cmp.mapping.close(),
			}),
			["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				elseif has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end, { "i", "s" }),

			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
			["<Up>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
		},
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" }, -- For luasnip users.
			{ name = "buffer" },
			{ name = "nvim_lsp_signature_help" },
			{ name = "path" },
			{ name = "nvim_lua" },
		}),
		menu = {
			buffer = "[Buffer]",
			nvim_lsp = "[LSP]",
			luasnip = "[LuaSnip]",
			nvim_lua = "[Lua]",
			latex_symbols = "[Latex]",
		},
	})
	if opts.git then
		require("cmp_git").setup()
		cmp.setup.filetype("gitcommit", {
			sources = cmp.config.sources({
				{ name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
			}, {
				{ name = "buffer" },
			}),
		})
	end
	cmp.setup.cmdline("/", {
		sources = {
			{ name = "buffer" },
		},
	})

	cmp.setup.cmdline(":", {
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{ name = "cmdline" },
		}),
	})
end
return M
