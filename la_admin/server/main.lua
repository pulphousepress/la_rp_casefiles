CreateThread(function()
    print("[la_admin] v1.2.0 Dispatch Console loaded.")
end)

RegisterNetEvent("la_admin:consoleEvent", function(event, args)
    local src = source
    print(("[la_admin] %s triggered %s %s"):format(GetPlayerName(src), event, json.encode(args)))
    -- TODO: Wire into la_weather, la_masks, la_era_vehicles, etc.
end)
