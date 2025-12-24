---@type Wezterm
local wezterm = require("wezterm")

---@type wezterm.Config
return {
  ---@type wezterm.MouseBinding[]
  mouse_bindings = {
    -- Ctrl + Shift + scroll up = increase font size
    -- INFO:
    -- Even if we don't use SHIFT here,
    -- WezTerm seems to require shift to be pressed along with CTRL
    {
      event = { Down = { streak = 1, button = { WheelUp = 1 } } },
      mods = "CTRL",
      action = wezterm.action.IncreaseFontSize,
    },
    -- Ctrl + Shift + scroll down = decrease font size
    -- INFO:
    -- Even if we don't use SHIFT here,
    -- WezTerm seems to require shift to be pressed along with CTRL
    {
      event = { Down = { streak = 1, button = { WheelDown = 1 } } },
      mods = "CTRL",
      action = wezterm.action.DecreaseFontSize,
    },
  },
}
