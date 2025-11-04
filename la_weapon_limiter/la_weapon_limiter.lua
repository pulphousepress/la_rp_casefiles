-- la_weapon_limiter.lua
-- Author: Los Animales RP
-- Description: Restrict weapon usage to era-appropriate jobs only

local Config = {}

-- Enforcement mode:
-- "off"   = disable
-- "warn"  = allow but notify
-- "block" = prevent equipping
-- "strip" = remove the weapon entirely
Config.Mode = "block"

-- Job → Weapon list mapping (WEAPON_ names)
Config.WeaponJobWhitelist = {
    police = {
        "WEAPON_PISTOL",
        "WEAPON_REVOLVER",
        "WEAPON_FLARE",
        "WEAPON_PUMPSHOTGUN",
        "WEAPON_BAT"
    },
    detective = {
        "WEAPON_PISTOL",
        "WEAPON_DOUBLEACTION",
        "WEAPON_KNUCKLE",
    },
    mob = {
        "WEAPON_GUSENBERG",
        "WEAPON_SAWNOFFSHOTGUN",
        "WEAPON_CLEAVER",
        "WEAPON_SWITCHBLADE"
    },
    fire = {
        "WEAPON_HATCHET",
        "WEAPON_FLARE"
    },
    farmer = {
        "WEAPON_MUSKET",
        "WEAPON_HATCHET"
    },
    bartender = {
        "WEAPON_KNIFE",
        "WEAPON_BAT"
    },
}

-- Messages
local function notify(source, msg)
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'error',
        description = msg,
        duration = 5000
    })
end

-- Check if weapon is allowed for job
local function isAllowed(job, weapon)
    local list = Config.WeaponJobWhitelist[job]
    if not list then return false end
    for _, v in pairs(list) do
        if v == weapon then return true end
    end
    return false
end

-- Strip weapon if needed
local function stripWeapon(src, weapon)
    local xPlayer = exports.ox_inventory:GetPlayer(src)
    if not xPlayer then return end
    local has = xPlayer:Search('weapon', weapon)
    if has then
        xPlayer:RemoveItem('weapon', weapon, 1)
        notify(src, "That weapon is not authorized for your job.")
    end
end

-- On weapon equipped
RegisterNetEvent('ox_inventory:weaponEquipped', function(weapon)
    local src = source
    local xPlayer = exports.ox_inventory:GetPlayer(src)
    if not xPlayer then return end

    local job = xPlayer.job.name
    local weaponName = string.upper(weapon)

    local allowed = isAllowed(job, weaponName)

    if Config.Mode == "off" then return end

    if not allowed then
        if Config.Mode == "warn" then
            notify(src, "⚠️ This weapon is not authorized for your current job.")
        elseif Config.Mode == "block" then
            notify(src, "❌ Weapon blocked: not allowed for your job.")
            CancelEvent()
        elseif Config.Mode == "strip" then
            stripWeapon(src, weaponName)
        end
    end
end)

-- Recheck inventory on job change (recommended)
RegisterNetEvent('QBCore:Server:OnJobUpdate', function(sourceJob, newJob)
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
                    notify(src, weaponName .. " is not allowed for your job.")
                end
            end
        end
    end
end)
