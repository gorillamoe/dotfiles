local wezterm = require("wezterm")
local workspace_switcher = require("wezterm-workspace-switcher")

return {
  keys = {
    --  wezterm tab navigator
    {
      mods = "LEADER",
      key = "w",
      action = wezterm.action.ShowTabNavigator,
    },
    -- quit tabs
    {
      mods = "LEADER",
      key = "q",
      action = wezterm.action.CloseCurrentTab({ confirm = true }),
    },
    -- copy mode / vim mode
    {
      mods = "LEADER",
      key = "v",
      action = wezterm.action.ActivateCopyMode,
    },
    -- search
    {
      mods = "LEADER",
      key = "/",
      action = wezterm.action.Search({ CaseInSensitiveString = "" }),
    },
    -- reset font size
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    -- workspace switcher
    {
      mods = "CTRL",
      key = "k",
      action = workspace_switcher.switch_workspace(),
    },
    {
      mods = "LEADER|CTRL", -- use LEADER + CTRL + k to avoid conflict with CTRL + k in neovim
      key = "k",
      action = workspace_switcher.switch_workspace(),
    },
    -- fullscreen
    {
      mods = "LEADER",
      key = "o",
      action = wezterm.action.ToggleFullScreen,
    },
  },
}
