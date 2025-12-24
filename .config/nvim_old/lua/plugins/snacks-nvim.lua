return {
  "folke/snacks.nvim",
  opts = {
    explorer = { enabled = false },
    dashboard = {
      sections = {
        {
          header = [[
██╗   ██╗ █████╗ ██╗   ██╗██╗  ████████╗
██║   ██║██╔══██╗██║   ██║██║  ╚══██╔══╝
██║   ██║███████║██║   ██║██║     ██║   
╚██╗ ██╔╝██╔══██║██║   ██║██║     ██║   
 ╚████╔╝ ██║  ██║╚██████╔╝███████╗██║   
  ╚═══╝  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝   
                                        
]],
          footer = [[]], -- Set the footer to an empty string
          padding = 0, -- Optional: Adjust padding if needed
          align = "center", -- Optional: Alignment setting
        },
      },
    },
    scroll = {
      configure = true,
    },

    lazygit = {
      configure = true,
      config = {
        os = {
          editPreset = "nvim-remote",
        },
        gui = {
          nerdFontsVersion = "3", -- Set to "" to disable icons
        },
      },
    },
    -- Optional: Customize the appearance of the floating window
    styles = {
      lazygit = {
        -- Example for a floating window
        position = "float",
        size = {
          width = 0.8, -- 90% of screen width
          height = 0.8, -- 90% of screen height
        },
      },
    },
    picker = {
      layout = "ivy",
      win = {
        input = {
          keys = {
            ["<a-p>"] = { "focus_preview", mode = { "n", "x" } },
          },
        },
      },
    },
  },
  keys = {
    { "<leader>fe", false },
    { "<leader>fE", false },
    { "<leader>E", false },
    { "<leader>e", false },
  },
}
