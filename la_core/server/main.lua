RegisterCommand("la_status", function(source)
    local src = source
    local msg = "[la_core] Active=true"
    if src == 0 then
        print(msg)
    else
        TriggerClientEvent("chat:addMessage", src, { args = { msg } })
    end
end, false)

CreateThread(function()
    print("[la_core] v1.0.2 loaded on server.")
end)
