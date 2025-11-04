-- Los Animales Loadscreen shutdown controller
-- - Kills Rockstar loading screen early (prevents 1-frame flash)
-- - Keeps a short black fade while NUI closes, then fades in the world
-- - Still supports manual close via event and playerSpawned

local closed = false

local function killRockstarLS()
    -- Remove the vanilla GTA loading screen ASAP
    ShutdownLoadingScreen()
end

local function closeNuiLS()
    if closed then return end
    closed = true
    ShutdownLoadingScreenNui()
end

local function closeAllWithFade()
    if closed then return end

    -- Fade to black immediately so nothing flashes
    DoScreenFadeOut(0)

    -- Make sure the vanilla screen is gone, then close NUI
    killRockstarLS()
    closeNuiLS()

    -- Small grace to let scene settle, then fade back in
    Wait(200)
    DoScreenFadeIn(800)
end

-- 1) As soon as the map is starting, kill the vanilla loadscreen to avoid a peek/flash
AddEventHandler('onClientMapStart', function()
    killRockstarLS()
end)

-- 2) Standard path: when session is up + small buffer, close with fade
CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(100)
    end
    -- Let other resources initialize a moment
    Wait(1200)
    closeAllWithFade()
end)

-- 3) Also close on first spawn (some frameworks signal readiness this way)
AddEventHandler('playerSpawned', function()
    closeAllWithFade()
end)

-- 4) Allow server/admin/manual close if needed
RegisterNetEvent('la:loadscreen:close', function()
    closeAllWithFade()
end)
