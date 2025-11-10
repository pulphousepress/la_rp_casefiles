-- la_engine/server/main.lua
-- Bootstraps runtime systems and exposes a registry API.

local RESOURCE_NAME = GetCurrentResourceName()

local state = {
    systems = {},
    order = {},
    exports = {},
    contexts = {},
}

local function log(level, message)
    print(('[la_engine][%s] %s'):format(level, message))
end

local function safeCoreCall(fn)
    local ok, result = pcall(fn)
    if not ok then
        log('warn', 'Core call failed: ' .. tostring(result))
        return nil
    end
    return result
end

local function fetchVehicles()
    local data = safeCoreCall(function()
        return exports.la_core:GetVehicleList()
    end)
    return type(data) == 'table' and data or {}
end

local function fetchPeds()
    local data = safeCoreCall(function()
        return exports.la_core:GetPedList()
    end)
    return type(data) == 'table' and data or {}
end

local function fetchFactions()
    local data = safeCoreCall(function()
        return exports.la_core:GetFactionList()
    end)
    return type(data) == 'table' and data or {}
end

local function fetchDataset(name)
    if type(name) ~= 'string' or name == '' then
        return {}
    end

    local data = safeCoreCall(function()
        return exports.la_core:GetData(name)
    end)
    return type(data) == 'table' and data or {}
end

local function registerExport(name, fn, systemId)
    if type(name) ~= 'string' or type(fn) ~= 'function' then
        return
    end

    exports(name, fn)
    state.exports[name] = systemId
    log('info', ('Registered export %s (system=%s)'):format(name, systemId or 'unknown'))
end

local function makeContext(system)
    local ctx = {}

    function ctx.log(level, message)
        log(level, ('[%s] %s'):format(system.id, message))
    end

    ctx.fetchVehicles = fetchVehicles
    ctx.fetchPeds = fetchPeds
    ctx.fetchFactions = fetchFactions
    ctx.fetchDataset = fetchDataset

    function ctx.registerTick(fn)
        if type(fn) ~= 'function' then return end
        CreateThread(fn)
    end

    function ctx.registerExport(name, fn)
        registerExport(name, fn, system.id)
    end

    function ctx.onCoreReady(handler)
        if type(handler) ~= 'function' then return end
        AddEventHandler('la_core:ready', function(datasets)
            handler(datasets or {})
        end)
    end

    function ctx.onCodexUpdated(handler)
        if type(handler) ~= 'function' then return end
        AddEventHandler('la_core:codexUpdated', function(datasets)
            handler(datasets or {})
        end)
    end

    return ctx
end

local registry = {}
registry.__index = registry

function registry:Register(spec)
    if type(spec) ~= 'table' or type(spec.id) ~= 'string' then
        log('warn', 'Attempted to register invalid system spec')
        return
    end

    if state.systems[spec.id] then
        log('warn', ('System id %s already registered; ignoring duplicate'):format(spec.id))
        return
    end

    state.systems[spec.id] = spec
    state.order[#state.order + 1] = { id = spec.id, order = spec.order or 100 }

    if type(spec.exports) == 'table' then
        local ctx = state.contexts[spec.id] or makeContext(spec)
        state.contexts[spec.id] = ctx
        for name, fn in pairs(spec.exports) do
            ctx.registerExport(name, fn)
        end
    end

    log('info', ('Registered system %s'):format(spec.id))
end

local function loadModule(path)
    local chunk = LoadResourceFile(RESOURCE_NAME, path)
    if not chunk then
        log('warn', ('Missing system module %s'):format(path))
        return
    end

    local fn, err = load(chunk, ('@@%s/%s'):format(RESOURCE_NAME, path))
    if not fn then
        log('error', ('Failed to compile %s: %s'):format(path, tostring(err)))
        return
    end

    local ok, result = pcall(fn)
    if not ok then
        log('error', ('Error executing %s: %s'):format(path, tostring(result)))
        return
    end

    if type(result) == 'function' then
        local okRegister, errRegister = pcall(result, setmetatable({}, registry))
        if not okRegister then
            log('error', ('System module %s threw: %s'):format(path, tostring(errRegister)))
        end
    elseif type(result) == 'table' then
        registry.Register(setmetatable({}, registry), result)
    else
        log('warn', ('System module %s returned unsupported type %s'):format(path, type(result)))
    end
end

local function ensureContexts()
    for id, spec in pairs(state.systems) do
        if not state.contexts[id] then
            state.contexts[id] = makeContext(spec)
        end
    end
end

local function bootstrapSystems()
    ensureContexts()

    table.sort(state.order, function(a, b)
        return a.order < b.order
    end)

    for _, entry in ipairs(state.order) do
        local spec = state.systems[entry.id]
        if spec and type(spec.bootstrap) == 'function' then
            local ctx = state.contexts[spec.id]
            local ok, err = pcall(spec.bootstrap, ctx)
            if not ok then
                log('error', ('System %s bootstrap failed: %s'):format(spec.id, tostring(err)))
            end
        end
    end
end

local function dispatch(eventName, datasets)
    for id, spec in pairs(state.systems) do
        local handler = spec[eventName]
        if type(handler) == 'function' then
            local ctx = state.contexts[id] or makeContext(spec)
            state.contexts[id] = ctx
            local ok, err = pcall(handler, ctx, datasets or {})
            if not ok then
                log('error', ('System %s handler %s failed: %s'):format(id, eventName, tostring(err)))
            end
        end
    end
end

local MODULE_PATHS = {
    'server/weather_controller.lua',
    'server/era_vehicles.lua',
    'server/ped_gate.lua',
}

for _, path in ipairs(MODULE_PATHS) do
    loadModule(path)
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= RESOURCE_NAME then
        return
    end

    log('info', 'Bootstrapping la_engine systems')
    bootstrapSystems()
end)

AddEventHandler('la_core:ready', function(datasets)
    dispatch('onCoreReady', datasets)
end)

AddEventHandler('la_core:codexUpdated', function(datasets)
    dispatch('onCodexUpdated', datasets)
end)

exports('GetAllowedVehicleModels', function()
    local vehicles = fetchVehicles()
    local models, seen = {}, {}
    for _, entry in ipairs(vehicles) do
        local model = type(entry) == 'table' and entry.model
        if type(model) == 'string' and model ~= '' and not seen[model] then
            models[#models + 1] = model
            seen[model] = true
        end
    end
    return models
end)
