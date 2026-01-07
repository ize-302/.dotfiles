return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "bash",
      "go",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "typescript",
      "javascript",
      "json",
      "html",
      "css",
      "zig",
      "vim",
      "vimdoc",
      "tsx",
      "c",
    },
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    autopairs = {
      enable = true,
    },
  },
}
