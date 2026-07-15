vim.pack.add({ "https://github.com/nvim-neotest/nvim-nio" })
vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })
vim.pack.add({ "https://github.com/rcarriga/nvim-dap-ui" })

local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Auto open/close dapui with debug session
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- Signs
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine" })

-- Go
dap.configurations.go = {
	{ type = "delve", name = "Debug file", request = "launch", program = "${file}" },
	{ type = "delve", name = "Debug package", request = "launch", program = "${workspaceFolder}" },
	{ type = "delve", name = "Attach to process", request = "attach", processId = require("dap.utils").pick_process },
}

-- JavaScript / TypeScript
local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"
dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "node",
		args = { js_debug_path .. "/js-debug/src/dapDebugServer.js", "${port}" },
	},
}
for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
	dap.configurations[lang] = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
			sourceMaps = true,
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach to process",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
			sourceMaps = true,
		},
	}
end

-- Java
dap.configurations.java = {
	{ type = "java", request = "attach", name = "Debug (Attach) - Remote", hostName = "127.0.0.1", port = 5005 },
}

-- Keymaps
vim.keymap.set("n", "<leader>db", function()
	dap.toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dc", function()
	dap.continue()
end, { desc = "Continue" })
vim.keymap.set("n", "<leader>di", function()
	dap.step_into()
end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>do", function()
	dap.step_over()
end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>dO", function()
	dap.step_out()
end, { desc = "Step Out" })
vim.keymap.set("n", "<leader>dr", function()
	dap.repl.open()
end, { desc = "Open REPL" })
vim.keymap.set("n", "<leader>dt", function()
	dap.terminate()
end, { desc = "Terminate" })
vim.keymap.set("n", "<leader>du", function()
	dapui.toggle()
end, { desc = "Toggle DAP UI" })
vim.keymap.set({ "n", "v" }, "<leader>de", function()
	dapui.eval()
end, { desc = "Eval" })
