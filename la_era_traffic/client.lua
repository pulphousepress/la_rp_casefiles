-- Load config
if not Config or not Config.SpawnLocations or not Config.EraVehicles then
    print("[la_era_traffic] ERROR: Config not loaded correctly.")
    return
end

-- Weighted random vehicle picker
function getRandomEraVehicle()
    local weightedList = {}

    -- Add custom vehicles with 3x weight
    for i = 1, 3 do
        for _, model in ipairs(Config.EraVehicles.custom) do
            table.insert(weightedList, model)
        end
    end

    -- Add classic vehicles with 1x weight
    for _, model in ipairs(Config.EraVehicles.classics) do
        table.insert(weightedList, model)
    end

    -- Add service vehicles with 0.5x weight
    for i = 1, 1 do
        for _, model in ipairs(Config.EraVehicles.service) do
            table.insert(weightedList, model)
        end
    end

    return weightedList[math.random(#weightedList)]
end

-- Spawn era vehicles at locations
Citizen.CreateThread(function()
    while true do
        for _, loc in ipairs(Config.SpawnLocations) do
            local nearby = GetClosestVehicle(loc, 20.0, 0, 70)
            if not DoesEntityExist(nearby) then
                local modelName = getRandomEraVehicle()
                local model = GetHashKey(modelName)

                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(10)
                end

                local veh = CreateVehicle(model, loc.x, loc.y, loc.z, math.random(0, 360), true, false)
                SetVehicleOnGroundProperly(veh)
                SetEntityAsNoLongerNeeded(veh)
                SetVehicleNumberPlateText(veh, "ERA")
                SetVehicleDoorsLocked(veh, 1)
                if Config.Debug then
                    print("[la_era_traffic] Spawned: " .. modelName)
                end
            end
        end
        Wait(15000) -- Re-check every 15 seconds
    end
end)
