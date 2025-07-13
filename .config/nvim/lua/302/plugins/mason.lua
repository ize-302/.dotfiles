return {
  {
    'williamboman/mason.nvim',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'neovim/nvim-lspconfig',
    },
    config = function()
      -- import mason
      local mason = require 'mason'

      -- import mason lspconfig
      local mason_lspconfig = require 'mason-lspconfig'

      -- import mason tool installer
      local mason_tool_installer = require 'mason-tool-installer'

      -- enable mason and configure icons
      mason.setup {
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
      }

      -- list of servers for mason to install
      mason_lspconfig.setup {
        ensure_installed = {
          'html',
          'biome',
          'cssls',
          'css_variables',
          'cssmodules_ls',
          'eslint',
          'lua_ls',
          'postgres_lsp',
          'pylsp',
          'rust_analyzer',
          'tailwindcss',
          'ts_ls',
          'vtsls',
          'zls',
        },
        automatic_installation = true,
      }

      mason_tool_installer.setup {
        ensure_installed = {
          'prettier',
          'prettierd',
          'stylua',
          'eslint_d',
          'biome',
          'stylelint',
          'markdownlint',
          'rustywind',
          'standardjs',
          'ts-standard',
          'eslint-lsp',
        },
      }
    end,
  },
}
