-- la_engine/server/main.lua
-- Server side boot and link to la_core.

local RES = GetCurrentResourceName()
local Config = Config or { Debug = true }

local allowedVehicleModels = nil

local function log(level, msg, force)
    if force or Config.Debug then
        print(('[la_engine][%s] %s'):format(level, msg))
    end
end

local function copyList(src)
    local out = {}
    for i = 1, #src do
        out[i] = src[i]
    end
    return out
end

local function loadAllowedVehiclesFromCore()
    local ok, vehicles = pcall(function()
        return exports.la_core:GetData('vehicles')
    end)

    if not ok then
        log('warn', 'Failed to fetch vehicles from la_core: ' .. tostring(vehicles), true)
        return {}
    end

    if type(vehicles) ~= 'table' then
        log('warn', 'Unexpected payload from la_core:GetData("vehicles"): ' .. type(vehicles), true)
        return {}
    end

    local models, seen = {}, {}
    for _, entry in ipairs(vehicles) do
        local model = type(entry) == 'table' and entry.model
        if type(model) == 'string' and model ~= '' and not seen[model] then
            models[#models + 1] = model
            seen[model] = true
        end
    end

    return models
end

local function refreshAllowedVehicles()
    allowedVehicleModels = loadAllowedVehiclesFromCore()
    log('info', ('Cached %d allowed vehicle models'):format(#allowedVehicleModels))
end

AddEventHandler('la_core:ready', function()
    local ok, version = pcall(function() return exports.la_core:GetVersion() end)
    if ok then
        log('info', ('la_core ready (version %s)'):format(version))
    else
        log('warn', 'la_core not linked', true)
    end
    refreshAllowedVehicles()
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= RES then return end
    refreshAllowedVehicles()
end)

exports('GetAllowedVehicleModels', function()
    if not allowedVehicleModels or #allowedVehicleModels == 0 then
        refreshAllowedVehicles()
    end

    if not allowedVehicleModels then
        return {}
    end

    return copyList(allowedVehicleModels)
end)

RegisterCommand('la_engine_status', function(src)
    if src == 0 then
        log('info', 'la_engine server status OK')
    else
        TriggerClientEvent('chat:addMessage', src, { args = { '^2LA Engine', 'Server status OK' } })
    end
end, false)

if GetResourceState(RES) == 'started' then
    refreshAllowedVehicles()
end
