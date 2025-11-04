local InToontown, InVinewood, InSandy = false, false, false
local globalWeather = "RAIN"
local uiVisible = false

-- zone checks
local function inToontown(coords)
    return #(coords - Config.ToontownCenter) < Config.ToontownRadius
end

local function inVinewood(coords)
    return coords.y >= Config.VinewoodY and coords.y < Config.SandyY
end

local function inSandy(coords)
    return coords.y >= Config.SandyY
end

local function setWeather(preset)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypeNowPersist(preset)
    SetWeatherTypeNow(preset)
    SetOverrideWeather(preset)
    if Config.Debug then print("[la_weather] Applied "..preset) end
end

-- receive global weather
RegisterNetEvent("la_weather:update", function(wType)
    globalWeather = wType
    if not (InToontown or InVinewood or InSandy) then
        setWeather(globalWeather)
    end
end)

-- force time lock
CreateThread(function()
    while true do
        Wait(2000)
        if Config.LockTime then
            NetworkOverrideClockTime(Config.TimeHour, Config.TimeMinute, 0)
        end
    end
end)

-- zone overrides
CreateThread(function()
    while true do
        Wait(5000)
        if not Config.Enable then goto continue end

        local coords = GetEntityCoords(PlayerPedId())
        local t, v, s = inToontown(coords), inVinewood(coords), inSandy(coords)

        if t and not InToontown then
            InToontown, InVinewood, InSandy = true, false, false
            setWeather(Config.ToonWeather)
            if Config.Debug then print("[la_weather] Entered Toontown -> "..Config.ToonWeather) end

        elseif v and not InVinewood then
            InVinewood, InToontown, InSandy = true, false, false
            local pick = Config.VinewoodWeather[math.random(#Config.VinewoodWeather)]
            setWeather(pick)
            if Config.Debug then print("[la_weather] Entered Vinewood Zone -> "..pick) end

        elseif s and not InSandy then
            InSandy, InToontown, InVinewood = true, false, false
            local pick = Config.SandyWeather[math.random(#Config.SandyWeather)]
            setWeather(pick)
            if Config.Debug then print("[la_weather] Entered Sandy Zone -> "..pick) end

        elseif (not t and InToontown) or (not v and InVinewood) or (not s and InSandy) then
            InToontown, InVinewood, InSandy = false, false, false
            setWeather(globalWeather)
            if Config.Debug then print("[la_weather] Zone reset -> "..globalWeather) end
        end

        ::continue::
    end
end)

-- UI monitor
local function updateUI()
    local zone = "Global"
    local weather = globalWeather

    if InToontown then
        zone = "Toontown"
        weather = Config.ToonWeather
    elseif InVinewood then
        zone = "Vinewood Zone"
        weather = "Stormy"
    elseif InSandy then
        zone = "Sandy Zone"
        weather = "Extreme"
    end

    local hour = GetClockHours()
    local minute = GetClockMinutes()
    local timeStr = string.format("%02d:%02d", hour, minute)

    SendNUIMessage({
        action  = "updateWeather",
        zone    = zone,
        weather = weather,
        clock   = timeStr
    })
end

RegisterCommand("weather_check", function()
    uiVisible = not uiVisible
    SetNuiFocus(false, false)
    print("[la_weather] /weather_check toggled -> " .. tostring(uiVisible))
    SendNUIMessage({
        action = "toggle",
        show = uiVisible
    })
    if uiVisible then updateUI() end
end, false)

-- refresh monitor
CreateThread(function()
    while true do
        Wait(5000)
        if uiVisible then updateUI() end
    end
end)
