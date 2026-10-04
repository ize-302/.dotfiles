-- Notify on project open
vim.api.nvim_create_autocmd("VimEnter", {
	desc = "Notify with project name on startup",
	callback = function()
		local project = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
		vim.notify("Now viewing " .. project .. " project", vim.log.levels.INFO, { title = "Project" })
	end,
})

-- LSP loading notifications
vim.lsp.config("*", {
	on_init = function(client)
		vim.notify(client.name .. " starting...", vim.log.levels.INFO, { title = "LSP" })
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Notify when LSP server is ready",
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client then
			vim.notify(client.name .. " ready", vim.log.levels.INFO, { title = "LSP" })
		end
	end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
