return {
  { -- Autoformat
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
        lua = { "stylua" },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        javascript = { "biome", "prettierd", "prettier" },
        javascriptreact = { "biome", "prettierd" },
        typescript = { "biome", "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        css = { "prettier", "stylelint" },
        scss = { "prettierd", "stylelint" },
        json = { "biome", "prettierd", "prettier" },
        go = { "goimports", "gofmt", "prettier" },
        c = { "clang-format" },
        vue = { "biome", "prettierd", "prettier" },
        svelte = { "prettierd", "prettier" },
        html = { "biome", "prettierd", "prettier" },
      },
    },
  },
}
