---@type Wezterm
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local is_windows = string.find(wezterm.target_triple, "windows") ~= nil

---@alias action_callback any
---@alias MuxWindow any
---@alias Pane any

---@alias workspace_ids table<string, boolean>
---@alias choice_opts {extra_args?: string, workspace_ids?: workspace_ids}
---@alias InputSelector_choices { id: string, label: string }[]

---@class public_module
---@field zoxide_path string
---@field choices {get_zoxide_elements: (fun(choices: InputSelector_choices, opts: choice_opts?): InputSelector_choices), get_workspace_elements: (fun(choices: InputSelector_choices): (InputSelector_choices, workspace_ids))}
---@field workspace_formatter fun(label: string, is_active: boolean): string
---@field zoxide_formatter fun(label: string): string
local M = {
  zoxide_path = "zoxide",
  choices = {},
  ---Strip wezterm.format()/ANSI-like escape sequences from strings.
  ---Workspace names should be plain, but older entries may contain escapes if they
  ---were created from a formatted InputSelector label.
  ---@param s string
  ---@return string
  _strip_escapes = function(s)
    if s == nil then
      return ""
    end
    -- OSC sequences: ESC ] ... (BEL or ST)
    s = s:gsub("\x1b%][^\x07\x1b]*\x07", "")
    s = s:gsub("\x1b%][^\x1b]*\x1b\\", "")
    -- CSI sequences: ESC [ ... letter
    s = s:gsub("\x1b%[[0-9:;<=>?]*[ -/]*[@-~]", "")
    -- Other 2-byte escapes
    s = s:gsub("\x1b.", "")
    return s
  end,
  ---Format a workspace row using theme-derived colors.
  ---@param label string
  ---@param is_active boolean
  ---@param colors any
  ---@return string
  workspace_formatter = function(label, is_active, colors)
    -- Style workspace entries (as opposed to zoxide paths) so they're easy to spot.
    -- WezTerm doesn't currently expose "hovered/selected row" state to the
    -- formatter. To make the workspace name visually consistent with the
    -- shortcut label column, we explicitly style the full label here.
    local text = label

    -- Derive colors from the currently effective config/theme.
    -- Prefer tab_bar.active_tab, then to sane defaults.
    local active_bg = "#ee5396"
    local active_fg = "#161616"

    if colors then
      local tab_bar = colors.tab_bar
      if tab_bar and tab_bar.active_tab then
        active_bg = tab_bar.active_tab.bg_color or active_bg
        active_fg = tab_bar.active_tab.fg_color or active_fg
      end
    end

    if is_active then
      text = "⚡ " .. label
      return wezterm.format({
        { Attribute = { Intensity = "Bold" } },
        { Background = { Color = active_bg } },
        { Foreground = { Color = active_fg } },
        { Text = text },
      })
    end

    return wezterm.format({
      { Background = { Color = active_fg } },
      { Foreground = { Color = active_bg } },
      { Text = text },
    })
  end,
  zoxide_formatter = function(label)
    return wezterm.format({
      { Foreground = { AnsiColor = "Grey" } },
      { Text = label },
    })
  end,
}

-- Track most-recently-used workspaces so we can sort open workspaces by recency.
-- Note: wezterm.GLOBAL persists within the wezterm process lifetime.
wezterm.GLOBAL.workspace_last_used = wezterm.GLOBAL.workspace_last_used or {}
wezterm.GLOBAL.workspace_use_seq = wezterm.GLOBAL.workspace_use_seq or 0

---@param name string
---@return string[]
local function workspace_name_variants(name)
  name = M._strip_escapes(name or "")
  local variants = { name }

  -- Expand ~ to home, and also generate a tilde version if possible.
  if wezterm.home_dir and wezterm.home_dir ~= "" then
    if name:sub(1, 2) == "~/" then
      table.insert(variants, wezterm.home_dir .. name:sub(2))
    elseif name:sub(1, #wezterm.home_dir) == wezterm.home_dir then
      table.insert(variants, "~" .. name:sub(#wezterm.home_dir + 1))
    end
  end

  -- Deduplicate
  local seen = {}
  local out = {}
  for _, v in ipairs(variants) do
    if v and v ~= "" and not seen[v] then
      seen[v] = true
      table.insert(out, v)
    end
  end
  return out
end

---@param workspace string
local function mark_workspace_used(workspace)
  if not workspace or workspace == "" then
    return
  end
  -- Use a monotonic sequence instead of os.time() (1s resolution) so that
  -- rapid switches/creates in the same second still sort deterministically.
  wezterm.GLOBAL.workspace_use_seq = (wezterm.GLOBAL.workspace_use_seq or 0) + 1
  local now = wezterm.GLOBAL.workspace_use_seq
  for _, key in ipairs(workspace_name_variants(workspace)) do
    wezterm.GLOBAL.workspace_last_used[key] = now
  end
end

---@param cmd string
---@return string
local run_child_process = function(cmd)
  local process_args = { os.getenv("SHELL"), "-c", cmd }
  if is_windows then
    process_args = { "cmd", "/c", cmd }
  end
  local success, stdout, stderr = wezterm.run_child_process(process_args)

  if not success then
    wezterm.log_error("Child process '" .. cmd .. "' failed with stderr: '" .. stderr .. "'")
  end
  return stdout
end

---@param choice_table InputSelector_choices
---@param active_workspace string|nil
---@param colors any
---@return InputSelector_choices, workspace_ids
function M.choices.get_workspace_elements(choice_table, active_workspace, colors)
  local workspace_ids = {}
  if active_workspace == nil then
    active_workspace = mux.get_active_workspace()
  end
  local workspaces = mux.get_workspace_names()
  table.sort(workspaces, function(a, b)
    -- Most recently used first; fall back to name for stable ordering
    local function last_used_for(name)
      for _, key in ipairs(workspace_name_variants(name)) do
        local ts = wezterm.GLOBAL.workspace_last_used[key]
        if ts ~= nil then
          return ts
        end
      end
      return 0
    end

    local la = last_used_for(a)
    local lb = last_used_for(b)
    if la ~= lb then
      return la > lb
    end
    return tostring(a) < tostring(b)
  end)

  for _, workspace in ipairs(workspaces) do
    local display = M._strip_escapes(workspace)
    table.insert(choice_table, {
      id = workspace,
      label = M.workspace_formatter(display, tostring(workspace) == tostring(active_workspace), colors),
    })
    workspace_ids[workspace] = true
  end
  return choice_table, workspace_ids
end

---@param choice_table InputSelector_choices
---@param opts? choice_opts
---@return InputSelector_choices
function M.choices.get_zoxide_elements(choice_table, opts)
  if opts == nil then
    opts = { extra_args = "", workspace_ids = {} }
  end

  local stdout = run_child_process(M.zoxide_path .. " query -l " .. (opts.extra_args or ""))

  for _, path in ipairs(wezterm.split_by_newlines(stdout)) do
    local updated_path = string.gsub(path, wezterm.home_dir, "~")
    if not opts.workspace_ids[updated_path] then
      table.insert(choice_table, {
        id = path,
        -- Keep the label plain; we use it as the workspace name on creation.
        label = updated_path,
      })
    end
  end
  return choice_table
end

---Returns choices for the InputSelector
---@param opts? choice_opts
---@param active_workspace? string
---@param colors? any
---@return InputSelector_choices
function M.get_choices(opts, active_workspace, colors)
  if opts == nil then
    opts = { extra_args = "" }
  end
  ---@type InputSelector_choices
  local choices = {}
  choices, opts.workspace_ids = M.choices.get_workspace_elements(choices, active_workspace, colors)
  choices = M.choices.get_zoxide_elements(choices, opts)
  return choices
end

---@param workspace string
---@return MuxWindow
local function get_current_mux_window(workspace)
  for _, mux_win in ipairs(mux.all_windows()) do
    if mux_win:get_workspace() == workspace then
      return mux_win
    end
  end
  error("Could not find a workspace with the name: " .. workspace)
end

---Check if the workspace exists
---@param workspace string
---@return boolean
local function workspace_exists(workspace)
  for _, workspace_name in ipairs(mux.get_workspace_names()) do
    if workspace == workspace_name then
      return true
    end
  end
  return false
end

---InputSelector callback when zoxide supplied element is chosen
---@param window MuxWindow
---@param pane Pane
---@param path string
---@param label_path string
local function zoxide_chosen(window, pane, path, label_path)
  -- label_path is displayed to the user; make sure we never use a formatted
  -- string (with escape sequences) as a workspace name.
  local workspace_name = M._strip_escapes(label_path)
  window:perform_action(
    act.SwitchToWorkspace({
      name = workspace_name,
      spawn = {
        label = "Workspace: " .. workspace_name,
        cwd = path,
      },
    }),
    pane
  )
  mark_workspace_used(workspace_name)
  wezterm.emit(
    "workspace_switcher.workspace_switcher.created",
    get_current_mux_window(workspace_name),
    path,
    workspace_name
  )
  -- increment zoxide path score
  run_child_process(M.zoxide_path .. " add " .. path)
end

---InputSelector callback when workspace element is chosen
---@param window MuxWindow
---@param pane Pane
---@param workspace string
---@param label_workspace string
local function workspace_chosen(window, pane, workspace, label_workspace)
  window:perform_action(
    act.SwitchToWorkspace({
      name = workspace,
    }),
    pane
  )
  mark_workspace_used(workspace)
  wezterm.emit(
    "workspace_switcher.workspace_switcher.chosen",
    get_current_mux_window(workspace),
    workspace,
    label_workspace
  )
end

---@param opts? choice_opts
---@return action_callback
function M.switch_workspace(opts)
  return wezterm.action_callback(function(window, pane)
    wezterm.emit("workspace_switcher.workspace_switcher.start", window, pane)
    local effective = window:effective_config()
    local choices = M.get_choices(opts, window:active_workspace(), effective and effective.colors or nil)

    window:perform_action(
      act.InputSelector({
        action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
          if id and label then
            wezterm.emit("workspace_switcher.workspace_switcher.selected", window, id, label)

            if workspace_exists(id) then
              -- workspace is choosen
              workspace_chosen(inner_window, inner_pane, id, label)
            else
              -- path is choosen
              zoxide_chosen(inner_window, inner_pane, id, label)
            end
          else
            wezterm.emit("workspace_switcher.workspace_switcher.canceled", window, pane)
          end
        end),
        title = "Choose Workspace",
        description = "Select a workspace and press Enter = accept, Esc = cancel, / = filter",
        fuzzy_description = "Workspace to switch: ",
        choices = choices,
        fuzzy = true,
      }),
      pane
    )
  end)
end

function M.switch_to_prev_workspace()
  return wezterm.action_callback(function(window, pane)
    local current_workspace = window:active_workspace()
    local previous_workspace = wezterm.GLOBAL.previous_workspace

    if current_workspace == previous_workspace or previous_workspace == nil then
      return
    end

    wezterm.GLOBAL.previous_workspace = current_workspace

    window:perform_action(
      act.SwitchToWorkspace({
        name = previous_workspace,
      }),
      pane
    )
    mark_workspace_used(previous_workspace)
    wezterm.emit("workspace_switcher.workspace_switcher.switched_to_prev", window, pane, previous_workspace)
  end)
end

wezterm.on("workspace_switcher.workspace_switcher.selected", function(window, _, _)
  wezterm.GLOBAL.previous_workspace = window:active_workspace()
  mark_workspace_used(window:active_workspace())
end)

return M
