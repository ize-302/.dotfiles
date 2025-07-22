return {
  -- Highlight, edit, and navigate code
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  main = "nvim-treesitter.configs", -- Sets main module to use for opts
  dependencies = { "OXY2DEV/markview.nvim" },
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  opts = function(_, opts)
    -- add tsx and treesitter
    vim.list_extend(opts.ensure_installed, {
      "tsx",
      "typescript",
      "zig",
      "vue",
      "css",
    })
  end,
}
