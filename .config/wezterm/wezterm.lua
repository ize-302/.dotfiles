local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- automatically start a tmux session when wezterm is opened
config.default_prog = { "tmux" }

--leader
config.leader = { key = "Space", mods = "CTRL|SHIFT" }

-- This is where you actually apply your config choices
config.color_scheme = "Tokyo Night"

config.font = wezterm.font("JetBrainsMono NF Medium")
config.font_size = 11
config.tab_bar_at_bottom = true
config.max_fps = 120
config.window_padding = {
	top = 5,
	right = 5,
	bottom = 0,
	left = 10,
}

-- disabled wezterm's tab bar
config.enable_tab_bar = false

config.keys = {
	{ key = "Enter", mods = "ALT", action = wezterm.action.SendKey({ key = "b", mods = "CTRL" }) },
}

-- and finally, return the configuration to wezterm
return config
