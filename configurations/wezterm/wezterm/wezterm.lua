local wezterm = require("wezterm")
local vhs_era_theme = require("themes.vhs-era.wezterm")
local tmux = require("wezterm-tmux")
local font_settings = require("wezterm-fonts")
local keybinds = require("wezterm-keybinds")
local mouse = require("wezterm-mouse")
local utils = require("wezterm-utils")
local tabline = require("wezterm-tabline")

local config = wezterm.config_builder()

-- keybindings
config.leader = tmux.leader
config.keys = utils.merge_keys(tmux.keys, keybinds.keys)

-- mouse bindings
config.mouse_bindings = mouse.bindings

-- font settings
config.font = font_settings.font
config.font_rules = font_settings.font_rules
config.font_size = font_settings.font_size

-- apply vhs-era theme colors
config.colors = vhs_era_theme.colors
config.window_frame = vhs_era_theme.window_frame
config.inactive_pane_hsb = vhs_era_theme.inactive_pane_hsb

tabline.setup({
  options = {
    theme = vhs_era_theme.colors,
  },
  sections = {
    tabline_a = { "mode" },
    tabline_b = { "workspace" },
    tabline_c = { " " },
    tab_active = { "index", { "tab", padding = { left = 0, right = 1 } }, { "zoomed", padding = 0 } },
    tab_inactive = { "index", { "tab", padding = { left = 0, right = 1 } } },
    tabline_x = {},
    tabline_y = {},
    tabline_z = { "domain" },
  },
  extensions = {},
})

tabline.apply_to_config(config)

-- misc settings --
-- prevents crashes with scaling
config.enable_wayland = false
config.initial_cols = 80
config.initial_rows = 25

return config
