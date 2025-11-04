-- la_npcs_live / server/main.lua
-- Los Animales RP — Living NPCs Server Sync + Patrol Handler (fixed version)

-------------------------------------------------
-- RESOURCE INITIALIZATION
-------------------------------------------------
local patrolStarted = false

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        print('^3[LivingNPCs]^7 Resource started, syncing all active players...')
        Wait(2000)
        SyncNPCsToAll()
    end
end)

-------------------------------------------------
-- PLAYER JOIN HANDLER
-------------------------------------------------
AddEventHandler('playerJoining', function()
    local src = source
    Wait(3000)
    SyncNPCsToPlayer(src)
end)

-------------------------------------------------
-- SYNC ALL NPCS TO PLAYER
-------------------------------------------------
function SyncNPCsToPlayer(player)
    -- 1. Spawn all *static* NPCs (those without vehicles)
    for id, npcData in ipairs(Config.NPCS) do
        if not npcData.vehicle then
            TriggerClientEvent('la_npcs_live:spawnNPC', player, id, npcData)
        end
    end

    -- 2. Send blips for all NPCs
    TriggerClientEvent('la_npcs_live:setupBlips', player, Config.NPCS)

    -- 3. Start patrols once globally
    if not patrolStarted then
        patrolStarted = true
        StartAllPatrols()
    end

    if Config.Debug then
        print(("^2[LivingNPCs]^7 Synced NPCs to player ID %s."):format(player))
    end
end

-------------------------------------------------
-- SYNC TO ALL PLAYERS
-------------------------------------------------
function SyncNPCsToAll()
    local players = GetPlayers()
    for _, player in ipairs(players) do
        SyncNPCsToPlayer(tonumber(player))
    end
end

-------------------------------------------------
-- START ALL PATROLS (GLOBAL)
-------------------------------------------------
function StartAllPatrols()
    for id, npcData in ipairs(Config.NPCS) do
        if npcData.vehicle then
            TriggerClientEvent('la_npcs_live:startPatrol', -1, id, npcData)
            if Config.Debug then
                print(("[LivingNPCs] Patrol route started for %s"):format(npcData.name))
            end
        end
    end
end

-------------------------------------------------
-- DEBUG COMMANDS
-------------------------------------------------
RegisterCommand('la_npcs_debug', function(src)
    Config.Debug = not Config.Debug
    local state = Config.Debug and '^2ON^7' or '^1OFF^7'
    print('[LivingNPCs] Debug mode toggled to ' .. state)
    if src > 0 then
        TriggerClientEvent('chat:addMessage', src, { args = { '^3[LivingNPCs]^0', 'Debug mode: ' .. state } })
    end
end, true)

RegisterCommand('la_npcs_resync', function(src)
    print('[LivingNPCs] Manual resync triggered.')
    SyncNPCsToAll()
    if src > 0 then
        TriggerClientEvent('chat:addMessage', src, { args = { '^3[LivingNPCs]^0', 'Resync complete.' } })
    end
end, true)

RegisterCommand('la_npcs_clear', function(src)
    print('[LivingNPCs] Clearing all NPCs and vehicles...')
    TriggerClientEvent('la_npcs_live:removeNPC', -1, -1)
    patrolStarted = false
end, true)
