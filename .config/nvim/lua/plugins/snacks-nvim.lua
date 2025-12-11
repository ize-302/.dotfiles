return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,

        header = [[
██╗   ██╗ █████╗ ██╗   ██╗██╗  ████████╗
██║   ██║██╔══██╗██║   ██║██║  ╚══██╔══╝
██║   ██║███████║██║   ██║██║     ██║   
╚██╗ ██╔╝██╔══██║██║   ██║██║     ██║   
 ╚████╔╝ ██║  ██║╚██████╔╝███████╗██║   
  ╚═══╝  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝   
                                             ]],
        keys = {},
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
  },
}
