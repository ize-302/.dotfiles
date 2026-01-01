return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = false,
      formatters_by_ft = {
        javascript = { "biome", "prettierd", "prettier" },
        javascriptreact = { "biome", "prettierd" },
        typescript = { "biome", "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        css = { "prettier", "stylelint" },
        scss = { "prettierd", "stylelint" },
        json = { "biome", "prettierd", "prettier" },
        vue = { "biome", "prettierd", "prettier" },
        html = { "biome", "prettierd", "prettier" },
        cpp = { "clang-format" },
        lua = { "stylua" },
        zig = { "zigfmt" },
      },
      format_on_save = { timeout_ms = 500 },
    },
  },
}
