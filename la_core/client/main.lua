-- client/main.lua inside la_core or your custom resource
local isAppearanceOpen = false

-- /la_status client-side test
RegisterCommand("la_status", function()
    print("[la_core] Active=true")
end, false)


