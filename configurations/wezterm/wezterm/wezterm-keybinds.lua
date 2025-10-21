local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.keys = {
  -- fullscreen
  {
    mods = "LEADER|SHIFT",
    key = "F",
    action = wezterm.action.ToggleFullScreen,
  },
}

return config
