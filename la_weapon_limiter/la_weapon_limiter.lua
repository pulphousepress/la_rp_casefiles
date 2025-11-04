local Config = require("config")
local SharedStore = require("ph_shared").new("la_weapon_limiter")

local WeaponLimiter = {}

local function mergeConfig(opts)
    if type(opts) ~= 'table' then return end
    for key, value in pairs(opts) do
        Config[key] = value
    end
end

local function notify(source, msg, kind)
    TriggerClientEvent('ox_lib:notify', source, {
        type = kind or 'error',
        description = msg,
        duration = 5000
    })
end

local function isAllowed(job, weapon)
    local cacheKey = string.format("allow:%s:%s", job or 'unknown', weapon or 'unknown')
    local cached = SharedStore:get(cacheKey)
    if cached.ok and cached.value ~= nil then
        return cached.value
    end

    local list = Config.WeaponJobWhitelist[job]
    local allowed = false
    if list then
        for _, v in pairs(list) do
            if v == weapon then
                allowed = true
                break
            end
        end
    end

    SharedStore:set(cacheKey, allowed)
    return allowed
end

local function stripWeapon(src, weapon)
    local xPlayer = exports.ox_inventory:GetPlayer(src)
    if not xPlayer then return end
    local ok, has = pcall(function()
        return xPlayer:Search('weapon', weapon)
    end)
    if not ok then
        notify(src, 'Unable to verify weapon ownership', 'error')
        return
    end
    if has then
        xPlayer:RemoveItem('weapon', weapon, 1)
        notify(src, "That weapon is not authorized for your job.")
    end
end

local function onWeaponEquipped(weapon)
    local src = source
    local xPlayer = exports.ox_inventory:GetPlayer(src)
    if not xPlayer then return end

    local job = xPlayer.job and xPlayer.job.name or 'unemployed'
    local weaponName = string.upper(weapon)
    local allowed = isAllowed(job, weaponName)

    if Config.Mode == "off" then return end

    if not allowed then
        if Config.Mode == "warn" then
            notify(src, "⚠️ This weapon is not authorized for your current job.", 'warning')
        elseif Config.Mode == "block" then
            notify(src, "❌ Weapon blocked: not allowed for your job.")
            CancelEvent()
        elseif Config.Mode == "strip" then
            stripWeapon(src, weaponName)
        end
    end
end

local function recheckInventory(_, newJob)
    local src = source
    Wait(500)
    local xPlayer = exports.ox_inventory:GetPlayer(src)
    if not xPlayer then return end

    local inventory = xPlayer:GetInventory()
    for _, item in pairs(inventory) do
        if item.name and item.name:find("WEAPON_") then
            local weaponName = string.upper(item.name)
            if not isAllowed(newJob.name, weaponName) then
                if Config.Mode == "strip" then
                    xPlayer:RemoveItem('weapon', weaponName, 1)
                    notify(src, weaponName .. " removed due to job restriction.")
                elseif Config.Mode == "warn" then
                    notify(src, weaponName .. " is not allowed for your job.", 'warning')
                end
            end
        end
    end
end

function WeaponLimiter.init(opts)
    mergeConfig(opts)

    RegisterNetEvent('ox_inventory:weaponEquipped', onWeaponEquipped)
    RegisterNetEvent('QBCore:Server:OnJobUpdate', recheckInventory)

    print('[la_weapon_limiter] enforcement mode: ' .. Config.Mode)
    return { ok = true }
end

WeaponLimiter.init(Config)

return WeaponLimiter
