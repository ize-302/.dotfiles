-- A hackable Markdown, HTML, LaTeX, Typst & YAML previewer for Neovim.

return {
  {
    'OXY2DEV/markview.nvim',
    lazy = false,
    experimental = {
      check_rtp = false, -- disables the runtime path warning and fix
      -- OR, to just hide the message:
      -- check_rtp_message = false
    },
  },
}
