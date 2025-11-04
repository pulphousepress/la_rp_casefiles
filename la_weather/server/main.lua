local currentWeather = "RAIN"

-- sync helper
local function syncWeather()
    TriggerClientEvent("la_weather:update", -1, currentWeather)
    if Config.Debug then
        print("[la_weather] Sync -> "..currentWeather)
    end
end

-- noir cycle
CreateThread(function()
    if not Config.Enable then return end
    Wait(2000)
    print("[la_weather] Server active (noir cycle)")
    while true do
        Wait(Config.TickSeconds * 1000)
        local pick = Config.NoirWeathers[math.random(#Config.NoirWeathers)]
        if pick ~= currentWeather then
            currentWeather = pick
            syncWeather()
        end
    end
end)

-- resync on join
AddEventHandler("playerJoining", function()
    local src = source
    TriggerClientEvent("la_weather:update", src, currentWeather)
end)
