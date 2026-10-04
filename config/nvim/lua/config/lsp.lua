
-- Broadcast nvim-cmp capabilities to all LSP servers
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
vim.lsp.config("*", {
  capabilities = ok and cmp_nvim_lsp.default_capabilities() or nil,
})

-- Enable inlay hints on attach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})

-- Enable LSP servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("zls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("bashls")
vim.lsp.enable("clangd")
vim.lsp.enable("html")
vim.lsp.enable("markdown_oxide")
vim.lsp.enable("jdtls")

-- Diagnostic display
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
