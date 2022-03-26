local M = {}
-- This is a very complicated plugin and still a WIP to get running nicely.
M.fabn_version = "0.0.1"
M.default_opts = {
	adapters = { debugpy = true, codelldb = false, lldb = true },
	dap_ui = true,
	dap_virtual_text = true,
	load_launchjs = true,
}
M.keybinds = function(opts)
	local dap = require("dap")
	return {
		d = {
			name = "debug",
			n = { dap.step_over, "step over" },
			s = { dap.step_into, "step into" },
			o = { dap.step_out, "step out" },
			u = { dap.run_to_cursor, "run to cursor" },
			b = { dap.toggle_breakpoint, "breakpoint" },
			c = { dap.continue, "continue" },
			r = { dap.run_last, "run_last" },
			q = {
				function()
					dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				"conditional",
			},
			x = { dap.terminate, "terminate" },
			e = { require("dapui").close, "close" },
			p = { dap.pause, "pause" },
		},
	}, { prefix = "<leader>" }
end
M.vanilla_dependencies = function(opts)
	local dependencies = {}
	if opts.dap_ui then
		table.insert(dependencies, "rcarriga/nvim-dap-ui")
	end
	if opts.dap_virtual_text then
		table.insert(dependencies, "theHamsta/nvim-dap-virtual-text")
	end
	if opts.adapter.python then
		table.insert(dependencies, "mfussenegger/nvim-dap-python")
	end
	return dependencies
end
local setup_lldb = function()
	local dap = require("dap")
	dap.adapters.lldb = {

		type = "executable",
		command = "/usr/bin/lldb-vscode", -- adjust as needed
		name = "lldb",
		env = {
			LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES",
		},
	}
	dap.configurations.cpp = {
		{
			name = "Launch",
			type = "lldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			args = {},
			runInTerminal = false,
		},
		{
			-- If you get an "Operation not permitted" error using this, try disabling YAMA:
			--  echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
			name = "Attach to process",
			type = "lldb", -- Adjust this to match your adapter name (`dap.adapters.<name>`)
			request = "attach",
			pid = require("dap.utils").pick_process,
			args = {},
		},
	}
	dap.configurations.c = dap.configurations.c
end
-- TODO incorporate DAP install stuff
local setup_codelldb = function()
	-- Since codelldb requires the path of codelldb, I won't implement it until I can get native packages working. If someone wants to contribute a patching making it work, go for it.
	-- dap.adapters.codelldb = function(on_adapter)
	-- 	local stdout = vim.loop.new_pipe(false)
	-- 	local stderr = vim.loop.new_pipe(false)
	--
	-- 	local cmd = "/home/bageljr/Downloads/extension/adapter/codelldb"
	--
	-- 	local handle, pid_or_err
	-- 	local opts = {
	-- 		stdio = { nil, stdout, stderr },
	-- 		detached = true,
	-- 	}
	-- 	handle, pid_or_err = vim.loop.spawn(cmd, opts, function(code)
	-- 		stdout:close()
	-- 		stderr:close()
	-- 		handle:close()
	-- 		if code ~= 0 then
	-- 			print("codelldb exited with code", code)
	-- 		end
	-- 	end)
	-- 	assert(handle, "Error running codelldb: " .. tostring(pid_or_err))
	-- 	stdout:read_start(function(err, chunk)
	-- 		assert(not err, err)
	-- 		if chunk then
	-- 			local port = chunk:match("Listening on port (%d+)")
	-- 			if port then
	-- 				vim.schedule(function()
	-- 					on_adapter({
	-- 						type = "server",
	-- 						host = "127.0.0.1",
	-- 						port = port,
	-- 					})
	-- 				end)
	-- 			else
	-- 				vim.schedule(function()
	-- 					require("dap.repl").append(chunk)
	-- 				end)
	-- 			end
	-- 		end
	-- 	end)
	-- 	stderr:read_start(function(err, chunk)
	-- 		assert(not err, err)
	-- 		if chunk then
	-- 			vim.schedule(function()
	-- 				require("dap.repl").append(chunk)
	-- 			end)
	-- 		end
	-- 	end)
	-- end
end
-- TODO add debug adapters as native dependencies
M.setup = function(opts)
	local dap = require("dap")
	if opts.adapter.python then
		require("dap-python").setup("/usr/bin/python")
	end
	if opts.adapter.codelldb then
		setup_codelldb()
	end
	if opts.adapter.lldb then
		setup_lldb()
	end
	if opts.load_launchjs then
		require("dap.ext.vscode").load_launchjs()
	end
	if opts.dap_ui then
		-- TODO spin out into submodule
		local dapui = require("dapui")
		dapui.setup()
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end
	end
	if opts.dap_virtual_text then
		require("nvim-dap-virtual-text").setup()
	end
end
return M
