local wezterm = require("wezterm")
local vhs_era_theme = require("themes.vhs-era.wezterm")
local tmux = require("wezterm-tmux")
local font_settings = require("wezterm-fonts")
local keybinds = require("wezterm-keybinds")
local utils = require("wezterm-utils")

local config = wezterm.config_builder()

-- show active workspace on the right status area
wezterm.on("update-right-status", function(window)
  window:set_right_status(window:active_workspace())
end)

-- keybindings
config.leader = tmux.leader
config.keys = utils.merge_keys(tmux.keys, keybinds.keys)

-- font settings
config.font = font_settings.font
config.font_rules = font_settings.font_rules
config.font_size = font_settings.font_size

-- apply vhs-era theme colors
config.colors = vhs_era_theme.colors
config.window_frame = vhs_era_theme.window_frame

-- misc settings
config.enable_wayland = true
config.initial_cols = 80
config.initial_rows = 25
config.hide_tab_bar_if_only_one_tab = true

return config
