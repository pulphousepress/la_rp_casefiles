-- client/main.lua (REPLACEMENT)
-- Prevent repeated SendNUIMessage({ action = "hideUI" }) spam.
-- Behavior:
--  - Press Q (remappable) to open the UI (sends toggle).
--  - Press Q again to cycle station (when UI open).
--  - When leaving a vehicle, only send hideUI once (state change), not every interval.

local radioVisible = false
local currentStationIndex = 0

local KEY_Q = 44           -- Q
local KEY_CLOSE = 44      -- Q

local lastHideSent = 0
local HIDE_COOLDOWN_MS = 1000 -- minimal spacing between hide messages (safety)

local function sendNui(data)
    SendNUIMessage(data)
end

local function openRadio()
    if radioVisible then return end
    radioVisible = true
    sendNui({ action = "toggle" }) -- ask NUI to show
end

local function closeRadio()
    if not radioVisible then return end
    radioVisible = false
    sendNui({ action = "hideUI" })
end

local function cycleStation()
    sendNui({ action = "cycleStation" })
end

-- Key mapping (remappable)
RegisterCommand("+radioCycle", function()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        if not radioVisible then
            openRadio()
        else
            cycleStation()
        end
    end
end, false)
RegisterKeyMapping("+radioCycle", "Cycle custom radio (open if closed)", "keyboard", "Q")

-- Also allow BACKSPACE to close the UI
RegisterCommand("+radioCloseRadio", function()
    if radioVisible then
        closeRadio()
    end
end, false)
RegisterKeyMapping("+radioCloseRadio", "Close custom radio UI", "keyboard", "BACKSPACE")

-- Keep GTA radio suppressed & hide HUD icon (same as before)
CreateThread(function()
    while true do
        Wait(0)
        SetRadioToStationName("OFF")
        SetUserRadioControlEnabled(false)

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if veh and veh ~= 0 then
                SetVehRadioStation(veh, "OFF")
            end
        end

        DisableControlAction(0, 81, true) -- Next radio station
        DisableControlAction(0, 82, true) -- Previous radio station
        DisableControlAction(0, 85, true) -- Radio wheel

        HideHudComponentThisFrame(16)
    end
end)

-- Hide UI when player leaves vehicle — only when state changes
CreateThread(function()
    while true do
        Wait(250) -- more responsive, still cheap
        local ped = PlayerPedId()
        local inVeh = IsPedInAnyVehicle(ped, false)
        -- If not in vehicle and UI is visible -> hide once
        if not inVeh and radioVisible then
            local now = GetGameTimer()
            if (now - lastHideSent) > HIDE_COOLDOWN_MS then
                radioVisible = false
                lastHideSent = now
                sendNui({ action = "hideUI" })
            end
        end
    end
end)
