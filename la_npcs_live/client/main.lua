-- la_npcs_live / client/main.lua
-- Los Animales RP — Living NPCs with grounded placement and ambient chatter (cleaned + patrol fix)

local NPCs = {}
local patrolVehicles = {}

-------------------------------------------------
-- UTILITY: FORCE PED TO GROUND
-------------------------------------------------
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

-------------------------------------------------
-- SPAWN STATIC NPC
-------------------------------------------------
RegisterNetEvent('la_npcs_live:spawnNPC', function(id, data)
    -- Skip spawning if NPC has a vehicle (those are patrol units)
    if data.vehicle then
        if Config.Debug or data.debug then
            print(("[LivingNPCs] Skipping static spawn for %s (patrol unit)."):format(data.name))
        end
        return
    end

    -- Cleanup old instance
    if NPCs[id] and DoesEntityExist(NPCs[id]) then
        DeletePed(NPCs[id])
        NPCs[id] = nil
    end

    local model = GetHashKey(data.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(4, model, data.coords.x, data.coords.y, data.coords.z, data.heading, true, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    ForceGroundAlign(ped)

    if data.emote then
        TaskStartScenarioInPlace(ped, data.emote, 0, true)
    end

    NPCs[id] = ped

    if Config.Debug or data.debug then
        print(("[LivingNPCs] Spawned %s at %.2f %.2f %.2f"):format(data.name, data.coords.x, data.coords.y, data.coords.z))
    end
end)

-------------------------------------------------
-- REMOVE NPC
-------------------------------------------------
RegisterNetEvent('la_npcs_live:removeNPC', function(id)
    if NPCs[id] then
        if DoesEntityExist(NPCs[id]) then DeletePed(NPCs[id]) end
        NPCs[id] = nil
        if Config.Debug then
            print(("[LivingNPCs] Removed NPC ID %s"):format(id))
        end
    end

    if patrolVehicles[id] then
        local pv = patrolVehicles[id]
        if pv.driver and DoesEntityExist(pv.driver) then DeletePed(pv.driver) end
        if pv.passenger and DoesEntityExist(pv.passenger) then DeletePed(pv.passenger) end
        if pv.vehicle and DoesEntityExist(pv.vehicle) then DeleteVehicle(pv.vehicle) end
        patrolVehicles[id] = nil
        if Config.Debug then
            print(("[LivingNPCs] Removed Patrol Unit ID %s"):format(id))
        end
    end
end)

-------------------------------------------------
-- SETUP BLIPS
-------------------------------------------------
RegisterNetEvent('la_npcs_live:setupBlips', function(data)
    for _, npc in pairs(data) do
        if npc.blip then
            local blip = AddBlipForCoord(npc.coords.x, npc.coords.y, npc.coords.z)
            SetBlipSprite(blip, npc.blip.sprite)
            SetBlipDisplay(blip, npc.blip.display)
            SetBlipScale(blip, npc.blip.scale)
            SetBlipColour(blip, npc.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(npc.blip.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-------------------------------------------------
-- INTERACTION LOOP
-------------------------------------------------
CreateThread(function()
    while true do
        local sleep = 1500
        local playerCoords = GetEntityCoords(PlayerPedId())

        for id, ped in pairs(NPCs) do
            if DoesEntityExist(ped) then
                local npcData = Config.NPCS[id]
                local pedCoords = GetEntityCoords(ped)
                local dist = #(playerCoords - pedCoords)

                if dist < 2.0 then
                    DrawSpeechBubble(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, npcData.text)
                    sleep = 0

                    if IsControlJustReleased(0, 38) then -- [E]
                        if npcData.event then
                            TriggerEvent(npcData.event)
                        end

                        if npcData.dialogue then
                            if exports['qbx_core'] then
                                exports['qbx_core']:Notify(npcData.dialogue, "inform")
                            else
                                print("[LivingNPCs] " .. npcData.dialogue)
                            end
                        end

                        if npcData.sound then
                            PlayNPCSound(ped, npcData.sound)
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-------------------------------------------------
-- PLAY SOUND
-------------------------------------------------
function PlayNPCSound(ped, soundName)
    if not DoesEntityExist(ped) then return end
    StopCurrentPlayingAmbientSpeech(ped)
    PlayAmbientSpeech1(ped, soundName, "SPEECH_PARAMS_FORCE_NORMAL")
end

-------------------------------------------------
-- 3D SPEECH BALLOON
-------------------------------------------------
function DrawSpeechBubble(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = #(vec3(px, py, pz) - vec3(x, y, z))
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        local width = string.len(text) / 220.0
        DrawRect(_x, _y + 0.0125, width, 0.03, 0, 0, 0, 150)
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(1)
        SetTextDropshadow(1, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-------------------------------------------------
-- PATROL VEHICLE UNIT (CLEAN FIXED VERSION)
-------------------------------------------------
RegisterNetEvent('la_npcs_live:startPatrol', function(id, data)
    -- Clean any previous patrol of the same ID
    if patrolVehicles[id] then
        local pv = patrolVehicles[id]
        if pv.driver and DoesEntityExist(pv.driver) then DeletePed(pv.driver) end
        if pv.passenger and DoesEntityExist(pv.passenger) then DeletePed(pv.passenger) end
        if pv.vehicle and DoesEntityExist(pv.vehicle) then DeleteVehicle(pv.vehicle) end
        patrolVehicles[id] = nil
    end

    -- Safety: remove any ghost NPCs spawned as static before patrol
    if NPCs[id] and DoesEntityExist(NPCs[id]) then
        DeletePed(NPCs[id])
        NPCs[id] = nil
    end

    local driverModel = GetHashKey(data.model)
    local passengerModel = GetHashKey(data.partner)
    local vehicleModel = GetHashKey(data.vehicle)

    RequestModel(driverModel)
    RequestModel(passengerModel)
    RequestModel(vehicleModel)
    while not HasModelLoaded(driverModel) or not HasModelLoaded(passengerModel) or not HasModelLoaded(vehicleModel) do Wait(0) end

    local veh = CreateVehicle(vehicleModel, data.coords.x, data.coords.y, data.coords.z, data.heading, true, false)
    SetVehicleOnGroundProperly(veh)
    SetVehicleDoorsLocked(veh, 1)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleRadioEnabled(veh, true)
    SetVehRadioStation(veh, "RADIO_16_SILVERLAKE")

    -- Directly spawn peds INSIDE the vehicle (prevents ghost floating issue)
    local driver = CreatePedInsideVehicle(veh, 4, driverModel, -1, true, true)
    local passenger = CreatePedInsideVehicle(veh, 4, passengerModel, 0, true, true)

    -- Safety and immersion settings
    SetEntityInvincible(driver, true)
    SetEntityInvincible(passenger, true)
    SetBlockingOfNonTemporaryEvents(driver, true)
    SetBlockingOfNonTemporaryEvents(passenger, true)
    SetPedAsCop(driver, true)
    SetPedAsCop(passenger, true)

    patrolVehicles[id] = { vehicle = veh, driver = driver, passenger = passenger, route = data.patrolRoute }

    if Config.Debug or data.debug then
        print(("[LivingNPCs] Patrol car '%s' spawned with %d route points."):format(data.name, #data.patrolRoute))
    end

    -- Begin patrol loop
    CreateThread(function()
        local route = data.patrolRoute
        local i = 1
        while DoesEntityExist(veh) and DoesEntityExist(driver) do
            local node = route[i]
            TaskVehicleDriveToCoordLongrange(driver, veh, node.x, node.y, node.z, 12.0, 447, 5.0)
            Wait(node.wait)
            i = i + 1
            if i > #route then i = 1 end
        end
    end)
end)
