return {
  "mason-org/mason.nvim",
  cmd = "Mason",
  event = "VeryLazy",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "mason-org/mason-lspconfig.nvim",
  },
  build = ":MasonUpdate",
  ---@param opts MasonSettings | {ensure_installed: string[]}
  config = function(_, opts)
    local mason = require("mason")
    local mason_tool_installer = require("mason-tool-installer")
    local mason_lspconfig = require("mason-lspconfig")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- 1️⃣ Install tools & LSP binaries
    mason_tool_installer.setup({
      ensure_installed = {
        -- formatters
        "stylua",
        "eslint",
        -- lsp (mason package names)
        "lua-language-server",
        "zls",
        "typescript-language-server",
        "gopls",
        "bash-language-server",
        "clangd",
      },
      auto_update = false,
      run_on_start = true,
    })

    -- 2️⃣ Register LSPs with lspconfig
    mason_lspconfig.setup({
      ensure_installed = {
        "lua_ls",
        "zls",
        "ts_ls",
        "gopls",
        "bashls",
        "clangd",
      },
      automatic_installation = true,
    })
  end,
}
