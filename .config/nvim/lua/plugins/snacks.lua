vim.pack.add({ "https://github.com/folke/snacks.nvim" })

require("snacks").setup({
	notifier = {
		enabled = true,
		timeout = 5000,
	},
	picker = {
		enabled = true,
		layout = {
			preset = "ivy",
			cycle = true,
		},
		win = {
			input = {
				keys = {
					["<Tab>"] = { "list_down", mode = { "i", "n" } },
					["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
				},
			},
			list = {
				keys = {
					["<Tab>"] = { "list_down", mode = { "n", "x" } },
					["<S-Tab>"] = { "list_up", mode = { "n", "x" } },
				},
			},
		},
	},
	lazygit = { enabled = true },
	styles = {
		notification = {
			wo = { wrap = true },
		},
	},
})

-- Debug globals
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		_G.dd = function(...)
			Snacks.debug.inspect(...)
		end
		_G.bt = function()
			Snacks.debug.backtrace()
		end
		vim._print = function(_, ...)
			dd(...)
		end
	end,
})

-- Buffers / delete
vim.keymap.set("n", "<leader><space>", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<C-x>", function()
	Snacks.bufdelete()
end, { desc = "Delete Buffer" })

-- Lazygit
vim.keymap.set("n", "<leader>lg", function()
	Snacks.lazygit.open()
end, { desc = "Lazygit" })

-- LSP navigation (using snacks picker for richer UI)
vim.keymap.set("n", "gd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Goto Definition" })
vim.keymap.set("n", "gr", function()
	Snacks.picker.lsp_references()
end, { nowait = true, desc = "References" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
vim.keymap.set("n", "gi", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Goto Implementation" })
vim.keymap.set("n", "gy", function()
	Snacks.picker.lsp_type_definitions()
end, { desc = "Goto Type Definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
vim.keymap.set("n", "<leader>ds", function()
	Snacks.picker.lsp_symbols()
end, { desc = "Document Symbols" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- Diagnostics
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev Diagnostic" })
