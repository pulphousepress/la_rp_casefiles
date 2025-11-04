local initialGlobals = {}
for k in pairs(_G) do
    initialGlobals[k] = true
end

local function allow(name)
    initialGlobals[name] = true
end

_G.vector3 = function(x, y, z)
    return setmetatable({ x = x, y = y, z = z }, {
        __sub = function(a, b)
            return vector3(a.x - b.x, a.y - b.y, a.z - b.z)
        end,
        __add = function(a, b)
            return vector3(a.x + b.x, a.y + b.y, a.z + b.z)
        end,
        __len = function(a)
            return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
        end
    })
end
allow('vector3')

_G.Wait = function() end
allow('Wait')
_G.PlayerPedId = function() return 1 end
allow('PlayerPedId')
_G.NetworkResurrectLocalPlayer = function() end
allow('NetworkResurrectLocalPlayer')
_G.ClearPedTasksImmediately = function() end
allow('ClearPedTasksImmediately')
_G.RemoveAllPedWeapons = function() end
allow('RemoveAllPedWeapons')
_G.TriggerEvent = function() end
allow('TriggerEvent')
_G.DoScreenFadeIn = function() end
allow('DoScreenFadeIn')
_G.DoScreenFadeOut = function() end
allow('DoScreenFadeOut')
_G.TaskStartScenarioInPlace = function() end
allow('TaskStartScenarioInPlace')
_G.TaskWanderStandard = function() end
allow('TaskWanderStandard')
_G.SetPedKeepTask = function() end
allow('SetPedKeepTask')
_G.RequestModel = function() end
allow('RequestModel')
_G.HasModelLoaded = function() return true end
allow('HasModelLoaded')
_G.CreatePed = function() return 1 end
allow('CreatePed')
_G.SetEntityAsNoLongerNeeded = function() end
allow('SetEntityAsNoLongerNeeded')
_G.GetGamePool = function() return {} end
allow('GetGamePool')
_G.DoesEntityExist = function() return false end
allow('DoesEntityExist')
_G.IsPedAPlayer = function() return false end
allow('IsPedAPlayer')
_G.GetEntityCoords = function() return vector3(0, 0, 0) end
allow('GetEntityCoords')
_G.IsPedInAnyVehicle = function() return false end
allow('IsPedInAnyVehicle')
_G.DeleteEntity = function() end
allow('DeleteEntity')
_G.math.randomseed(os.time())
_G.math.random = function(min, max)
    if not max then
        return min and (min * 0.5) or 0
    end
    return (min + max) / 2
end
_G.joaat = function(v) return v end
allow('joaat')
_G.CreateThread = function(fn) fn() end
allow('CreateThread')
_G.RegisterCommand = function() end
allow('RegisterCommand')
_G.RegisterNetEvent = function() end
allow('RegisterNetEvent')
_G.TriggerClientEvent = function() end
allow('TriggerClientEvent')
_G.TriggerServerEvent = function() end
allow('TriggerServerEvent')
_G.AddEventHandler = function() end
allow('AddEventHandler')
_G.IsPlayerAceAllowed = function() return false end
allow('IsPlayerAceAllowed')
_G.GetCurrentResourceName = function() return 'la_npcs' end
allow('GetCurrentResourceName')
_G.LoadResourceFile = function()
    return '{}'
end
allow('LoadResourceFile')
_G.json = { decode = function() return {} end }
allow('json')
_G.lib = {
    callback = {
        await = function() return {} end,
        register = function() end
    }
}
allow('lib')

_G.SetNuiFocus = function() end
allow('SetNuiFocus')
_G.SendNUIMessage = function() end
allow('SendNUIMessage')
_G.RegisterNUICallback = function(_, cb)
    if cb then cb('ok') end
end
allow('RegisterNUICallback')
_G.RegisterKeyMapping = function() end
allow('RegisterKeyMapping')
_G.GetPlayerName = function()
    return 'unit-test-player'
end
allow('GetPlayerName')

_G.exports = {
    oxmysql = {
        execute = function(_, _, cb)
            if cb then cb({ affectedRows = 0 }) end
        end,
        executeSync = function()
            return {}
        end
    },
    ox_inventory = {
        GetPlayer = function()
            return {
                job = { name = 'police' },
                Search = function()
                    return true
                end,
                RemoveItem = function() end,
                GetInventory = function() return {} end
            }
        end
    }
}
allow('exports')

local M = {}

function M.assertNoNewGlobals()
    for k in pairs(_G) do
        if not initialGlobals[k] and not tostring(k):match('^_ENV') then
            error('Global leaked: ' .. tostring(k))
        end
    end
end

return M
