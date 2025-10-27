local wezterm = require("wezterm")

local config = {}

--- Mimic tmux
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 5000 }
config.keys = {
  -- rename tab
  {
    mods = "LEADER",
    key = ",",
    action = wezterm.action.PromptInputLine({
      description = "Enter new tab name",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  -- splitting
  {
    mods = "LEADER",
    key = "-",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    mods = "LEADER|SHIFT",
    key = "|",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  -- close pane
  {
    mods = "LEADER",
    key = "x",
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },
  -- create a new tab
  {
    mods = "LEADER",
    key = "c",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },
  -- zoom
  {
    mods = "LEADER",
    key = "z",
    action = wezterm.action.TogglePaneZoomState,
  },
  -- next tab
  {
    mods = "LEADER",
    key = "n",
    action = wezterm.action.ActivateTabRelative(1),
  },
  -- previous tab
  {
    mods = "LEADER",
    key = "p",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  -- up pane
  {
    mods = "LEADER",
    key = "k",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },
  -- down pane
  {
    mods = "LEADER",
    key = "j",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },
  -- right pane
  {
    mods = "LEADER",
    key = "l",
    action = wezterm.action.ActivatePaneDirection("Next"),
  },
  -- left pane
  {
    mods = "LEADER",
    key = "h",
    action = wezterm.action.ActivatePaneDirection("Prev"),
  },
  {
    mods = "LEADER",
    key = "Space",
    action = wezterm.action.RotatePanes("Clockwise"),
  },
  -- show the pane selection mode, but have it swap the active and selected panes
  {
    mods = "LEADER",
    key = "0",
    action = wezterm.action.PaneSelect({
      mode = "SwapWithActive",
    }),
  },
  -- activate copy mode or vim mode
  {
    key = "Enter",
    mods = "LEADER",
    action = wezterm.action.ActivateCopyMode,
  },
}

return {
  leader = config.leader,
  keys = config.keys,
}
