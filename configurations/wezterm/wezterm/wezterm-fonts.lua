local wezterm = require("wezterm")

local config = wezterm.config_builder()

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

config.font_size = 14.0

return config
