local M = {}
M.version = "0.0.1"
M.default_opts = {}
M.setup = function(opts) require("which-key").setup(opts) end
return M
