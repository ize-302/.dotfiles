# Neovim Configuration

A modern Neovim configuration built for Neovim 0.11+ using the native LSP API.

## Requirements

- Neovim >= 0.11
- Git
- A Nerd Font (for icons)
- Node.js (for some LSP servers)
- Go, Zig, etc. (for respective language support)

## Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lsp/                     # LSP server configurations (native 0.11 API)
│   ├── bashls.lua
│   ├── gopls.lua
│   ├── lua_ls.lua
│   ├── ts_ls.lua
│   └── zls.lua
└── lua/
    ├── config/
    │   ├── autocmds.lua     # Autocommands
    │   ├── keymaps.lua      # Global keymaps
    │   └── options.lua      # Neovim options
    ├── core/
    │   ├── lazy.lua         # Plugin manager setup
    │   └── lsp.lua          # LSP configuration and diagnostics
    └── plugins/             # Plugin specifications
        ├── autocomplete.lua
        ├── autopairs.lua
        ├── autoformat.lua
        ├── colorscheme.lua
        ├── comment.lua
        ├── explorer.lua
        ├── gitsigns.lua
        ├── mason.lua
        ├── snacks.lua
        ├── treesitter.lua
        └── ...
```

## Features

### LSP (Language Server Protocol)

Uses Neovim 0.11's native LSP API (`vim.lsp.enable()`). Configured servers:

| Server | Language |
|--------|----------|
| `lua_ls` | Lua |
| `ts_ls` | TypeScript / JavaScript |
| `gopls` | Go |
| `zls` | Zig |
| `bashls` | Bash / Shell |

Servers are automatically installed via Mason.

### Completion

Powered by `nvim-cmp` with the following sources:

- LSP completions
- Buffer words
- File paths

| Keymap | Action |
|--------|--------|
| `<Tab>` | Next completion item |
| `<S-Tab>` | Previous completion item |
| `<CR>` | Confirm selection |
| `<C-Space>` | Trigger completion |

### LSP Keymaps

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find references |
| `gi` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>ds` | Document symbols |
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |
| `<leader>d` | Diagnostics list |

### Treesitter

Provides enhanced syntax highlighting, indentation, and code parsing for:

- Lua, Go, Zig, TypeScript, JavaScript, TSX
- Bash, JSON, HTML, CSS, Markdown
- Vim, Vimdoc

### Formatting

Auto-format on save using `conform.nvim`. Configured formatters:

| Language | Formatter |
|----------|-----------|
| Lua | stylua |
| TypeScript/JavaScript | biome, prettierd, prettier |
| CSS/SCSS | prettier, stylelint |
| JSON | biome, prettierd, prettier |
| HTML | biome, prettierd, prettier |

### Autopairs

Automatically closes brackets, quotes, and parentheses. Integrates with nvim-cmp to add `()` after completing a function.

### Comments

Context-aware commenting using `Comment.nvim` with Treesitter integration. Works correctly in TSX files (uses `{/* */}` in JSX, `//` in TypeScript).

| Keymap | Action |
|--------|--------|
| `gcc` | Toggle comment (line) |
| `gc` + motion | Comment with motion |
| `gbc` | Toggle block comment |
| Visual + `gc` | Comment selection |

### File Navigation (Snacks.nvim)

| Keymap | Action |
|--------|--------|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader><space>` | Open buffers |
| `<leader>sr` | Recent files |
| `<C-x>` | Delete buffer |

### Git

| Keymap | Action |
|--------|--------|
| `<leader>lg` | Open Lazygit |

Git signs in the gutter via `gitsigns.nvim`.

### Other Keymaps

| Keymap | Action |
|--------|--------|
| `<leader>tt` | Toggle file explorer |
| `<leader>cm` | Open Mason |
| `<leader>f` | Format buffer |
| `<Esc>` | Clear search highlights |
| `<C-h/j/k/l>` | Navigate splits |

## Plugin Manager

Uses [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management with lazy-loading for optimal startup time.

## Installation

1. Backup your existing Neovim configuration
2. Clone this configuration to `~/.config/nvim`
3. Start Neovim - plugins will be installed automatically
4. Run `:Mason` to verify LSP servers are installed

## Customization

- **Add LSP servers**: Create a new file in `lsp/` directory and add `vim.lsp.enable("server_name")` to `lua/core/lsp.lua`
- **Add plugins**: Create a new file in `lua/plugins/` directory
- **Modify keymaps**: Edit `lua/config/keymaps.lua` or plugin-specific files
- **Change options**: Edit `lua/config/options.lua`
