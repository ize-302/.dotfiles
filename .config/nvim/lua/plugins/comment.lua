vim.pack.add({ "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" })

require("ts_context_commentstring").setup({
	enable_autocmd = false,
})

-- Hook ts_context_commentstring into native Neovim gc commenting
local get_option = vim.filetype.get_option
vim.filetype.get_option = function(filetype, option)
	if option == "commentstring" then
		local cs = require("ts_context_commentstring.internal").calculate_commentstring()
		if cs then
			return cs
		end
	end
	return get_option(filetype, option)
end
