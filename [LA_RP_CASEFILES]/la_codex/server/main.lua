local RESOURCE_NAME = GetCurrentResourceName()
local LOG_PREFIX = "[la_codex]"

local DATA_FILES = {
    vehicles = { path = "data/vehicles.json", optional = false },
    peds     = { path = "data/peds.json", optional = false },
    factions = { path = "data/factions.json", optional = false },
    addons   = { path = "data/addons.json", optional = true }
}

local codexData = {
    vehicles = {},
    peds = {},
    factions = {},
    addons = {}
}

local vehiclesByModel = {}
local pedsByModel = {}
local factionsById = {}

local function warn(message)
    print(string.format("%s %s", LOG_PREFIX, message))
end

local function stripJsonComments(payload)
    payload = payload:gsub("/%*.-%*/", "")
    payload = payload:gsub("//[^\n\r]*", "")
    return payload
end

local function readJsonFile(path, optional)
    local raw = LoadResourceFile(RESOURCE_NAME, path)
    if not raw or raw == "" then
        if not optional then
            warn(string.format("Unable to load required data file '%s'", path))
        end
        return nil
    end

    local sanitized = stripJsonComments(raw)
    local ok, decoded = pcall(json.decode, sanitized)
    if not ok then
        warn(string.format("Failed to decode JSON from '%s': %s", path, decoded))
        return nil
    end

    if type(decoded) ~= "table" then
        warn(string.format("Expected JSON array/object in '%s'", path))
        return nil
    end

    return decoded
end

local function isArray(tbl)
    local count = 0
    for k in pairs(tbl) do
        if type(k) ~= "number" then
            return false
        end
        count = count + 1
    end
    return count == #tbl
end

local function validateVehicle(entry, index)
    if type(entry) ~= "table" then
        warn(string.format("vehicles[%d] is not an object", index))
        return false
    end

    local model = entry.model
    if type(model) ~= "string" or model == "" then
        warn(string.format("vehicles[%d] is missing a valid 'model'", index))
        return false
    end

    local name = entry.name
    if type(name) ~= "string" or name == "" then
        warn(string.format("vehicles[%d] is missing a valid 'name'", index))
        return false
    end

    if type(entry.class) ~= "string" or entry.class == "" then
        warn(string.format("vehicles[%s] must include a 'class' string", model))
        return false
    end

    if type(entry.price) ~= "number" then
        warn(string.format("vehicles[%s] must include a numeric 'price'", model))
        return false
    end

    if entry.stock ~= nil then
        if type(entry.stock) ~= "number" or entry.stock < 0 or math.floor(entry.stock) ~= entry.stock then
            warn(string.format("vehicles[%s] has invalid 'stock' value", model))
            return false
        end
    else
        entry.stock = 0
    end

    local existing = vehiclesByModel[model]
    if existing then
        warn(string.format("Duplicate vehicle model '%s' detected", model))
        return false
    end

    vehiclesByModel[model] = entry
    return true
end

local function validatePed(entry, index)
    if type(entry) ~= "table" then
        warn(string.format("peds[%d] is not an object", index))
        return false
    end

    local model = entry.model
    if type(model) ~= "string" or model == "" then
        warn(string.format("peds[%d] is missing a valid 'model'", index))
        return false
    end

    if type(entry.role) ~= "string" or entry.role == "" then
        warn(string.format("peds[%s] must include a 'role' string", model))
        return false
    end

    if entry.scenario ~= nil and type(entry.scenario) ~= "string" then
        warn(string.format("peds[%s] has invalid 'scenario' value", model))
        return false
    end

    if pedsByModel[model] then
        warn(string.format("Duplicate ped model '%s' detected", model))
        return false
    end

    pedsByModel[model] = entry
    return true
end

local function validateFaction(entry, index)
    if type(entry) ~= "table" then
        warn(string.format("factions[%d] is not an object", index))
        return false
    end

    local id = entry.id
    if type(id) ~= "string" or id == "" then
        warn(string.format("factions[%d] is missing a valid 'id'", index))
        return false
    end

    if type(entry.name) ~= "string" or entry.name == "" then
        warn(string.format("factions[%s] must include a 'name' string", id))
        return false
    end

    if type(entry.type) ~= "string" or entry.type == "" then
        warn(string.format("factions[%s] must include a 'type' string", id))
        return false
    end

    if entry.color ~= nil and type(entry.color) ~= "string" then
        warn(string.format("factions[%s] has invalid 'color' value", id))
        return false
    end

    if entry.permissions ~= nil then
        if type(entry.permissions) ~= "table" or not isArray(entry.permissions) then
            warn(string.format("factions[%s] must provide 'permissions' as an array", id))
            return false
        end

        for permIndex, perm in ipairs(entry.permissions) do
            if type(perm) ~= "string" or perm == "" then
                warn(string.format("factions[%s].permissions[%d] must be a non-empty string", id, permIndex))
                return false
            end
        end
    else
        entry.permissions = {}
    end

    if factionsById[id] then
        warn(string.format("Duplicate faction id '%s' detected", id))
        return false
    end

    factionsById[id] = entry
    return true
end

local function validateAddon(entry, index)
    if type(entry) ~= "table" then
        warn(string.format("addons[%d] is not an object", index))
        return false
    end

    if type(entry.name) ~= "string" or entry.name == "" then
        warn(string.format("addons[%d] is missing a valid 'name'", index))
        return false
    end

    if type(entry.resource) ~= "string" or entry.resource == "" then
        warn(string.format("addons[%s] must include a 'resource' string", entry.name))
        return false
    end

    if entry.description ~= nil and type(entry.description) ~= "string" then
        warn(string.format("addons[%s] has invalid 'description' value", entry.name))
        return false
    end

    return true
end

local function resetLookups()
    codexData.vehicles = {}
    codexData.peds = {}
    codexData.factions = {}
    codexData.addons = {}

    vehiclesByModel = {}
    pedsByModel = {}
    factionsById = {}
end

local function loadArray(name, entries, validator)
    if type(entries) ~= "table" or not isArray(entries) then
        warn(string.format("The '%s' data must be an array", name))
        return
    end

    for index, entry in ipairs(entries) do
        if validator(entry, index) then
            codexData[name][#codexData[name] + 1] = entry
        end
    end
end

local function bootstrapCodex()
    resetLookups()

    for key, spec in pairs(DATA_FILES) do
        local entries = readJsonFile(spec.path, spec.optional)
        if entries then
            if key == "vehicles" then
                loadArray(key, entries, validateVehicle)
            elseif key == "peds" then
                loadArray(key, entries, validatePed)
            elseif key == "factions" then
                loadArray(key, entries, validateFaction)
            elseif key == "addons" then
                loadArray(key, entries, validateAddon)
            end
        end
    end
end

local function ensureLoadedOnStart(resource)
    if resource ~= RESOURCE_NAME then
        return
    end

    bootstrapCodex()
end

AddEventHandler("onResourceStart", ensureLoadedOnStart)

if GetResourceState(RESOURCE_NAME) == "started" then
    bootstrapCodex()
end

function GetCodexData()
    return codexData
end

function GetVehicleByModel(model)
    return vehiclesByModel[model]
end

function GetPedByModel(model)
    return pedsByModel[model]
end

function GetFactionById(id)
    return factionsById[id]
end
