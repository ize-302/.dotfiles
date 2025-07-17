-- Pull in the wezterm API
local wezterm = require("wezterm")

-- wezterm action
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- automatically start a zellij session when wezterm is opened
config.default_prog = { "zellij" }

--leader
config.leader = { key = "Space", mods = "CTRL|SHIFT" }

-- This is where you actually apply your config choices
config.color_scheme = "Tokyo Night"
config.font = wezterm.font("JetBrainsMono NF Medium")
config.font_size = 11
config.window_background_opacity = 1
config.tab_bar_at_bottom = true
config.max_fps = 120
config.window_padding = {
	top = 4,
	right = 4,
	bottom = 2,
	left = 4,
}

config.keys = {
	{ key = "Enter", mods = "ALT", action = wezterm.action.SendKey({ key = "b", mods = "CTRL" }) },
	-- -- tab management
	-- { key = "t", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
	-- { key = "w", mods = "ALT", action = act.CloseCurrentTab({ confirm = false }) },
	-- { key = "Tab", mods = "ALT", action = act.ActivateTabRelative(1) },
	-- { key = "Tab", mods = "ALT|SHIFT", action =act.ActivateTabRelative(-1) },
	--
	-- -- pane management
	-- { key = "v", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- { key = "h", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- { key = "q", mods = "ALT", action = act.CloseCurrentPane({ confirm = false }) },
	--
	-- -- pane navigation
	-- { key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	-- { key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	-- { key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	-- { key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },
}

-- and finally, return the configuration to wezterm
return config
