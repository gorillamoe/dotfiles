---@type Wezterm
local wezterm = require("wezterm")
local act = wezterm.action

---@type wezterm.Config
return {
  key_tables = {
    search_mode = {
      { key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
      { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
      -- Optional: use CTRL-n/CTRL-p while still typing to jump matches
      { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
      { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
    },
    -- Key table for when you are in Copy Mode (Visual Mode)
    copy_mode = {
      { key = "n", mods = "NONE", action = act.CopyMode("NextMatch") },
      { key = "N", mods = "SHIFT", action = act.CopyMode("PriorMatch") },
      { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    },
  },
}
