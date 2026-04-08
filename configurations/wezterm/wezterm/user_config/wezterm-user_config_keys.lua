---@type Wezterm
local wezterm = require("wezterm")
local act = wezterm.action
local act_callback = wezterm.action_callback
local workspace_switcher = require("plugins.workspace-switcher")

---@type wezterm.Config
return {
  ---@type wezterm.KeyBinding[]
  keys = {
    -- flashlight 🔦 mode
    {
      mods = "LEADER",
      key = "f",
      action = wezterm.action.QuickSelectArgs {
        label = 'Flashlight Mode 🔦',
        patterns = { [[\b\w+\b]] },
        action = act.CopyTo("Clipboard"),
      },
    },
    -- toggle tabline plugin
    {
      mods = "LEADER",
      key = "t",
      action = act_callback(function(window)
        require("plugins.tabline").toggle(window)
      end),
    },
    -- increase of decrease the window size
    {
      mods = "LEADER",
      key = "R",
      action = act.PromptInputLine({
        description = "Enter a new window size in px as:\n"
          .. "<width>x<height> or +/- values.\n\n"
          .. "Single value to set both width and height."
          .. "'auto' to 80% of available screen size.",
        action = act_callback(function(window, _, line)
          if line then
            if line == "auto" then
              local screens = wezterm.gui.screens()
              local active_screen = screens["active"]
              local ypx = math.floor(active_screen.height * 0.8)
              -- don't go too wide for typical monitor aspect ratios
              -- assume 16:9 max
              local xpx = math.floor((ypx * 16) / 9)
              window:set_inner_size(xpx, ypx)
              return
            end
            -- input can be like "80x24", "+10x+5", "-10x-5"
            -- also "+10, -5" or "-10, +5" or "+10" or "-5" or "80"
            local dimensions = window:get_dimensions()
            local width, height = dimensions.pixel_width, dimensions.pixel_height
            local xpx, ypx = line:match("^%s*([+-]?%d+)%s*x%s*([+-]?%d+)%s*$")
            local single_value = line:match("^%s*([+-]?%d+)%s*$")
            if single_value then
              if single_value:sub(1, 1) == "+" or single_value:sub(1, 1) == "-" then
                -- relative change
                xpx = width + tonumber(single_value)
                ypx = height + tonumber(single_value)
              else
                -- absolute change
                xpx = tonumber(single_value)
                ypx = xpx
              end
            end
            if xpx and ypx then
              if not single_value and (xpx:sub(1, 1) == "+" or xpx:sub(1, 1) == "-") then
                -- relative change
                xpx = width + tonumber(xpx)
              else
                -- absolute change
                xpx = tonumber(xpx)
              end
              if not single_value and (ypx:sub(1, 1) == "+" or ypx:sub(1, 1) == "-") then
                -- relative change
                ypx = height + tonumber(ypx)
              else
                -- absolute change
                ypx = tonumber(ypx)
              end
              window:set_inner_size(tonumber(xpx), tonumber(ypx))
            else
              wezterm.log_error("Invalid input. Please enter in the format: <cols>,<rows>")
            end
          end
        end),
      }),
    },
    --  wezterm tab navigator
    {
      mods = "LEADER",
      key = "w",
      action = act.ShowTabNavigator,
    },
    -- quit all panes and tabs and exit wezterm
    {
      mods = "LEADER",
      key = "Q",
      action = act.QuitApplication,
    },
    -- quit pane, or tab if no pane
    {
      mods = "LEADER",
      key = "q",
      action = act.CloseCurrentPane({ confirm = true }),
    },
    -- copy mode / vim mode
    {
      mods = "LEADER",
      key = "v",
      action = act.ActivateCopyMode,
    },
    -- search
    {
      mods = "LEADER",
      key = "/",
      action = act.Search({ CaseInSensitiveString = "" }),
    },
    -- reset font size
    { key = "0", mods = "CTRL", action = act.ResetFontSize },
    {
      mods = "CTRL", -- use CTRL + SHIFT + K to avoid conflict with vim motions
      key = "K",
      action = workspace_switcher.switch_workspace(),
    },
    -- fullscreen
    {
      mods = "LEADER",
      key = "o",
      action = act.ToggleFullScreen,
    },
  },
}
