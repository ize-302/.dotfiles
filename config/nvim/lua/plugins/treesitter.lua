vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

-- Run :TSUpdate manually after first install to fetch parsers
local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then return end

configs.setup({
	ensure_installed = {
		"bash", "go", "lua", "luadoc", "markdown", "markdown_inline",
		"typescript", "javascript", "json", "html", "css", "zig",
		"vim", "vimdoc", "tsx", "c", "java",
	},
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true },
})
