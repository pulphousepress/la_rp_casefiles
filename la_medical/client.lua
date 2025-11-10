local Config = require("config")

local MedicalClient = {}
local initialized = false

local function mergeConfig(opts)
    if type(opts) ~= 'table' then return end
    for key, value in pairs(opts) do
        Config[key] = value
    end
end

local function revivePlayer()
    local ped = PlayerPedId()
    NetworkResurrectLocalPlayer(Config.reviveCoords.x, Config.reviveCoords.y, Config.reviveCoords.z, 0.0, true, false)
    ClearPedTasksImmediately(ped)
    RemoveAllPedWeapons(ped, true)
    Wait(500)
    TriggerEvent('ox_lib:notify', Config.notify)
    DoScreenFadeIn(Config.fadeDurationMs)
end

function MedicalClient.init(opts)
    if initialized then
        return { ok = true, alreadyInitialized = true }
    end

    mergeConfig(opts)

    AddEventHandler('baseevents:onPlayerDied', function()
        Wait(Config.respawnDelayMs)
        DoScreenFadeOut(Config.fadeDurationMs)
        Wait(1500)
        revivePlayer()
    end)

    initialized = true
    return { ok = true }
end

return MedicalClient
