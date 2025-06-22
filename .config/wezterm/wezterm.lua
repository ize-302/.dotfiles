-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.color_scheme = "Tokyo Night"
config.font = wezterm.font("JetBrainsMono NF Medium")
config.font_size = 11
config.window_background_opacity = 1
config.tab_bar_at_bottom = true
config.max_fps = 120

-- and finally, return the configuration to wezterm
return config
