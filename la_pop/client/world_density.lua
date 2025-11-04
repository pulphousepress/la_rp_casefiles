-- Pulphouse Press – World Density Manager
CreateThread(function()
    while true do
        local d = Config.Density
        SetVehicleDensityMultiplierThisFrame(d.Vehicles)
        SetPedDensityMultiplierThisFrame(d.Peds)
        SetRandomVehicleDensityMultiplierThisFrame(d.Vehicles)
        SetParkedVehicleDensityMultiplierThisFrame(d.ParkedVehicles)
        SetScenarioPedDensityMultiplierThisFrame(d.Scenarios, d.Scenarios)
        Wait(1000)
    end
end)
