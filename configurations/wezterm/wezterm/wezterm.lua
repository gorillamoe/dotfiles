local wezterm = require("wezterm")
local vhs_era_theme = require("themes.vhs-era.wezterm")

local config = wezterm.config_builder()

--- Mimic tmux
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  -- splitting
  {
    mods = "LEADER",
    key = "-",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    mods = "LEADER",
    key = "|",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    mods = "LEADER",
    key = "z",
    action = wezterm.action.TogglePaneZoomState,
  },
  -- next pane
  {
    mods = "LEADER",
    key = "n",
    action = wezterm.action.ActivatePaneDirection("Next"),
  },
  -- previous pane
  {
    mods = "LEADER",
    key = "p",
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

config.initial_cols = 80
config.initial_rows = 25

config.color_scheme = "retro-theme"

config.font = wezterm.font_with_fallback({
  "FiraCode Nerd Font",
  "VictorMono Nerd Font",
  "Noto Color Emoji",
})

config.font_rules = {
  {
    italic = true,
    intensity = "Normal",
    font = wezterm.font({
      family = "VictorMono Nerd Font",
      stretch = "Normal",
      weight = "Regular",
      style = "Italic",
    }),
  },
  {
    italic = true,
    intensity = "Bold",
    font = wezterm.font({
      family = "VictorMono Nerd Font",
      stretch = "Normal",
      weight = "Bold",
      style = "Italic",
    }),
  },
  {
    italic = false,
    intensity = "Normal",
    font = wezterm.font({
      family = "FiraCode Nerd Font",
      stretch = "Normal",
      weight = "Regular",
      style = "Normal",
    }),
  },
  {
    italic = false,
    intensity = "Bold",
    font = wezterm.font({
      family = "FiraCode Nerd Font",
      stretch = "Normal",
      weight = "Bold",
      style = "Normal",
    }),
  },
}

-- apply vhs-era theme colors
config.colors = vhs_era_theme.colors
config.window_frame = vhs_era_theme.window_frame
config.color_scheme = vhs_era_theme.color_scheme

config.font_size = 14.0
config.enable_wayland = true

config.hide_tab_bar_if_only_one_tab = true

return config
