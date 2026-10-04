vim.pack.add({
	{ src = "https://github.com/DaikyXendo/nvim-material-icon" },
	{ src = "https://github.com/akinsho/bufferline.nvim" },
})

require("nvim-web-devicons").setup()

require("bufferline").setup({
	options = {
		diagnostics = "nvim_lsp",
		always_show_bufferline = false,
		show_buffer_close_icons = false,
		show_close_icon = false,
		show_buffer_icons = true,
		offsets = {
			{
				filetype = "snacks_layout_box",
			},
		},
	},
	highlights = {
		buffer_selected = {
			italic = true,
			bold = true,
		},
	},
})
