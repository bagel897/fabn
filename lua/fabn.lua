local M = {}
local parse_config = function(default, user_config)
	-- TODO make a better (recursive) config parser
	-- TODO deep copy the default config
	if user_config == nil then
		return default
	end
	for k, v in pairs(user_config) do
		default[k] = v
	end
	return default
end
-- Modeled after and wrapping the packer startup function, with less functionality
-- The spec is a table of options in lua. The current support will be just the name and the config options
local function setup_plugin(item, use)
	local module_name = item[1]
	local user_opts = item[2]
	-- TODO remove keyword arguments
	-- TODO Error Checking
	local use_registry = not string.find(module_name, "/")
	local plugin = require("fabn/" .. module_name)
	local source = plugin.source
	if source == nil then
		source = module_name
	end
	local default_opts = plugin.default_opts
	local opts = parse_config(default_opts, user_opts)
	local vanilla_deps = plugin.vanilla_deps == nil and {} or plugin.vanilla_deps(opts)
	local dependencies = plugin.dependencies == nil and {} or plugin.dependencies(opts)
	for _, dependency in ipairs(dependencies) do
		setup_plugin(dependency.name, dependency.config)
		-- TODO check if plugin is already installed
	end
	use({
		plugin.source,
		requires = vanilla_deps,
		config = function()
			plugin.setup(opts)
		end,
	})
	-- TODO implement non-registry system. This will require downloading the plugin beforehand
end
local setup_plugins = function(spec, use)
	for _, item in ipairs(spec) do
		setup_plugin(item, use)
	end
end
M.startup = function(spec)
	return require("packer").startup({
		function(use)
			setup_plugins(spec, use)
		end,
	})
end
return M
