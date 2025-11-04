-- client/main.lua (la_core client helper)
-- Local state only, no globals
local client = {}
local isAppearanceOpen = false
local lastCodexVersion = "unknown"

-- safe print wrapper (toggle debug easily)
local function dbg(...)
    print("[la_core:client]", ...)
end

-- Open/close appearance NUI (safe: checks before calling NUI)
local function openAppearance()
    if isAppearanceOpen then return false, "already_open" end
    isAppearanceOpen = true
    -- If you have an NUI, this will focus it. If not, this is harmless (no NUI).
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openAppearance" })
    dbg("Appearance opened")
    return true
end

local function closeAppearance()
    if not isAppearanceOpen then return false, "not_open" end
    isAppearanceOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeAppearance" })
    dbg("Appearance closed")
    return true
end

-- Toggle function (public)
client.toggleAppearance = function()
    if isAppearanceOpen then
        return closeAppearance()
    else
        return openAppearance()
    end
end

-- Client command: /la_status
-- prints client-side status and attempts to request server-side status
RegisterCommand("la_status", function()
    dbg("Active=true; appearance_open=" .. tostring(isAppearanceOpen) .. "; codex_version=" .. tostring(lastCodexVersion))

    -- Try to request server status via an event. Server snippet below (optional).
    local requested = false
    local cbName = "la_core:client:statusCallback_" .. tostring(math.random(100000,999999))
    AddEventHandler(cbName, function(tbl)
        -- Basic defensive validation
        if type(tbl) == "table" then
            dbg("Server status:", tbl.server or "nil", "codex_version:", tbl.codex_version or "nil")
        else
            dbg("Server status callback received unexpected type")
        end
    end)
    -- Fire server event with callback name - server can TriggerClientEvent(cbName, source, payload)
    TriggerServerEvent("la_core:server:requestStatus", cbName)
end, false)

-- Listen for server-initiated codex version update (optional)
-- The server may broadcast `la_core:ClientCodexLoaded` with a payload { version = "x.y.z" }
RegisterNetEvent("la_core:ClientCodexLoaded")
AddEventHandler("la_core:ClientCodexLoaded", function(payload)
    if type(payload) == "table" and payload.version then
        lastCodexVersion = tostring(payload.version)
        dbg("Client noticed codex load; version=", lastCodexVersion)
    else
        dbg("Client received la_core:ClientCodexLoaded with invalid payload")
    end
end)

-- NUI callback handler (if you implement NUI)
RegisterNUICallback("close", function(data, cb)
    closeAppearance()
    cb({ ok = true })
end)

-- Exported functions for other client resources
exports("IsAppearanceOpen", function() return isAppearanceOpen end)
exports("ToggleAppearance", function() return client.toggleAppearance() end)

-- Client ready message
CreateThread(function()
    Wait(500) -- give some time for resource startup
    dbg("client helper ready")
end)
