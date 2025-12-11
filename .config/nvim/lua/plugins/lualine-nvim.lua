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
      lualine_b = { "branch" },
      lualine_c = { "filename" },
      lualine_x = { "diagnostics" },
      lualine_y = { "filetype" },
      lualine_z = {
        { "filetype", padding = { left = 0, right = 1 } },
        enabled = false,
      },
    },
  },
}
