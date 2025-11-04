local enabled = Config.Enable
local catalog, variants = {}, {}
local order, cursor = {}, 1  -- deterministic cycling

local function loadJson(path)
    local raw = LoadResourceFile(GetCurrentResourceName(), path)
    return raw and json.decode(raw) or nil
end

local function isFreemodeMale(model)
    return model == joaat("mp_m_freemode_01")
end

local function isFreemodeFemale(model)
    return model == joaat("mp_f_freemode_01")
end

local function getSexKey(ped)
    local m = GetEntityModel(ped)
    if isFreemodeMale(m) then return "male" end
    if isFreemodeFemale(m) then return "female" end
    -- Fallback: use male mappings; most masks share drawables/textures
    return "male"
end

local function loadData()
    catalog = loadJson(Config.CatalogFile) or {}
    variants = loadJson(Config.VariantsFile) or {}
    order, cursor = {}, 1
    for i, entry in ipairs(catalog) do
        if entry.id then table.insert(order, entry.id) end
    end
    if Config.Debug then
        print(("[la_masks] Loaded %d catalog, %d variants."):format(#catalog, (variants and #variants) or 0))
    end
end

local function applyMaskId(maskId)
    if not enabled then return false end
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return false end

    local sexKey = getSexKey(ped)
    local v = variants[maskId]
    if not v or not v[sexKey] then
        if Config.Debug then
            print(("[la_masks] No variant for '%s' sex=%s"):format(maskId, sexKey))
        end
        return false
    end

    local comp = Config.MaskComponentIndex
    local drawable = tonumber(v[sexKey].d or 0) or 0
    local texture  = tonumber(v[sexKey].t or 0) or 0

    SetPedComponentVariation(ped, comp, drawable, texture, 0)

    if Config.Debug then
        print(("[la_masks] Applied %s (sex=%s, comp=%d, d=%d, t=%d)"):format(maskId, sexKey, comp, drawable, texture))
    end
    return true
end

-- Export + Event
exports("ApplyMask", applyMaskId)
RegisterNetEvent("la_masks:apply", function(maskId)
    applyMaskId(maskId)
end)

-- Cycle to next mask in catalog
local function cycleNext()
    if #order == 0 then return end
    if cursor > #order then cursor = 1 end
    local id = order[cursor]
    cursor = cursor + 1
    local ok = applyMaskId(id)
    if ok and Config.Debug then
        print("[la_masks] Cycle -> " .. id)
    end
end

-- Debug/test command for this module
RegisterCommand("la_masks", function()
    if not enabled then
        print("[la_masks] Disabled in config.")
        return
    end
    cycleNext()
end, false)

-- Init
CreateThread(function()
    loadData()
    if Config.Debug then print("[la_masks] Client ready.") end
end)
