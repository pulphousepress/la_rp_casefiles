--[[
    la_era_vehicles_ext/server/main.lua

    Startup expectations:
      * la_core should be started first and emit the 'la_core:ready' event so we can
        fetch codex vehicle data through its exports.
      * la_engine must provide the 'GetAllowedVehicleModels' export; the addon falls
        back to la_core data if the export is unavailable.
      * la_admin should expose 'RegisterAddon' so we can publish our debug command,
        but failure to do so is non-fatal and is logged.
]]

local RESOURCE_NAME = GetCurrentResourceName()
local LOG_PREFIX = '[LA_ADDON:la_era_vehicles_ext]'

local ADMIN = 'la_admin'
local CORE = 'la_core'
local ENGINE = 'la_engine'

local cachedModels = {}

local function log(message)
    print(('%s %s'):format(LOG_PREFIX, message))
end

local function fetchModelsFromCore()
    local ok, vehicles = pcall(function()
        return exports[CORE]:GetData('vehicles')
    end)

    if not ok then
        log(('Failed to query %s:GetData("vehicles"): %s'):format(CORE, tostring(vehicles)))
        return {}
    end

    if type(vehicles) ~= 'table' then
        log(('Unexpected payload from %s:GetData("vehicles"): %s'):format(CORE, type(vehicles)))
        return {}
    end

    local out, seen = {}, {}
    for _, entry in ipairs(vehicles) do
        local model = type(entry) == 'table' and entry.model
        if type(model) == 'string' and model ~= '' and not seen[model] then
            out[#out + 1] = model
            seen[model] = true
        end
    end

    return out
end

local function fetchModelsFromEngine()
    local ok, models = pcall(function()
        return exports[ENGINE]:GetAllowedVehicleModels()
    end)

    if not ok then
        log(('Failed to query %s:GetAllowedVehicleModels(): %s'):format(ENGINE, tostring(models)))
        return nil
    end

    if type(models) ~= 'table' then
        log(('Unexpected payload from %s:GetAllowedVehicleModels(): %s'):format(ENGINE, type(models)))
        return nil
    end

    return models
end

local function refreshAllowedModels()
    local engineModels = fetchModelsFromEngine()
    if engineModels and #engineModels > 0 then
        cachedModels = engineModels
        log(('Loaded %d allowed vehicle models from %s'):format(#cachedModels, ENGINE))
        return cachedModels
    end

    cachedModels = fetchModelsFromCore()
    log(('Loaded %d allowed vehicle models directly from %s'):format(#cachedModels, CORE))
    return cachedModels
end

local function registerWithAdmin()
    local ok, success, descriptor = pcall(function()
        return exports[ADMIN]:RegisterAddon({
            id = RESOURCE_NAME,
            name = 'Era Vehicle Extension',
            version = '1.0.0',
            hooks = { 'onReady' },
            provides = { 'vehicles', 'debug_commands' }
        })
    end)

    if not ok then
        log(('Unable to register addon with %s: %s'):format(ADMIN, tostring(success)))
        return
    end

    if success == false then
        log(('Addon registration rejected by %s'):format(ADMIN))
        return
    end

    if type(descriptor) == 'table' and descriptor.name then
        log(('Registered addon with %s (%s)'):format(ADMIN, descriptor.name))
    else
        log(('Registered addon with %s'):format(ADMIN))
    end
end

local function emitAllowedModels(target)
    local models = cachedModels
    if #models == 0 then
        models = refreshAllowedModels()
    end

    local payload = table.concat(models, ', ')
    if target == 0 then
        log(('Allowed vehicle models: %s'):format(payload))
    else
        TriggerClientEvent('chat:addMessage', target, {
            args = { '^2Era Vehicles', ('Allowed models (%d): %s'):format(#models, payload) }
        })
    end
end

RegisterCommand('la_era_vehicles_ext_models', function(src)
    emitAllowedModels(src)
end, true)

RegisterNetEvent('la_era_vehicles_ext:refresh', function()
    local src = source
    refreshAllowedModels()
    emitAllowedModels(src)
end)

AddEventHandler('la_core:ready', function()
    refreshAllowedModels()
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= RESOURCE_NAME then return end
    registerWithAdmin()
    refreshAllowedModels()
end)

-- Eager load when the resource is already running (e.g. during script reload).
if GetResourceState(RESOURCE_NAME) == 'started' then
    registerWithAdmin()
    refreshAllowedModels()
end
