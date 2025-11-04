local Config = require("config")

local NPCClient = {}
local whitelist = {}
local modelsByCategory = {}
local zonePeds = {}
local initialized = false

local function emitLog(level, message)
    if Config.Debug then
        print(string.format("[la_npcs][%s] %s", level, message))
    end
end

local function count(tbl)
    local c = 0
    for _ in pairs(tbl) do c = c + 1 end
    return c
end

local function loadPeds()
    local dbPeds = lib.callback.await("la_npcs:getWhitelist", false)
    if dbPeds and #dbPeds > 0 then
        whitelist = { all = dbPeds }
        modelsByCategory.all = {}
        for _, name in ipairs(dbPeds) do
            modelsByCategory.all[joaat(name)] = name
        end
        emitLog("info", ("Loaded %d models from DB whitelist."):format(#dbPeds))
        return true
    end

    local raw = LoadResourceFile(GetCurrentResourceName(), Config.PedsFile)
    if not raw then
        emitLog("error", "Missing " .. Config.PedsFile)
        return false
    end
    local ok, result = pcall(json.decode, raw)
    if not ok or type(result) ~= "table" then
        emitLog("error", "Failed to parse JSON whitelist")
        return false
    end
    whitelist = result
    modelsByCategory = {}
    for cat, list in pairs(whitelist) do
        modelsByCategory[cat] = {}
        for _, name in ipairs(list) do
            modelsByCategory[cat][joaat(name)] = name
        end
    end
    emitLog("info", ("Loaded %d categories from JSON."):format(count(whitelist)))
    return true
end

local function inZone(coords, zone)
    return #(coords - zone.center) < zone.radius
end

local function getRandomModel(categories)
    local pool = {}
    for _, cat in ipairs(categories) do
        if whitelist[cat] then
            for _, name in ipairs(whitelist[cat]) do
                pool[#pool+1] = name
            end
        elseif whitelist.all then
            for _, name in ipairs(whitelist.all) do
                pool[#pool+1] = name
            end
        end
    end
    if #pool > 0 then
        return pool[math.random(#pool)]
    end
end

local function givePedBehavior(ped, zone)
    if zone.scenarios and #zone.scenarios > 0 and math.random() < 0.6 then
        TaskStartScenarioInPlace(ped, zone.scenarios[math.random(#zone.scenarios)], 0, true)
    else
        TaskWanderStandard(ped, 10.0, 10)
    end
    SetPedKeepTask(ped, true)
end

local function spawnReplacementPed(zone, coords)
    local modelName = getRandomModel(zone.categories)
    if not modelName then return end
    local model = joaat(modelName)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, 0.0, true, false)
    SetEntityAsNoLongerNeeded(ped)
    givePedBehavior(ped, zone)

    zonePeds[zone.name] = zonePeds[zone.name] or {}
    table.insert(zonePeds[zone.name], ped)

    emitLog("debug", ("Replaced ped with %s in %s"):format(modelName, zone.name))
end

local function filterLoop()
    while true do
        Wait(Config.CheckInterval)
        if not Config.Enable then goto continue end
        for _, ped in ipairs(GetGamePool("CPed")) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                local coords = GetEntityCoords(ped)
                for _, zone in ipairs(Config.Zones) do
                    if inZone(coords, zone) then
                        local model = GetEntityModel(ped)
                        local allowed = false
                        for _, cat in ipairs(zone.categories) do
                            if modelsByCategory[cat] and modelsByCategory[cat][model] then
                                allowed = true
                                break
                            end
                        end
                        if not allowed and not IsPedInAnyVehicle(ped, false) then
                            DeleteEntity(ped)
                            spawnReplacementPed(zone, coords)
                        end
                    end
                end
            end
        end
        ::continue::
    end
end

local function spawnLoop()
    while true do
        Wait(Config.CheckInterval)
        if not Config.Enable then goto continue end
        for _, zone in ipairs(Config.Zones) do
            zonePeds[zone.name] = zonePeds[zone.name] or {}
            local currentCount = #zonePeds[zone.name]
            local maxPeds = zone.density and zone.density.max or Config.MaxZonePeds
            local spawnRate = zone.density and zone.density.rate or Config.SpawnRate
            if currentCount < maxPeds then
                for _ = 1, spawnRate do
                    local modelName = getRandomModel(zone.categories)
                    if modelName then
                        local model = joaat(modelName)
                        RequestModel(model)
                        while not HasModelLoaded(model) do Wait(10) end
                        local offset = zone.center + vector3(
                            math.random(-Config.SpawnRadius, Config.SpawnRadius),
                            math.random(-Config.SpawnRadius, Config.SpawnRadius),
                            0.0)
                        local ped = CreatePed(4, model, offset.x, offset.y, offset.z, 0.0, true, false)
                        SetEntityAsNoLongerNeeded(ped)
                        givePedBehavior(ped, zone)
                        table.insert(zonePeds[zone.name], ped)
                        emitLog("debug", ("Spawned %s in %s"):format(modelName, zone.name))
                    end
                end
            end
        end
        ::continue::
    end
end

local function validateConfig()
    if type(Config.Zones) ~= "table" or #Config.Zones == 0 then
        return false, "Config.Zones is required"
    end
    return true
end

function NPCClient.init(opts)
    if initialized then
        return { ok = true, alreadyInitialized = true }
    end

    if type(opts) == "table" then
        for key, value in pairs(opts) do
            Config[key] = value
        end
    end

    local ok, err = validateConfig()
    if not ok then
        return { ok = false, err = err }
    end

    if not loadPeds() then
        return { ok = false, err = "Failed to load whitelist" }
    end

    CreateThread(filterLoop)
    CreateThread(spawnLoop)

    initialized = true
    emitLog("info", "Client NPC controller initialized")
    return { ok = true }
end

return NPCClient
