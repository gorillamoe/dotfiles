---@type Wezterm
local wezterm = require("wezterm")

---@type WeztermConfig
local font_settings = require("user_config.wezterm-user_config_fonts")
---@type WeztermConfig
local user_config_keys = require("user_config.wezterm-user_config_keys")
---@type WeztermConfig
local user_config_mouse = require("user_config.wezterm-user_config_mouse")
---@type WeztermConfig
local user_config_tmux_like = require("user_config.wezterm-user_config_tmux_like")
local user_tabline = require("plugins.tabline")
local user_utils = require("user_config.wezterm-user_utils")
---@type WeztermConfig
local vhs_era_theme = require("themes.vhs-era.wezterm")

---@type wezterm.Config
local config = wezterm.config_builder()

-- keybindings
config.leader = user_config_tmux_like.leader
config.keys = user_utils.merge_keys(user_config_tmux_like.keys, user_config_keys.keys)

-- mouse bindings
config.mouse_bindings = user_config_mouse.mouse_bindings

-- font settings
config.font = font_settings.font
config.font_rules = font_settings.font_rules
config.font_size = font_settings.font_size

-- apply vhs-era theme colors
config.colors = vhs_era_theme.colors
config.window_frame = vhs_era_theme.window_frame
config.inactive_pane_hsb = vhs_era_theme.inactive_pane_hsb

user_tabline.setup({
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

user_tabline.apply_to_config(config)

-- misc settings --

-- this can crash on wayland without manually setting dpi
config.enable_wayland = true

-- trickery to get window to a desired size on launch
-- this is some voodoo for wayland
wezterm.on("gui-attached", function()
  local active_screen = wezterm.gui.screens().active
  local ypx = math.floor(active_screen.height * 0.8)
  -- don't go too wide for typical monitor aspect ratios
  -- assume 16:9 max
  local xpx = math.floor((ypx * 16) / 9)
  local workspace = wezterm.mux.get_active_workspace()
  for _, window in ipairs(wezterm.mux.all_windows()) do
    if window:get_workspace() == workspace then
      local timeout = os.clock() + 2.0 -- 2 second limit
      while os.clock() < timeout do
        local gui_win = window:gui_window()
        gui_win:set_inner_size(xpx, ypx)
        -- required exactly at this point in time
        -- otherwise wezterm reports back the correct size,
        -- but the window is not actually that size yet
        -- You can't put that at the end of the loop either, it has to be
        -- immediately after setting the size
        wezterm.sleep_ms(100)
        local dims = gui_win:get_dimensions()
        -- might be off by a pixel or two, so allow some wiggle room
        if (math.abs(dims.pixel_width - xpx) <= 2) and (math.abs(dims.pixel_height - ypx) <= 2) then
          break
        end
      end
    end
  end
end)

-- set initial window size
config.initial_cols = 80
config.initial_rows = 25

---@return WeztermConfig
return config
