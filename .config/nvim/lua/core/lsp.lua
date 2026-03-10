-- Set up LSP capabilities and enable servers after plugins load
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.lsp.config("*", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    -- Toggle inlay hints in Neovim
    vim.lsp.inlay_hint.enable(true)

    vim.lsp.enable("lua_ls")
    vim.lsp.enable("zls")
    vim.lsp.enable("ts_ls")
    vim.lsp.enable("gopls")
    vim.lsp.enable("bashls")
    vim.lsp.enable("clangd")
    vim.lsp.enable("html")
    vim.lsp.enable("markdown_oxide")
    -- vim.lsp.enable("jdtls")
  end,
})

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
    },
  },
})
