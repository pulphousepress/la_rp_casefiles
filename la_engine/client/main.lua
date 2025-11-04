-- la_engine client stub
RegisterNetEvent('la_engine:ClientSpawnVehicle', function(model, coords)
    print('[la_engine - client] spawn vehicle event received: ' .. tostring(model))
    -- client spawn code would go here; left as an exercise for the real engine
    -- Example: TriggerEvent('vehicle:spawn', model, coords)
end)
