-- la_core/server/main.lua — core runtime, codex loader, bootstrap

local RES = GetCurrentResourceName()
local CODEX = Config.CodexPath or 'la_codex'

local state = rawget(_G, 'LA_CORE_STATE')
if not state then
  state = { cache = {}, indices = {}, codex = { resource = CODEX, ready = false, sets = {} } }
  _G.LA_CORE_STATE = state
else
  state.cache = state.cache or {}
  state.indices = state.indices or {}
  state.codex = state.codex or { resource = CODEX, ready = false, sets = {} }
end

state.codex.resource = CODEX
state.resource = RES

local cache = state.cache
local manifest = state.codex.manifest

local function emit(level, message)
  local msg = string.format('[la_core][%s] %s', level, message)
  state.lastLog = msg
  if type(Config.logger) == 'function' then
    local ok, err = pcall(Config.logger, level, message, msg)
    if not ok then print('[la_core][warn] logger callback failed: '..tostring(err)) end
  else
    print(msg)
  end
  return msg
end

state.emit = emit

local function dbg(m)
  if Config.Debug then emit('dbg', m) end
end

local function loadFrom(res, path)
  local src = LoadResourceFile(res, path)
  if not src then return nil, ('missing %s:%s'):format(res, path) end
  local fn, err = load(src, ('@@%s/%s'):format(res, path))
  if not fn then return nil, err end
  local ok, out = pcall(fn)
  if not ok then return nil, out end
  return out
end

local function ensureManifest()
  if manifest then return true end
  local man, err = loadFrom(CODEX, 'manifest.lua')
  if not man or type(man.sets) ~= 'table' then
    state.codex.ready = false
    state.codex.error = err or 'invalid manifest'
    emit('error', 'Cannot load codex manifest')
    return false
  end
  manifest = man
  state.codex.manifest = man
  state.codex.ready = true
  state.codex.error = nil
  state.codex.sets = man.sets or {}
  state.codex.version = man.version
  dbg(('codex v%s ready'):format(tostring(man.version)))
  return true
end

local function loadSet(name)
  if not ensureManifest() then return nil, 'manifest unavailable' end
  local path = manifest.sets[name]
  if not path then
    dbg(('manifest missing set %s'):format(name))
    return nil, 'not defined'
  end
  local data, err = loadFrom(CODEX, path)
  if not data then
    return nil, err or 'load failed'
  end
  return data, nil
end

local function countEntries(list)
  if type(list) ~= 'table' then return 0 end
  if list[1] ~= nil then return #list end
  local c = 0
  for _ in pairs(list) do c = c + 1 end
  return c
end

local function buildVehicleIndex(list)
  if type(list) ~= 'table' then return {} end
  local idx = {}
  for _, entry in ipairs(list) do
    if type(entry) == 'table' then
      if entry.model then idx[tostring(entry.model):lower()] = entry end
      if entry.spawn then idx[tostring(entry.spawn):lower()] = entry end
      if entry.name then idx[tostring(entry.name):lower()] = entry end
      if entry.label then idx[tostring(entry.label):lower()] = entry end
      if entry.hash then idx[tostring(entry.hash)] = entry end
    end
  end
  return idx
end

local function assignCache(name, data, opts)
  cache[name] = data
  if name == 'vehicles' then
    state.indices.vehicles = buildVehicleIndex(data)
  end
  if not (opts and opts.silent) then
    TriggerEvent('la_core:dataRefreshed', name, data)
  end
end

local trackedSets = {
  'vehicles',
  'peds',
  'factions'
}

local function bootstrapDatasets()
  if not ensureManifest() then
    emit('warn', 'Skipping dataset bootstrap; manifest unavailable')
    return
  end

  local summary = {}
  for _, name in ipairs(trackedSets) do
    local data, err = loadSet(name)
    if not data then
      assignCache(name, {})
      emit('warn', ('Codex set %s missing (%s)'):format(name, err or 'not defined'))
      summary[#summary + 1] = ('%s=0'):format(name)
    else
      assignCache(name, data)
      summary[#summary + 1] = ('%s=%d'):format(name, countEntries(data))
    end
  end

  state.codex.bootstrapped = true
  local msg = ('datasets ready: %s'):format(table.concat(summary, ' '))
  emit('info', msg)
  state.codex.summary = msg
  TriggerEvent('la_core:dataReady', cache)
end

exports('GetVersion', function()
  return Config.Version or '0.0.0'
end)

exports('PrintStatus', function()
  local codexVersion = state.codex.version or 'unknown'
  print(('[la_core] v%s, codex=%s@%s'):format(Config.Version or '0.0.0', CODEX, codexVersion))
end)

exports('GetData', function(name)
  if not name then return nil end
  if cache[name] == nil then
    local data = select(1, loadSet(name))
    if data ~= nil then
      assignCache(name, data, { silent = true })
    else
      assignCache(name, {}, { silent = true })
    end
  end
  return cache[name]
end)

RegisterCommand(Config.StatusCommand or 'la_status', function(src)
  local v = exports[RES]:GetVersion()
  if src == 0 then
    print(('[la_core] v%s OK'):format(v))
  else
    TriggerClientEvent('chat:addMessage', src, { args = { 'LA', ('core %s ok'):format(v) } })
  end
end, false)

AddEventHandler('onResourceStart', function(r)
  if r ~= RES then return end
  exports[RES]:PrintStatus()
  bootstrapDatasets()
  TriggerEvent('la_core:ready', cache)
end)
