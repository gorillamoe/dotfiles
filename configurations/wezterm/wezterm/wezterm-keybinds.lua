local wezterm = require("wezterm")
local workspace_switcher = require("wezterm-workspace-switcher")

return {
  keys = {
    -- reset font size
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    -- workspace switcher
    {
      mods = "CTRL",
      key = "k",
      action = workspace_switcher.switch_workspace(),
    },
    -- fullscreen
    {
      mods = "LEADER|SHIFT",
      key = "F",
      action = wezterm.action.ToggleFullScreen,
    },
  },
}
