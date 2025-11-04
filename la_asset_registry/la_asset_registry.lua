-- la_asset_registry.lua
-- Los Animales RP – Era Enforcement System
-- Author: Your Server

---------------------------------------
-- CONFIG + WHITELIST
---------------------------------------

local Config = {}

-- Enforcement Modes: "off", "warn", "block"
Config.EnforcementMode = "block"

-- Duration for popup warnings (ms)
Config.PopupDuration = 6000

-- Whitelisted Vehicles (1950s-60s era)
Config.WhitelistedVehicles = {
    "btype", "btype3", "roosevelt", "roosevelt2", "frankenstange",
    "broadway", "brigham", "hermes", "hustler", "clique", "clique2",
    "blade", "ratloader", "ratloader2", "slamvan", "tornado", "tornado2",
    "tornado3", "tornado4", "tornado5", "tornado6", "peyote", "peyote2",
    "peyote3", "glendale", "journey", "journey2", "surfer", "surfer2",
    "youga2", "youga3", "stafford", "viseris", "stirlinggt", "jb700",
    "jb7002", "casco", "gt500", "monroe", "mamba", "pigalle", "dynasty",
    "savestra", "retinue", "retinue2", "nebula", "vigero", "vamos",
    "dukes", "tulip", "bfinjection", "bodhi2", "kalahari", "winky",
    "flatbed", "tractor", "tractor2", "tractor3", "bus", "coach",
    "taxi", "pbus", "trash", "mixer", "mixer2", "tiptruck", "tiptruck2",
    "policeold1", "policeold2", "sheriff", "sheriff2", "pranger",
    "ambulance", "firetruk",
    -- Exceptions:
    "stretch", "lurcher", "cap58pol", "deluxo", "oppressor", "oppressor2"
}

-- Whitelisted Ped Models
Config.WhitelistedPeds = {
    "s_m_m_postal_01", "s_m_m_postal_02", "s_m_m_gardener_01", "s_m_m_dockwork_01",
    "s_m_m_linecook", "s_m_m_autoshop_02", "s_m_m_pilot_01", "s_m_y_cop_01",
    "s_f_y_cop_01", "s_m_y_hwaycop_01", "s_m_y_fireman_01", "s_m_m_paramedic_01",
    "ig_bankman", "ig_barry", "ig_business_01", "ig_tenniscoach", "ig_tourist_01",
    "ig_vagos_leader", "ig_fbisuit_01", "a_m_m_bevhills_02", "a_f_m_bevhills_02",
    "a_m_y_genstreet_01", "a_f_y_genstreet_01", "csb_reporter", "ig_josef",
    "ig_clay", "ig_lestercrest", "a_m_m_skidrow_01", "u_m_m_jesus_01",
    "u_m_y_imporage", "u_m_y_zombie_01", "ig_orleans", "ig_rustyfox",
    "ig_della_alley", "ig_berry_mason", "ig_sid_light", "ig_crimson_bat",
    "ig_hops_montalvo", "ig_gertie_lark", "u_m_y_abner", "u_m_y_sasquatch",
    "u_m_m_spacegoon_01", "u_m_y_juggernaut_01", "ig_alien_pilot", "ig_void_sentinel",
    "u_m_m_bikehire_01", "u_m_m_streetart_01", "u_m_m_prolsec_01", "ig_admin_char", "ig_event_host"
}

-- Whitelisted Jobs
Config.WhitelistedJobs = {
    "police", "sheriff", "detective", "fire", "ems", "doctor",
    "mechanic", "bartender", "news", "taxi", "butcher",
    "postman", "tailor", "dockworker", "railworker", "carpenter",
    "farmer", "janitor", "banker", "waiter", "conductor",
    "maid", "seamstress", "newspaper", "shopkeeper", "mob",
    "gang", "hustler", "longshoreman", "switchboard", "telegraph",
    "bellboy", "bouncer", "valet", "clerk", "cop"
}

-- Exceptions: Allowed prefixes
Config.ExceptionPrefixes = {
    ["Toon"] = true,
    ["Alien"] = true,
    ["Other"] = true
}

---------------------------------------
-- UTILITIES
---------------------------------------

local recentlyBlocked = {}

local function isWhitelisted(model, list)
    for _, name in ipairs(list) do
        if type(name) == "string" then
            if model == name or model == GetHashKey(name) then return true end
        elseif type(name) == "number" then
            if model == name then return true end
        end
    end
    return false
end

local function isNamespaced(name)
    name = tostring(name or "")
    for prefix in pairs(Config.ExceptionPrefixes) do
        if name:lower():find(prefix:lower(), 1, true) then return true end
    end
    return false
end

local function notifyPlayer(src, msg)
    TriggerClientEvent('la_asset_registry:client:Notify', src, msg, Config.PopupDuration)
end

local function writeLogToFile(msg)
    local file = io.open('asset_blocker.log', 'a')
    if file then
        file:write(os.date('%Y-%m-%d %H:%M:%S') .. ' - ' .. msg .. '\n')
        file:close()
    end
end

local function getSpawnSourceInfo(src, model, entityType)
    local modelName = model
    if entityType == 2 and type(model) == 'number' then
        modelName = GetDisplayNameFromVehicleModel(model) or tostring(model)
    end

    local info = ('[AssetBlocker] Blocked %s: %s'):format(entityType == 2 and "vehicle" or "ped", modelName)

    if src and src > 0 then
        local playerName = GetPlayerName(src)
        if playerName then
            info = info .. string.format(" | By Player: %s (ID %d)", playerName, src)
        else
            info = info .. string.format(" | By Net Owner ID: %d", src)
        end
    else
        info = info .. " | Spawned by: server-side or unknown script"
    end

    return info
end

---------------------------------------
-- SERVER SIDE ENFORCEMENT
---------------------------------------

AddEventHandler('entityCreating', function(entity)
    if Config.EnforcementMode == "off" then return end

    local entityType = GetEntityType(entity)
    local model = GetEntityModel(entity)
    local src = NetworkGetEntityOwner(entity)

    if not DoesEntityExist(entity) or not model then return end

    if recentlyBlocked[model] and (GetGameTimer() - recentlyBlocked[model]) < 3000 then
        CancelEvent()
        return
    end

    recentlyBlocked[model] = GetGameTimer()

    if entityType == 2 then -- Vehicle
        local name = GetDisplayNameFromVehicleModel(model) or tostring(model)
        local allowed = isWhitelisted(name, Config.WhitelistedVehicles) or isNamespaced(name)
        if not allowed then
            local msg = ('🚫 Vehicle blocked: %s'):format(name)
            local log = getSpawnSourceInfo(src, model, entityType)

            if Config.EnforcementMode == "warn" then
                print('[WARN] ' .. msg)
                print(log)
                writeLogToFile(log)
                if src then notifyPlayer(src, msg) end
            elseif Config.EnforcementMode == "block" then
                print('[BLOCK] ' .. msg)
                print(log)
                writeLogToFile(log)
                if src then notifyPlayer(src, msg) end
                CancelEvent()
            end
        end

    elseif entityType == 1 then -- Ped
        local allowed = isWhitelisted(model, Config.WhitelistedPeds) or isNamespaced(model)
        if not allowed then
            local msg = ('🚫 Ped blocked: %s'):format(tostring(model))
            local log = getSpawnSourceInfo(src, model, entityType)

            if Config.EnforcementMode == "warn" then
                print('[WARN] ' .. msg)
                print(log)
                writeLogToFile(log)
                if src then notifyPlayer(src, msg) end
            elseif Config.EnforcementMode == "block" then
                print('[BLOCK] ' .. msg)
                print(log)
                writeLogToFile(log)
                if src then notifyPlayer(src, msg) end
                CancelEvent()
            end
        end
    end
end)

---------------------------------------
-- CLIENT-SIDE POPUPS
---------------------------------------

if not IsDuplicityVersion() then
    RegisterNetEvent('la_asset_registry:client:Notify', function(msg, duration)
        if lib and lib.notify then
            lib.notify({
                title = 'Asset Blocked',
                description = msg,
                type = 'error',
                duration = duration or 6000
            })
        else
            BeginTextCommandThefeedPost("STRING")
            AddTextComponentSubstringPlayerName(msg)
            EndTextCommandThefeedPostTicker(false, duration or 6000)
        end
    end)
end

---------------------------------------
-- RUNTIME EXPORTS
---------------------------------------

exports('SetMode', function(mode)
    if mode == "warn" or mode == "block" or mode == "off" then
        Config.EnforcementMode = mode
        print('[Los Animales] Enforcement mode set to: ' .. mode)
        return true
    else
        print('[Los Animales] Invalid mode passed to SetMode')
        return false
    end
end)

exports('AddVehicleWhitelist', function(name)
    table.insert(Config.WhitelistedVehicles, name)
end)

exports('AddPedWhitelist', function(name)
    table.insert(Config.WhitelistedPeds, name)
end)

exports('AddJobWhitelist', function(name)
    table.insert(Config.WhitelistedJobs, name)
end)

-- Cleanup old block cache
SetInterval(function()
    local now = GetGameTimer()
    for model, time in pairs(recentlyBlocked) do
        if now - time > 300000 then
            recentlyBlocked[model] = nil
        end
    end
end, 300000)
