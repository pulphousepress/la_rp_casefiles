-- client.lua
-- 1950s Basic Hospital Revive for Los Animales RP

local reviveCoords = vector3(354.23, -1403.25, 32.5) -- Pillbox (adjust if you want county hospital)

AddEventHandler('baseevents:onPlayerDied', function()
    Wait(10000) -- Time unconscious
    DoScreenFadeOut(1000)
    Wait(1500)

    -- Move player to hospital
    local ped = PlayerPedId()
    NetworkResurrectLocalPlayer(reviveCoords.x, reviveCoords.y, reviveCoords.z, 0.0, true, false)
    ClearPedTasksImmediately(ped)
    RemoveAllPedWeapons(ped, true)

    Wait(500)
    TriggerEvent('ox_lib:notify', {
        title = 'Revived at Hospital',
        description = 'You were treated by a local doctor.',
        type = 'inform'
    })

    DoScreenFadeIn(1000)
end)
