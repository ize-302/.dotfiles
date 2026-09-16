vim.pack.add({ "https://github.com/mason-org/mason.nvim" })
vim.pack.add({ "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" })
vim.pack.add({ "https://github.com/jay-babu/mason-nvim-dap.nvim" })

require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

require("mason-tool-installer").setup({
	ensure_installed = {
		-- formatters
		"stylua",
		"eslint-lsp",
		-- lsp binaries
		"lua-language-server",
		"zls",
		"typescript-language-server",
		"gopls",
		"bash-language-server",
		"clangd",
		"html-lsp",
		"markdown-oxide",
		"jdtls",
		-- debuggers
		"js-debug-adapter",
		"delve",
	},
	auto_update = false,
	run_on_start = true,
})

require("mason-nvim-dap").setup({
	ensure_installed = { "python", "delve" },
	automatic_installation = true,
})
