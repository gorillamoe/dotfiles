local wezterm = require("wezterm")
local M = {}

function M.update(window)
  local mode = M.get(window):gsub("_mode", "")
  mode = mode:upper()

  if window:leader_is_active() then
    return wezterm.nerdfonts.md_keyboard_outline
  elseif mode == "NORMAL" then
    return wezterm.nerdfonts.cod_terminal
  elseif mode == "COPY" then
    return wezterm.nerdfonts.md_scissors_cutting
  elseif mode == "SEARCH" then
    return wezterm.nerdfonts.oct_search
  end

  return mode
end

function M.get(window)
  local key_table = window:active_key_table()

  if key_table == nil or not key_table:find("_mode$") then
    key_table = "normal_mode"
  end

  return key_table
end

return M
