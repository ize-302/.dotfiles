vim.pack.add({ "https://github.com/ziontee113/icon-picker.nvim" })

require("icon-picker").setup({ disable_legacy_commands = true })

vim.keymap.set("n", "<Leader>ic", "<cmd>IconPickerNormal<cr>", { noremap = true, silent = true })
