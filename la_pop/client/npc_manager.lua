local NPCs, patrolVehicles = {}, {}

-- Force to ground
local function ForceGroundAlign(entity)
    local pos = GetEntityCoords(entity)
    local _, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 1.0, false)
    if groundZ and groundZ > 0 then
        SetEntityCoords(entity, pos.x, pos.y, groundZ, false, false, false, true)
    else
        for i = 1, 10 do
            PlaceObjectOnGroundProperly(entity)
            Wait(100)
        end
    end
end

-- SPAWN STATIC NPC
RegisterNetEvent('la_population:spawnNPC', function(id, data)
    if data.vehicle then return end
    if NPCs[id] and DoesEntityExist(NPCs[id]) then DeletePed(NPCs[id]) end
    RequestModel(data.model); while not HasModelLoaded(data.model) do Wait(0) end
    local ped = CreatePed(4, data.model, data.coords.x, data.coords.y, data.coords.z, data.heading, true, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    ForceGroundAlign(ped)
    if data.emote then TaskStartScenarioInPlace(ped, data.emote, 0, true) end
    NPCs[id] = ped
end)

-- BLIPS
RegisterNetEvent('la_population:setupBlips', function(data)
    for _, npc in pairs(data) do
        if npc.blip then
            local b = AddBlipForCoord(npc.coords.x, npc.coords.y, npc.coords.z)
            SetBlipSprite(b, npc.blip.sprite)
            SetBlipDisplay(b, npc.blip.display)
            SetBlipScale(b, npc.blip.scale)
            SetBlipColour(b, npc.blip.color)
            SetBlipAsShortRange(b, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(npc.blip.name)
            EndTextCommandSetBlipName(b)
        end
    end
end)

-- REMOVE
RegisterNetEvent('la_population:removeNPC', function(id)
    if NPCs[id] then if DoesEntityExist(NPCs[id]) then DeletePed(NPCs[id]) end NPCs[id] = nil end
    if patrolVehicles[id] then
        local pv = patrolVehicles[id]
        if pv.driver then DeletePed(pv.driver) end
        if pv.passenger then DeletePed(pv.passenger) end
        if pv.vehicle then DeleteVehicle(pv.vehicle) end
        patrolVehicles[id] = nil
    end
end)

-- PATROL UNIT
RegisterNetEvent('la_population:startPatrol', function(id, data)
    if patrolVehicles[id] then TriggerEvent('la_population:removeNPC', id) end
    RequestModel(data.model); RequestModel(data.partner); RequestModel(data.vehicle)
    while not HasModelLoaded(data.model) or not HasModelLoaded(data.partner) or not HasModelLoaded(data.vehicle) do Wait(0) end
    local veh = CreateVehicle(data.vehicle, data.coords.x, data.coords.y, data.coords.z, data.heading, true, false)
    SetVehicleOnGroundProperly(veh)
    SetVehicleEngineOn(veh, true, true, false)
    local driver = CreatePedInsideVehicle(veh, 4, data.model, -1, true, true)
    local passenger = CreatePedInsideVehicle(veh, 4, data.partner, 0, true, true)
    SetEntityInvincible(driver, true); SetEntityInvincible(passenger, true)
    SetBlockingOfNonTemporaryEvents(driver, true); SetBlockingOfNonTemporaryEvents(passenger, true)
    patrolVehicles[id] = { vehicle = veh, driver = driver, passenger = passenger, route = data.patrolRoute }
    CreateThread(function()
        local route, i = data.patrolRoute, 1
        while DoesEntityExist(veh) and DoesEntityExist(driver) do
            local node = route[i]
            TaskVehicleDriveToCoordLongrange(driver, veh, node.x, node.y, node.z, 12.0, 447, 5.0)
            Wait(node.wait); i = i + 1; if i > #route then i = 1 end
        end
    end)
end)
