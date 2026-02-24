return {
  {
    "michaelrommel/nvim-silicon",
    lazy = true,
    cmd = "Silicon",
    main = "nvim-silicon",
    opts = {
      output = function()
        return "~/Pictures/" .. os.date("!%Y-%m-%dT%H-%M-%SZ") .. "_code.png"
      end,
      theme = "Dracula",
      background = nil,
      no_round_corner = true,
      pad_horiz = 0,
      pad_vert = 0,
      shadow_blur_radius = 0,
    },
  },
}
