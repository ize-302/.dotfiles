return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local lspconfig = require 'lspconfig'
      local telescope = require 'telescope.builtin'

      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc, mode)
          vim.keymap.set(mode or 'n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end

        map('gd', telescope.lsp_definitions, 'Goto Definition')
        map('gr', telescope.lsp_references, 'Goto References')
        map('gI', telescope.lsp_implementations, 'Goto Implementation')
        map('<leader>D', telescope.lsp_type_definitions, 'Type Definition')
        map('<leader>ds', telescope.lsp_document_symbols, 'Document Symbols')
        map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, 'Workspace Symbols')
        map('<leader>rn', vim.lsp.buf.rename, 'Rename')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
      end

      if vim.g.have_nerd_font then
        local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
        local diagnostic_signs = {}
        for type, icon in pairs(signs) do
          diagnostic_signs[vim.diagnostic.severity[type]] = icon
        end
        vim.diagnostic.config { signs = { text = diagnostic_signs } }
      end

      local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), { offsetEncoding = { 'utf-16' } })

      -- Setup your servers here

      -- vue language server
      local vue_language_server_path = vim.fn.expand '$MASON/packages' .. '/vue-language-server' .. '/node_modules/@vue/language-server'
      lspconfig.vtsls.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          -- typescript = {
          --   preferences = {
          --     importModuleSpecifier = 'non-relative',
          --     suggest = {
          --       completeFunctionCalls = true,
          --     },
          --     updateImportsOnFileMove = {
          --       enabled = 'always',
          --     },
          --   },
          -- },
          vtsls = {
            autoUseWorkspaceTsdk = true,
            tsserver = {
              globalPlugins = {
                {
                  name = '@vue/typescript-plugin',
                  location = vue_language_server_path,
                  languages = { 'vue' },
                  enableForWorkspaceTypeScriptVersions = true,
                  configNamespace = 'typescript',
                },
              },
            },
          },
        },
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
      }
    end,
  },
}
