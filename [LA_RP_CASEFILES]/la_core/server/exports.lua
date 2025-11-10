-- la_core/server/exports.lua
-- All public exports that other resources consume.

local state = rawget(_G, 'LA_CORE_STATE') or {}
local datasets = state.codex and state.codex.datasets or {}

local function copyList(list)
    if type(list) ~= 'table' then
        return {}
    end

    local out = {}
    for i = 1, #list do
        out[i] = list[i]
    end
    return out
end

local function ensureDataset(name)
    datasets = (state.codex and state.codex.datasets) or datasets or {}
    local data = datasets[name]
    if type(data) ~= 'table' then
        return {}
    end
    return data
end

local function normalize(value)
    if type(value) == 'string' then
        local trimmed = value:match('^%s*(.-)%s*$')
        return trimmed:lower()
    end
    return value
end

local function valueInSet(value, set)
    if type(set) ~= 'table' then
        return false
    end

    for i = 1, #set do
        if normalize(set[i]) == normalize(value) then
            return true
        end
    end

    return false
end

local function matchesVehicle(vehicle, filters)
    if type(vehicle) ~= 'table' then
        return false
    end

    if type(filters) ~= 'table' or next(filters) == nil then
        return true
    end

    if filters.model then
        local needle = normalize(filters.model)
        local model = vehicle.model and normalize(vehicle.model)
        if model ~= needle then
            return false
        end
    end

    if filters.label then
        local needle = normalize(filters.label)
        local label = vehicle.label and normalize(vehicle.label)
        if label ~= needle then
            return false
        end
    end

    if filters.era_tag then
        local target = normalize(filters.era_tag)
        local tag = vehicle.era_tag and normalize(vehicle.era_tag)
        if tag ~= target then
            return false
        end
    end

    if filters.type then
        local desired = normalize(filters.type)
        local vehicleType = vehicle.type and normalize(vehicle.type)
        if vehicleType ~= desired then
            return false
        end
    end

    if filters.faction then
        local faction = normalize(filters.faction)
        local allowed = vehicle.allowed_factions
        if type(allowed) == 'table' and #allowed > 0 then
            if not valueInSet(faction, allowed) then
                return false
            end
        end
    end

    return true
end

exports('GetVehicleList', function()
    return copyList(ensureDataset('vehicles'))
end)

exports('GetPedList', function()
    return copyList(ensureDataset('peds'))
end)

exports('GetFactionList', function()
    return copyList(ensureDataset('factions'))
end)

exports('FindVehicle', function(filters)
    local matches = {}
    local vehicles = ensureDataset('vehicles')

    for _, vehicle in ipairs(vehicles) do
        if matchesVehicle(vehicle, filters) then
            matches[#matches + 1] = vehicle
        end
    end

    return matches
end)

exports('GetData', function(name)
    if type(name) ~= 'string' or name == '' then
        return nil
    end

    return copyList(ensureDataset(name))
end)
