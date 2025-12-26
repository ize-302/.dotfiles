-- set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Enable auto format
vim.g.lazyvim_eslint_auto_format = true

-- show number
vim.o.number = true

-- enable relative number
-- vim.o.relativenumber = true

-- remove extra space at the bottom
vim.opt.cmdheight = 0

-- hide the ~ symbol
vim.opt.fillchars = { eob = " " }

-- enable mouse mode, can be used for resizing split for example
vim.opt.mouse = "a"

-- sync clipboard between os and neovim
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

vim.opt.splitright = true
vim.opt.splitbelow = true

-- use termguicolors
vim.opt.termguicolors = true

-- keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- how many spaces per tab
vim.o.tabstop = 2

-- how many spaces per shift
vim.o.shiftwidth = 2

-- highlight line where cursor is
vim.o.cursorline = true

-- copy indentation from current line when creating new line
vim.o.autoindent = true

-- Enable persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.local/share/nvim/undo//")

-- Enable Treesitter-based code folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- Start with all folds open

-- set max length of text width
vim.opt.textwidth = 80
