RegisterCommand('testped', function()
    local model = `ig_mrwolf`
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(0)
    end

    local coords = GetEntityCoords(PlayerPedId())
    local ped = CreatePed(4, model, coords.x, coords.y + 2.0, coords.z, 0.0, true, false)
    print("Spawned ig_mrwolf!")
end, false)
