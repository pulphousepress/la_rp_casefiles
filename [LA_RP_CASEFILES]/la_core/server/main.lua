-- la_core/server/main.lua — core runtime, codex loader, exports
package.path = string.format('%s;server/?.lua;server/?/init.lua', package.path)

local RES = GetCurrentResourceName()
local CODEX = Config.CodexPath or 'la_codex'
local cache, manifest = {}, nil

local AddonsRegistry = require('addons_registry')
local Commands = require('commands')

local defaultCategories = {
  { name = 'core', label = 'Core Systems', description = 'Primary LA framework modules' },
  { name = 'integration', label = 'Integrations', description = 'Bridges into external services' },
  { name = 'gameplay', label = 'Gameplay', description = 'Mechanics and narrative content' },
  { name = 'ui', label = 'User Interface', description = 'Interface and NUI components' },
  { name = 'utility', label = 'Utilities', description = 'Supporting helpers and infrastructure' },
}

local function emit(level, message)
  local msg = string.format('[la_core][%s] %s', level, message)
  if type(Config.logger) == 'function' then
    local ok, err = pcall(Config.logger, level, message, msg)
    if not ok then print('[la_core][warn] logger callback failed: '..tostring(err)) end
  else
    print(msg)
  end
  return msg
end

local function dbg(m) if Config.Debug then emit('dbg', m) end end

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
  local data, err = loadFrom(CODEX, 'manifest.lua')
  if not data or type(data.sets) ~= 'table' then
    emit('error', ('Cannot load codex manifest: %s'):format(err or 'invalid manifest'))
    return false
  end
  manifest = data
  dbg(('codex v%s ready'):format(tostring(manifest.version)))
  return true
end

local function loadSet(name)
  if not ensureManifest() then return nil end
  local path = manifest.sets[name]
  if not path then return nil end
  return loadFrom(CODEX, path)
end

local function getStatus()
  local ok = ensureManifest()
  return {
    ok = ok,
    resource = RES,
    version = Config.Version or '0.0.0',
    codex = CODEX,
    manifestVersion = manifest and manifest.version or nil,
    timestamp = os.time(),
  }
end

-- public exports
exports('GetVersion', function() return Config.Version or '0.0.0' end)
exports('PrintStatus', function()
  local status = getStatus()
  if status.ok then
    emit('info', ('core ready v%s (codex=%s, manifest=%s)'):format(status.version, status.codex, status.manifestVersion or 'n/a'))
  else
    emit('error', 'core status check failed')
  end
end)
exports('GetData', function(name)
  if not name then return nil end
  cache[name] = cache[name] or loadSet(name)
  return cache[name]
end)

-- command registration
Commands.register({
  logger = emit,
  registry = AddonsRegistry,
  statusCommand = Config.StatusCommand or 'la_status',
  addonsCommand = Config.AddonsCommand or 'la_addons',
  getStatus = function()
    local status = getStatus()
    return {
      ok = status.ok,
      version = status.version,
      codex = status.codex,
      manifestVersion = status.manifestVersion,
    }
  end,
})

-- lifecycle
AddEventHandler('onResourceStart', function(r)
  if r ~= RES then return end

  AddonsRegistry.seedCategories(defaultCategories)
  local categories = AddonsRegistry.getCategories()
  dbg(string.format('seeded %d registry categories', #categories))

  local status = getStatus()
  if status.ok then
    emit('info', ('resource started (v%s, codex=%s, manifest=%s)'):format(status.version, status.codex, status.manifestVersion or 'n/a'))
  else
    emit('error', ('resource start check failed (codex=%s)'):format(status.codex))
  end

  TriggerEvent('la_core:ready', status)
end)
