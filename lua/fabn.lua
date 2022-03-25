local M = {}
local parse_config = function(default, user_config)
	-- TODO make a better (recursive) config parser
	-- TODO deep copy the default config
	for k, v in pairs(user_config) do
		default[k] = v
	end
	return default
end
-- Modeled after and wrapping the packer startup function, with less functionality
-- The spec is a table of options in lua. The current support will be just the name and the config options
local setup_plugins = function(spec, use)
	for _, item in ipairs(spec) do
		local module_name = item.name
		local opts = item.opts
		-- TODO remove keyword arguments
		-- TODO Error Checking
		local use_registry = not string.find(module_name, "/")
		if use_registry then
			local plugin = require("fabn/" .. module_name)
			local default_opts = plugin.default_opts
			use({
				plugin.source,
				requires = plugin.dependencies(opts),
				config = function()
					plugin.setup(parse_config(default_opts, opts))
				end,
			})
		end
			-- TODO implement non-registry system

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
