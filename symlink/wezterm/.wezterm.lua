local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.initial_cols = 80
config.initial_rows = 25

config.color_scheme = 'BlulocoDark'

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
    })
  },
  {
    italic = false,
    intensity = "Bold",
    font = wezterm.font({
      family = "FiraCode Nerd Font",
      stretch = "Normal",
      weight = "Bold",
      style = "Normal",
    })
  },
}

config.font_size = 12.0
config.enable_wayland = true

config.hide_tab_bar_if_only_one_tab = true

return config
