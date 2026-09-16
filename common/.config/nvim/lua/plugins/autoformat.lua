vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
	notify_on_error = false,
	formatters_by_ft = {
		javascript = { "biome", "prettierd", "prettier" },
		javascriptreact = { "biome", "prettierd" },
		typescript = { "biome", "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
		css = { "prettier", "stylelint" },
		scss = { "prettierd", "stylelint" },
		json = { "biome", "prettierd", "prettier" },
		vue = { "biome", "prettierd", "prettier" },
		html = { "biome", "prettierd", "prettier" },
		cpp = { "clang-format" },
		c = { "clang_format" },
		lua = { "stylua" },
		zig = { "zigfmt" },
		markdown = { "prettier" },
		go = { "goimports", "gofumpt" },
		java = { "google-java-format", "spotless" },
		php = { "php-cs-fixer" },
	},
	format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
})

vim.keymap.set("", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })
