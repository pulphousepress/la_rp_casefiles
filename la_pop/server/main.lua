-- la_population/server/main.lua
local patrolStarted = false

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        print('[LA_POPULATION] Resource started, syncing all players...')
        Wait(2000)
        SyncNPCsToAll()
    end
end)

AddEventHandler('playerJoining', function()
    local src = source; Wait(3000); SyncNPCsToPlayer(src)
end)

function SyncNPCsToPlayer(player)
    for id, npcData in ipairs(Config.NPCS) do
        if not npcData.vehicle then
            TriggerClientEvent('la_population:spawnNPC', player, id, npcData)
        end
    end
    TriggerClientEvent('la_population:setupBlips', player, Config.NPCS)
    if not patrolStarted then patrolStarted = true; StartAllPatrols() end
end

function SyncNPCsToAll()
    for _, p in ipairs(GetPlayers()) do SyncNPCsToPlayer(tonumber(p)) end
end

function StartAllPatrols()
    for id, npcData in ipairs(Config.NPCS) do
        if npcData.vehicle then
            TriggerClientEvent('la_population:startPatrol', -1, id, npcData)
            print(("[LA_POPULATION] Patrol route started for %s"):format(npcData.name))
        end
    end
end

RegisterCommand('la_pop_debug', function(src)
    Config.Debug = not Config.Debug
    local s = Config.Debug and '^2ON^7' or '^1OFF^7'
    print('[LA_POPULATION] Debug: ' .. s)
end, true)

RegisterCommand('la_pop_resync', function(src)
    print('[LA_POPULATION] Manual resync triggered.')
    SyncNPCsToAll()
end, true)

RegisterCommand('la_pop_clear', function(src)
    print('[LA_POPULATION] Clearing all NPCs.')
    TriggerClientEvent('la_population:removeNPC', -1, -1)
    patrolStarted = false
end, true)
