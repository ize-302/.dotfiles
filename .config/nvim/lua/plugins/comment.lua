return {
  "numToStr/Comment.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    -- Disable default autocmd for ts_context_commentstring (we use Comment.nvim integration)
    require("ts_context_commentstring").setup({
      enable_autocmd = false,
    })
    require("Comment").setup({
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    })
  end,
}
