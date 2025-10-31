local wezterm = require("wezterm")
local workspace_switcher = require("wezterm-workspace-switcher")

return {
  keys = {
    -- increase of decrease the window size
    {
      mods = "LEADER",
      key = "R",
      action = wezterm.action.PromptInputLine({
        description = "Enter a new window size in px as:\n"
          .. "<width>,<height> or +/- values.\n\n"
          .. "Single value to set both width and height."
          .. "'auto' to 80% of available screen size.",
        action = wezterm.action_callback(function(window, _, line)
          if line then
            if line == "auto" then
              local screens = wezterm.gui.screens()
              local active_screen = screens["active"]
              local xpx = math.floor(active_screen.width * 0.8)
              local ypx = math.floor(active_screen.height * 0.8)
              window:set_inner_size(xpx, ypx)
              return
            end
            -- input can be like "80,24", "+10,+5", "-10,-5"
            -- also "+10, -5" or "-10, +5" or "+10" or "-5" or "80"
            local dimensions = window:get_dimensions()
            local width, height = dimensions.pixel_width, dimensions.pixel_height
            local xpx, ypx = line:match("^%s*([+-]?%d+)%s*,%s*([+-]?%d+)%s*$")
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
      action = wezterm.action.ShowTabNavigator,
    },
    -- quit pane, or tab if no pane
    {
      mods = "LEADER",
      key = "q",
      action = wezterm.action.CloseCurrentPane({ confirm = true }),
    },
    -- copy mode / vim mode
    {
      mods = "LEADER",
      key = "v",
      action = wezterm.action.ActivateCopyMode,
    },
    -- search
    {
      mods = "LEADER",
      key = "/",
      action = wezterm.action.Search({ CaseInSensitiveString = "" }),
    },
    -- reset font size
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    -- workspace switcher
    {
      mods = "CTRL",
      key = "k",
      action = workspace_switcher.switch_workspace(),
    },
    {
      mods = "LEADER|CTRL", -- use LEADER + CTRL + k to avoid conflict with CTRL + k in neovim
      key = "k",
      action = workspace_switcher.switch_workspace(),
    },
    -- fullscreen
    {
      mods = "LEADER",
      key = "o",
      action = wezterm.action.ToggleFullScreen,
    },
  },
}
