local M = {}
M.source = "neovim/nvim-lspconfig"
M.version = "0.0.1"
M.default_opts = { use_code_action_menu = true, default_keybinds_with_which_key = true }
M.dependencies = function(opts)
	local dependencies = {}
	if opts.use_code_action_menu then
		table.insert(dependencies, "code_action_menu")
	end
	if opts.default_keybinds_with_which_key then
		table.insert(dependencies, "which-key")
	end
	return dependencies
end
M.setup = function(opts) end
return M
