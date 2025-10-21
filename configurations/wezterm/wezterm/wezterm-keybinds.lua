local wezterm = require("wezterm")
local workspace_switcher = require("wezterm-workspace-switcher")

local config = {}

config.keys = {
  -- workspace switcher
  {
    mods = "LEADER|CTRL",
    key = "k",
    action = workspace_switcher.switch_workspace(),
  },
  -- fullscreen
  {
    mods = "LEADER|SHIFT",
    key = "F",
    action = wezterm.action.ToggleFullScreen,
  },
}

return { keys = config.keys }
