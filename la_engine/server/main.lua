local Config = require('config')
local la_core = nil
local popgroups = {}

CreateThread(function()
    Wait(Config.StartDelay)
    -- wait for la_core to be available (up to 10s)
    local attempts = 0
    while attempts < 20 do
        if exports and exports['la_core'] then
            la_core = exports['la_core']
            break
        end
        attempts = attempts + 1
        Wait(500)
    end

    if not la_core then
        print('[la_engine] WARNING: la_core not available. Ensure la_core is started before la_engine.')
        return
    end

    -- fetch popgroups
    local ok, res = pcall(function() return la_core.GetPopGroups() end)
    if ok and res then
        popgroups = res
        print('[la_engine] Popgroups loaded, entries: ' .. tostring(#(popgroups or {})))
    else
        print('[la_engine] Failed to get popgroups from la_core')
    end

    -- announce ready
    TriggerEvent('la_engine:EngineReady', {popcount = #(popgroups or {})})
end)

-- Example server event to spawn a vehicle (validation against la_core)
RegisterNetEvent('la_engine:SpawnEraVehicle', function(model, coords)
    if not la_core then
        print('[la_engine] spawn request but la_core unavailable')
        return
    end
    local ok, vehs = pcall(function() return la_core.GetVehicleWhitelist() end)
    if not ok or not vehs then
        print('[la_engine] failed to validate vehicle model')
        return
    end
    local valid = false
    for _,v in ipairs(vehs) do
        if v.model == model then
            valid = true
            break
        end
    end
    if not valid then
        print('[la_engine] spawn rejected - model not in era whitelist: ' .. tostring(model))
        return
    end
    -- triggered event to clients to actually spawn; server only validates
    TriggerClientEvent('la_engine:ClientSpawnVehicle', -1, model, coords)
end)
