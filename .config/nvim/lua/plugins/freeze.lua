return {
  "AlejandroSuero/freeze-code.nvim",
  config = function()
    require("freeze-code").setup({
      freeze_path = vim.fn.exepath("freeze"), -- where is freeze installed
      copy = true, -- copy after screenshot option
      open = false, -- open after screenshot option
      dir = vim.env.PWD, -- where is the image going to be saved "." as default
      freeze_config = { -- configuration options for `freeze` command
        output = "freeze.png",
        config = "base",
        theme = "tokyonight-night",
      },
    })
  end,
}
