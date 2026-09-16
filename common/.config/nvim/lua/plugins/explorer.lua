vim.pack.add({ "https://github.com/nvim-tree/nvim-tree.lua" })

-- nvim-web-devicons is mocked by mini.icons (loaded in mini-icons.lua)

local WIDTH_RATIO = 0.4
local HEIGHT_RATIO = 0.8

require("nvim-tree").setup({
	on_attach = function(bufnr)
		require("nvim-tree.api").config.mappings.default_on_attach(bufnr)
		vim.keymap.del("n", "f", { buffer = bufnr })
		vim.keymap.del("n", "F", { buffer = bufnr })
		vim.keymap.del("n", "s", { buffer = bufnr })
	end,
	git = {
		ignore = false,
	},
	filters = { dotfiles = false },
	disable_netrw = true,
	hijack_cursor = true,
	sync_root_with_cwd = true,
	update_focused_file = {
		enable = true,
		update_root = false,
	},
	respect_buf_cwd = true,
	view = {
		preserve_window_proportions = true,
		float = {
			enable = true,
			open_win_config = function()
				local screen_w = vim.opt.columns:get()
				local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
				local window_w = math.floor(screen_w * WIDTH_RATIO)
				local window_h = math.floor(screen_h * HEIGHT_RATIO)
				local center_x = math.floor((screen_w - window_w) / 2)
				local center_y = math.floor((screen_h - window_h) / 2)
				return {
					border = "single",
					relative = "editor",
					row = center_y,
					col = center_x,
					width = window_w,
					height = window_h,
				}
			end,
		},
		width = function()
			return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
		end,
	},
	actions = {
		remove_file = {
			close_window = false,
		},
	},
	renderer = {
		root_folder_label = false,
		highlight_git = true,
		highlight_opened_files = "name",
		highlight_modified = "name",
		group_empty = true,
		indent_markers = { enable = true },
		icons = {
			glyphs = {
				default = "󰈚",
				folder = {
					default = "",
					empty = "",
					empty_open = "",
					open = "",
					symlink = "",
				},
				git = { unmerged = "" },
			},
		},
	},
})

-- nvim tree
vim.keymap.set("n", "<leader>tt", "<cmd>:NvimTreeToggle<cr>")
vim.keymap.set("n", "<leader>tf", "<cmd>NvimTreeFindFile<cr>", { desc = "Reveal current file in tree" })
