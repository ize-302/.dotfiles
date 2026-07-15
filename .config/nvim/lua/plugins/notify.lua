-- Use snacks.nvim as the vim.notify handler
vim.notify = function(msg, level, opts)
	Snacks.notify(msg, vim.tbl_extend("force", opts or {}, { level = level }))
end

vim.keymap.set("n", "<leader>un", function()
	Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })
