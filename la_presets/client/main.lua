local debug = Config.Debug

-- Command + Keybind to open Illenium Appearance with Los Animales presets
RegisterCommand("la_skin", function()
    exports['illenium-appearance']:startPlayerCustomization(function(appearance)
        if appearance then
            TriggerServerEvent("illenium-appearance:server:saveAppearance", appearance)
            if debug then print("[la_presets] Appearance saved.") end
        else
            if debug then print("[la_presets] Appearance canceled.") end
        end
    end, {
        ped = true,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        tattoos = true,
        outfits = Config.Presets
    })
end, false)

RegisterKeyMapping("la_skin", "Open Los Animales Presets", "keyboard", "F4")

-- Debug test command
RegisterCommand("la_presets_status", function()
    print("[la_presets] Loaded presets for Male:", #Config.Presets.Male, " Female:", #Config.Presets.Female)
end, false)
