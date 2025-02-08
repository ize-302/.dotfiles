-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  require '302.plugins.vim-sleuth',

  require '302.plugins.debug',
  require '302.plugins.indent_line',
  require '302.plugins.lint',
  require '302.plugins.autopairs',
  require '302.plugins.nvim-tree',
  require '302.plugins.gitsigns',
  require '302.plugins.which-key',
  require '302.plugins.telescope',

  -- LSP Plugins
  require '302.plugins.lazydev',
  require '302.plugins.nvim-lspconfig',
  require '302.plugins.conform',
  require '302.plugins.nvim-cmp',
  require '302.plugins.colorscheme',

  -- Highlight todo, notes, etc in comments
  require '302.plugins.todo-comments',

  require '302.plugins.mini',
  require '302.plugins.nvim-treesitter',
  require '302.plugins.markview',
  require '302.plugins.alpha-nvim',
  require '302.plugins.blame_line',
  require '302.plugins.lazygit',

  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
