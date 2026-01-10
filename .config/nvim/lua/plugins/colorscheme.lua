return {
  "folke/tokyonight.nvim",
  lazy = false,
  opts = {
    style = "night",
  },
  priority = 1000,
  config = function()
    -- set the colorscheme
    vim.cmd.colorscheme("tokyonight-night")
    -- enable true color support in terminal (often necessary)
    vim.o.termguicolors = true
  end,
}
