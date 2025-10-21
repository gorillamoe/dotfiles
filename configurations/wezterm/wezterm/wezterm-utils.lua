-- Pure-Lua tbl_deep_extend replacement
-- behavior: "force" | "keep"
-- returns a new table which is the deep-merge of all provided tables
-- Example usage:
-- local a = { x = 1, nested = { a = 1 } }
-- local b = { x = 2, nested = { b = 2 } }
-- local merged = tbl_deep_extend("force", a, b)
-- => merged.x == 2; merged.nested == { a = 1, b = 2 }
local function tbl_deep_extend(behavior, ...)
  assert(type(behavior) == "string", "behavior must be a string")
  assert(behavior == "force" or behavior == "keep", "behavior must be 'force' or 'keep'")

  local args = { ... }
  assert(#args > 0, "must provide at least one table to extend")

  -- Create a deep copy/merge. 'seen' maps source tables -> destination table
  local function is_array_like(t)
    -- not strictly necessary, but helps treat sequential arrays normally
    -- determine if table has only integer keys from 1..n
    local i = 0
    for k in pairs(t) do
      if type(k) ~= "number" then
        return false
      end
      if k > 2 ^ 31 then
        return false
      end
      i = i + 1
    end
    -- crude — returns true if only numeric keys (order not guaranteed)
    return i > 0
  end

  local function _merge(dst, src, seen)
    -- seen: map from src table -> dst table to avoid infinite recursion
    if seen[src] then
      return seen[src]
    end
    seen[src] = dst

    for k, v in pairs(src) do
      local kt = type(k)
      if kt ~= "string" and kt ~= "number" then
        -- copy other key types too
      end

      local existing = dst[k]
      local tv = type(v)
      local tex = type(existing)

      if tv == "table" then
        if tex == "table" then
          -- both tables => merge recursively
          if seen[v] then
            -- already mapped -> reuse mapped table
            dst[k] = seen[v]
          else
            local new_sub = existing
            -- ensure we don't mutate shared table from elsewhere:
            -- create a new table and copy existing into it if it's reused elsewhere
            local copy_existing = {}
            for kk, vv in pairs(existing) do
              copy_existing[kk] = vv
            end
            new_sub = copy_existing
            dst[k] = _merge(new_sub, v, seen)
          end
        else
          -- src is table, dst not table
          if behavior == "force" or existing == nil then
            -- deep-copy src table into dst[k]
            local new_sub = {}
            dst[k] = _merge(new_sub, v, seen)
          elseif behavior == "keep" then
            -- keep existing non-table value; do nothing
          end
        end
      else
        -- src is not a table
        if existing == nil then
          dst[k] = v
        else
          if behavior == "force" then
            dst[k] = v
          elseif behavior == "keep" then
            -- keep existing, do nothing
          end
        end
      end
    end

    return dst
  end

  -- start with an empty result, then merge each table in order
  local result = {}
  local seen = {} -- maps source tables to corresponding tables in result
  for i = 1, #args do
    local t = args[i]
    if type(t) ~= "table" then
      error("argument #" .. i .. " is not a table")
    end
    _merge(result, t, seen)
  end

  return result
end

return {
  tbl_deep_extend = tbl_deep_extend,
}
