local M = {}

--- Merge multiple keybinding tables safely for WezTerm
---@param ... table[] List of keybinding tables
---@return table Merged keybindings
M.merge_keys = function(...)
  local result = {}
  for _, tbl in ipairs({ ... }) do
    for _, entry in ipairs(tbl) do
      -- Ensure each entry is a table with a valid action
      if type(entry) == "table" and entry.action ~= nil then
        -- Assume action is already a valid wezterm action or action_callback
        table.insert(result, entry)
      else
        error("Invalid keybinding entry: must be a table with an 'action' field")
      end
    end
  end
  return result
end

return M
