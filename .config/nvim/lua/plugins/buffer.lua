vim.pack.add({ 
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
	{src = "https://github.com/akinsho/bufferline.nvim"},
})

require("bufferline").setup({
	options = {
		diagnostics = "nvim_lsp",
		always_show_bufferline = false,
		offsets = {
 			{
        filetype = "snacks_layout_box",
      },
		}
	}
})
