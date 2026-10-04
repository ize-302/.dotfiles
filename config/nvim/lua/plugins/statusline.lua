vim.pack.add({
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
})

require("lualine").setup({
 	options = {
		component_separators = "",
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = {
			{
				"mode",
				fmt = function(res)
					return res:sub(1, 1)
				end,
				separator = { left = "" },
				right_padding = 2,
			},
		},
		lualine_b = { "branch" },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "location", "diagnostics" },
		lualine_y = { "filetype" },
		lualine_z = {
			{
				function()
					return "🌊"
				end,
				padding = { left = 1, right = 1 },
			},
		},
	},
})
