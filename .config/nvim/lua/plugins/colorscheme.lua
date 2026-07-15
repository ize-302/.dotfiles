vim.pack.add({ "https://github.com/folke/tokyonight.nvim" })

local ok, tokyonight = pcall(require, "tokyonight")
if not ok then
	return
end

tokyonight.setup({
	style = "night",
	transparent = false,
	terminal_colors = true,
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		sidebars = "dark",
		floats = "dark",
	},
})

vim.cmd.colorscheme("tokyonight")
