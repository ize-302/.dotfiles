-- Use snacks.nvim as the vim.notify handler
local fallback_notify = vim.notify
vim.notify = function(msg, level, opts)
	if not _G.Snacks then
		fallback_notify(msg, level, opts)
		return
	end
	Snacks.notify(msg, vim.tbl_extend("force", opts or {}, { level = level }))
end

vim.keymap.set("n", "<leader>un", function()
	Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })
