return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      component_separators = "",
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = {
        {
          "mode",
          fmt = function(res)
            return res:sub(1, 1)
          end,
          separator = { left = "" },
          right_padding = 2,
        },
      },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { "filename" },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = {
        { "progress", separator = "", padding = { left = 1, right = 1 } },
      },
      lualine_z = {
        { "location", padding = { left = 0, right = 1 } },
      },
    },
  },
}
