---@type Wezterm
local wezterm = require("wezterm")

local M = {}

function M.setup(opts)
  require("plugins.tabline.config").set(opts)

  wezterm.on("update-status", function(window)
    require("plugins.tabline.component").set_status(window)
  end)

  wezterm.on("format-tab-title", function(tab, _, _, _, hover, _)
    return require("plugins.tabline.tabs").set_title(tab, hover)
  end)

  require("plugins.tabline.extension").load()
end

function M.apply_to_config(config)
  config.use_fancy_tab_bar = false
  config.show_new_tab_button_in_tab_bar = false
  config.tab_max_width = 32
  config.window_decorations = "RESIZE"
  config.window_padding = config.window_padding or {}
  config.window_padding.left = 0
  config.window_padding.right = 0
  config.window_padding.top = 0
  config.window_padding.bottom = 0
  config.colors = config.colors or {}
  config.colors.tab_bar = config.colors.tab_bar or {}
  config.colors.tab_bar.background = require("plugins.tabline.config").theme.normal_mode.c.bg
  config.status_update_interval = 500
end

function M.toggle(window)
  local overrides = window:get_config_overrides() or {}

  if overrides.enable_tab_bar == false then
    overrides.enable_tab_bar = nil
  else
    overrides.enable_tab_bar = false
  end

  window:set_config_overrides(overrides)
end

function M.get_config()
  return require("plugins.tabline.config").opts
end

function M.get_theme()
  return require("plugins.tabline.config").theme
end

function M.set_theme(theme, overrides)
  return require("plugins.tabline.config").set_theme(theme, overrides)
end

function M.refresh(window, tab)
  if not M.get_config().enabled then
    wezterm.log_error("Tabline plugin is disabled; skipping refresh")
    return
  end
  wezterm.log_error("Tabline plugin is refreshing")
  if window then
    require("plugins.tabline.component").set_status(window)
  end
  if tab then
    require("plugins.tabline.tabs").set_title(tab)
  end
end

return M
