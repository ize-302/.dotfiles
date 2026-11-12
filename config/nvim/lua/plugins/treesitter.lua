vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

-- nvim-treesitter `main` branch: no `configs` module; install parsers and
-- start highlighting per buffer. Needs the `tree-sitter` CLI to build parsers.
local ok, ts = pcall(require, "nvim-treesitter")
if not ok then return end

ts.install({
	"bash", "go", "lua", "luadoc", "markdown", "markdown_inline",
	"typescript", "javascript", "json", "html", "css", "zig",
	"vim", "vimdoc", "tsx", "c", "java",
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
	callback = function(args)
		if not pcall(vim.treesitter.start, args.buf) then return end
		vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
