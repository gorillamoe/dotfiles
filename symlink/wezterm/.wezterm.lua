local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'BlulocoDark'
config.font = wezterm.font_with_fallback({
  "Fira Code Nerd Font",
  "Noto Color Emoji",
})


config.font_size = 12.0
config.enable_wayland = true

config.hide_tab_bar_if_only_one_tab = true

return config
