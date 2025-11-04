-- Handles interactions and speech bubbles
local NPCs = {}

CreateThread(function()
    while true do
        local sleep = 1500
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        for id, ped in pairs(NPCs) do
            if DoesEntityExist(ped) then
                local data = Config.NPCS[id]
                local dist = #(coords - data.coords)
                if dist < 2.0 then
                    sleep = 0
                    DrawSpeechBubble(data.coords.x, data.coords.y, data.coords.z + 1.0, data.text)
                    if IsControlJustReleased(0, 38) then
                        if data.dialogue then
                            if exports['qbx_core'] then exports['qbx_core']:Notify(data.dialogue, "inform")
                            else print("[LA_POP] " .. data.dialogue) end
                        end
                        if data.sound then PlayAmbientSpeech1(ped, data.sound, "SPEECH_PARAMS_FORCE_NORMAL") end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

function DrawSpeechBubble(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    if not onScreen then return end
    SetTextScale(0.3,0.3); SetTextFont(0); SetTextProportional(1)
    SetTextColour(255,255,255,255); SetTextCentre(1)
    SetTextEntry("STRING"); AddTextComponentString(text); DrawText(_x,_y)
end
