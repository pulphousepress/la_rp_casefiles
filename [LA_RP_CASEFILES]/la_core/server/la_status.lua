-- la_core/server/la_status.lua
-- Provides status snapshot export for operators and la_admin.

local state = rawget(_G, 'LA_CORE_STATE') or {}

local function countEntries(list)
    if type(list) ~= 'table' then
        return 0
    end

    if list[1] ~= nil then
        return #list
    end

    local count = 0
    for _ in pairs(list) do
        count = count + 1
    end
    return count
end

local function fetchAddonCount()
    local ok, addons = pcall(function()
        return exports.la_admin:GetRegisteredAddons()
    end)

    if not ok or type(addons) ~= 'table' then
        return 0
    end

    if addons[1] ~= nil then
        return #addons
    end

    local count = 0
    for _ in pairs(addons) do
        count = count + 1
    end
    return count
end

exports('GetStatusSnapshot', function()
    local datasets = (state.codex and state.codex.datasets) or {}
    local vehicles = datasets.vehicles or {}
    local peds = datasets.peds or {}
    local factions = datasets.factions or {}

    return {
        time = os.time(),
        codex_ok = state.codex and state.codex.ok or false,
        vehicles_count = countEntries(vehicles),
        peds_count = countEntries(peds),
        factions_count = countEntries(factions),
        addons_registered = fetchAddonCount(),
    }
end)
