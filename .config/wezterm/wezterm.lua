-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.color_scheme = "Tokyo Night"
config.font = wezterm.font("JetBrainsMono NF Medium")
config.font_size = 10.5
config.window_background_opacity = 0.9
config.tab_bar_at_bottom = true
config.max_fps = 120

-- and finally, return the configuration to wezterm
return config
