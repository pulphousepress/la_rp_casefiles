-- la_core/server/la_status.lua — status helpers for monitoring

local state = rawget(_G, 'LA_CORE_STATE') or {}
local RES = state.resource or GetCurrentResourceName()

local function countEntries(list)
  if type(list) ~= 'table' then return 0 end
  if list[1] ~= nil then return #list end
  local c = 0
  for _ in pairs(list) do c = c + 1 end
  return c
end

local function collectCachedSets()
  if type(state.cache) ~= 'table' then return {} end
  local keys = {}
  for name in pairs(state.cache) do
    keys[#keys + 1] = name
  end
  table.sort(keys)
  return keys
end

local function codexStatus()
  local codex = state.codex or {}
  return {
    resource = codex.resource or 'la_codex',
    ready = not not codex.ready,
    version = codex.version,
    summary = codex.summary,
    sets = codex.sets or {},
    cachedSets = collectCachedSets(),
    bootstrapped = not not codex.bootstrapped,
    lastError = codex.error
  }
end

local function datasetStatus()
  local cache = state.cache or {}
  local vehicles = cache.vehicles
  local peds = cache.peds
  local factions = cache.factions
  local status = {
    vehicles = { count = countEntries(vehicles) },
    peds = { count = countEntries(peds) },
    factions = { count = countEntries(factions) }
  }
  status.total = (status.vehicles.count or 0) + (status.peds.count or 0) + (status.factions.count or 0)
  return status
end

local function addonStatus()
  local stats = { categories = 0, actions = 0, ok = false }
  local ok, categories, actions = pcall(function()
    return exports['la_admin']:GetActions()
  end)
  if ok then
    stats.ok = true
    stats.categories = countEntries(categories)
    stats.actions = countEntries(actions)
  else
    stats.error = categories
  end
  return stats
end

exports('GetStatusSnapshot', function()
  local snapshot = {
    resource = RES,
    version = Config.Version or '0.0.0',
    debug = not not Config.Debug,
    timestamp = os.time(),
    codex = codexStatus(),
    datasets = datasetStatus(),
    addons = addonStatus()
  }
  snapshot.codex.healthy = snapshot.codex.ready and snapshot.datasets.total > 0
  return snapshot
end)
