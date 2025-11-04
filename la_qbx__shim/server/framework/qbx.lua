-- server/framework/qbx.lua
---@diagnostic disable: undefined-global
local Framework = {}

-- Safe wrapper to call qbx_core:GetPlayer
function Framework.GetPlayer(src)
    if exports and exports.qbx_core then
        local ok, res = pcall(function() return exports.qbx_core:GetPlayer(src) end)
        if ok then return res end
    end
    return nil
end

-- Inventory helpers (ox_inventory)
function Framework.HasItem(src, item, amount)
    amount = amount or 1
    if exports and exports.ox_inventory then
        local ok, count = pcall(function() return exports.ox_inventory:Search(src, 'count', item) end)
        if ok and type(count) == "number" then
            return count >= amount
        end
    end
    return false
end

function Framework.AddItem(src, item, amount, metadata)
    if exports and exports.ox_inventory then
        local ok, res = pcall(function() return exports.ox_inventory:AddItem(src, item, amount or 1, metadata) end)
        if ok then return res end
    end
    return false
end

function Framework.RemoveItem(src, item, amount)
    if exports and exports.ox_inventory then
        local ok, res = pcall(function() return exports.ox_inventory:RemoveItem(src, item, amount or 1) end)
        if ok then return res end
    end
    return false
end

-- Try a list of common exported function names to obtain a character id
local function tryExportsGetCid(source)
    if not exports or not exports.qbx_core then return nil end
    local tries = {
        function() return exports.qbx_core:GetCharId(source) end,
        function() return exports.qbx_core:GetCid(source) end,
        function() return exports.qbx_core:GetPlayerCid(source) end,
        function() return exports.qbx_core:GetPlayerId and exports.qbx_core:GetPlayerId(source) end,
    }
    for _, fn in ipairs(tries) do
        local ok, cid = pcall(fn)
        if ok and cid then return cid end
    end
    return nil
end

-- Canonical GetCharID with fallbacks
function Framework.GetCharID(source)
    -- 1) try framework exports
    local cid = tryExportsGetCid(source)
    if cid then return cid end

    -- 2) fall back to identifiers (license/steam/discord)
    local ids = GetPlayerIdentifiers(source)
    if ids and type(ids) == "table" then
        for _, v in ipairs(ids) do
            if v:match("^(license:|steam:|discord:)") then
                return v
            end
        end
        -- if no labeled id matched, return the first identifier
        return ids[1]
    end

    -- 3) last resort: server id string
    return tostring(source)
end

-- Backwards-compatibility aliases (some scripts expect different casing/names)
Framework.getCharID = Framework.GetCharID
Framework.getPlayer = Framework.GetPlayer
Framework.hasItem = Framework.HasItem
Framework.addItem = Framework.AddItem
Framework.removeItem = Framework.RemoveItem

return Framework
