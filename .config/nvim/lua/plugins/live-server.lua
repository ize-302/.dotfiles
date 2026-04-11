vim.pack.add({ "https://github.com/ngtuonghy/live-server-nvim" })

-- Run :LiveServerInstall once after adding this plugin
require("live-server-nvim").setup({
	custom = {
		"--port=8080",
		"--no-css-inject",
	},
})
