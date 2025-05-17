-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
-- [[ Global settings ]]
require 'globals'

-- [[ Setting options ]]
require 'options'

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
require 'keymaps'

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
require 'autocmds'

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
