local keymap = vim.keymap
keymap.set('n', '<leader>tlv', ':LiveServerToggle<CR>')

return {
  {
    'barrett-ruth/live-server.nvim',
    -- build = 'pnpm add -g live-server',
    cmd = { 'LiveServerStart', 'LiveServerStop', 'LiveServerToggle' },
    config = true,
  },
}
