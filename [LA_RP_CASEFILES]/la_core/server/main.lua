-- la_core/server/main.lua
-- Bootstrap codex caches and provide a stable API surface for other resources.

local RESOURCE_NAME = GetCurrentResourceName()
local CODEX_RESOURCE = Config.CodexResource or 'la_codex'

local state = rawget(_G, 'LA_CORE_STATE')
if not state then
    state = {
        resource = RESOURCE_NAME,
        codex = {
            resource = CODEX_RESOURCE,
            datasets = {
                vehicles = {},
                peds = {},
                factions = {},
            },
            ok = false,
            lastSync = 0,
        },
        indices = {
            vehicles = {},
        },
    }
    _G.LA_CORE_STATE = state
else
    state.resource = RESOURCE_NAME
    state.codex = state.codex or { resource = CODEX_RESOURCE, datasets = {} }
    state.codex.resource = CODEX_RESOURCE
    state.codex.datasets = state.codex.datasets or {}
    state.codex.datasets.vehicles = state.codex.datasets.vehicles or {}
    state.codex.datasets.peds = state.codex.datasets.peds or {}
    state.codex.datasets.factions = state.codex.datasets.factions or {}
    state.indices = state.indices or { vehicles = {} }
end

local DATASETS = { 'vehicles', 'peds', 'factions' }

local function log(level, message)
    print(('[la_core][%s] %s'):format(level, message))
end

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

local function buildVehicleIndex(list)
    local idx = {}

    if type(list) ~= 'table' then
        return idx
    end

    for _, entry in ipairs(list) do
        if type(entry) == 'table' then
            local model = entry.model
            if type(model) == 'string' and model ~= '' then
                idx[model:lower()] = entry
            end
            local label = entry.label
            if type(label) == 'string' and label ~= '' then
                idx[label:lower()] = entry
            end
        end
    end

    return idx
end

local function fetchDataset(name)
    local ok, payload = pcall(function()
        return exports[state.codex.resource]:GetCodexData(name)
    end)

    if not ok then
        log('warn', ('Failed to query %s:GetCodexData("%s"): %s'):format(state.codex.resource, name, tostring(payload)))
        return nil
    end

    if type(payload) ~= 'table' then
        log('warn', ('Codex dataset %s returned %s (expected table)'):format(name, type(payload)))
        return nil
    end

    return payload
end

local function refreshCodex()
    local summary = {}
    local codexOk = true

    for _, name in ipairs(DATASETS) do
        local data = fetchDataset(name)
        if not data then
            codexOk = false
            data = {}
        end
        state.codex.datasets[name] = data

        if name == 'vehicles' then
            state.indices.vehicles = buildVehicleIndex(data)
        end

        local count = countEntries(data)
        summary[#summary + 1] = ('%s=%d'):format(name, count)
    end

    state.codex.ok = codexOk
    state.codex.lastSync = os.time()
    state.codex.summary = table.concat(summary, ' ')

    log('info', ('Codex sync complete (%s)'):format(state.codex.summary))
    TriggerEvent('la_core:codexUpdated', state.codex.datasets)
end

state.refreshCodex = refreshCodex

AddEventHandler('onResourceStart', function(resource)
    if resource ~= RESOURCE_NAME then
        if resource == state.codex.resource then
            log('info', 'Codex resource restarted; refreshing datasets')
            refreshCodex()
        end
        return
    end

    log('info', ('Resource start — linking to codex resource "%s"'):format(state.codex.resource))
    refreshCodex()
    TriggerEvent('la_core:ready', state.codex.datasets)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == state.codex.resource then
        log('warn', 'Codex resource stopped; cached data will remain until refresh')
        state.codex.ok = false
    end
end)

RegisterCommand(Config.ReloadCommand or 'la_codex_reload', function(source)
    if source ~= 0 then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1la_core', 'This command can only be run from the server console.' } })
        return
    end

    log('info', 'Manual codex reload requested from console')
    refreshCodex()
end, false)

if GetResourceState(RESOURCE_NAME) == 'started' then
    refreshCodex()
end

exports('GetVersion', function()
    return Config.Version or '0.0.0'
end)

exports('PrintStatus', function()
    local summary = state.codex.summary or 'no datasets'
    log('info', ('v%s codex=%s (%s)'):format(Config.Version or '0.0.0', state.codex.resource, summary))
end)
