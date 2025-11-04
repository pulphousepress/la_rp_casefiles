local uiVisible = false

local function ToggleUI(state)
    uiVisible = state
    SetNuiFocus(state, state)
    SendNUIMessage({ action = "toggle", show = state })
    if Config.Debug then
        print("[la_admin] UI=" .. tostring(uiVisible))
    end
end

-- Toggle with F10
RegisterCommand("+la_admin_toggle", function()
    ToggleUI(not uiVisible)
end, false)
RegisterKeyMapping("+la_admin_toggle", "Toggle Admin Console", "keyboard", Config.ToggleKey)

-- Close NUI
RegisterNUICallback("close", function(_, cb)
    ToggleUI(false)
    cb("ok")
end)

-- Event passthrough
RegisterNUICallback("triggerEvent", function(data, cb)
    if Config.Debug then
        print("[la_admin] Event → " .. tostring(data.event))
    end
    TriggerServerEvent("la_admin:consoleEvent", data.event, data.args or {})
    cb("ok")
end)

-- Debug
RegisterCommand("la_debug", function()
    print("[la_admin] Console Visible=" .. tostring(uiVisible))
end, false)
