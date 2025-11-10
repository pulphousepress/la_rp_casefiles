-- la_core/server/exports.lua — codex backed exports

local state = rawget(_G, 'LA_CORE_STATE') or {}
local RES = state.resource or GetCurrentResourceName()

local function ensureCached(name)
  if type(state.cache) ~= 'table' then return {} end
  local data = state.cache[name]
  if type(data) ~= 'table' then
    local ok, fetched = pcall(function()
      return exports[RES]:GetData(name)
    end)
    if ok and type(fetched) == 'table' then
      data = fetched
    else
      data = {}
    end
    state.cache[name] = data
  end
  return data
end

local function getList(name)
  local data = ensureCached(name)
  if type(data) ~= 'table' then
    return {}
  end
  return data
end

local function eachEntry(list, fn)
  if type(list) ~= 'table' then return end
  if list[1] ~= nil then
    for _, entry in ipairs(list) do fn(entry) end
  else
    for _, entry in pairs(list) do fn(entry) end
  end
end

local function findVehicle(query)
  if query == nil then return nil end
  local vehicles = getList('vehicles')
  local idx = state.indices and state.indices.vehicles
  local key
  if type(query) == 'number' then
    key = tostring(query)
    if idx and idx[key] then return idx[key] end
  end
  key = tostring(query):lower()
  if idx and idx[key] then return idx[key] end

  local found
  eachEntry(vehicles, function(entry)
    if found or type(entry) ~= 'table' then return end
    local model = entry.model and tostring(entry.model):lower()
    local spawn = entry.spawn and tostring(entry.spawn):lower()
    local name = entry.name and tostring(entry.name):lower()
    local label = entry.label and tostring(entry.label):lower()
    if model == key or spawn == key or name == key or label == key then
      found = entry
    end
  end)

  return found
end

exports('GetVehicleList', function()
  return getList('vehicles')
end)

exports('GetPedList', function()
  return getList('peds')
end)

exports('GetFactionList', function()
  return getList('factions')
end)

exports('FindVehicle', function(query)
  return findVehicle(query)
end)
