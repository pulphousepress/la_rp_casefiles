-- la_admin/server/main.lua
-- Bootstraps the admin control surface and exposes addon registry exports.

local RESOURCE_NAME = GetCurrentResourceName()

local function loadModule(path)
    local chunk = LoadResourceFile(RESOURCE_NAME, path)
    if not chunk then
        error(('Failed to load module %s'):format(path))
    end

    local fn, err = load(chunk, ('@@%s/%s'):format(RESOURCE_NAME, path))
    if not fn then
        error(('Failed to compile %s: %s'):format(path, tostring(err)))
    end

    local ok, result = pcall(fn)
    if not ok then
        error(('Error executing %s: %s'):format(path, tostring(result)))
    end

    if type(result) ~= 'table' then
        error(('Module %s did not return a table'):format(path))
    end

    return result
end

local Registry = loadModule('server/addons_registry.lua')
local Commands = loadModule('server/commands.lua')

local function log(level, message)
    print(('[la_admin][%s] %s'):format(level, message))
end

local function fetchCoreStatus()
    local ok, status = pcall(function()
        return exports.la_core:GetStatusSnapshot()
    end)

    if not ok then
        return nil, status
    end

    if type(status) ~= 'table' then
        return nil, 'invalid status payload'
    end

    return status
end

local function bootstrap(resource)
    if resource ~= RESOURCE_NAME then
        return
    end

    local status, err = fetchCoreStatus()
    if status then
        log('info', ('Linked to la_core (vehicles=%d peds=%d factions=%d, addons=%d)'):format(
            status.vehicles_count or 0,
            status.peds_count or 0,
            status.factions_count or 0,
            status.addons_registered or 0
        ))
    else
        log('warn', ('Unable to query la_core status: %s'):format(tostring(err)))
    end

    Commands.register({
        config = Config,
        registry = {
            getAll = Registry.getAll,
            getByCapability = Registry.getByCapability,
        },
        getStatus = function()
            return fetchCoreStatus() or { codex_ok = false }
        end,
    })
end

AddEventHandler('onResourceStart', bootstrap)

if GetResourceState(RESOURCE_NAME) == 'started' then
    bootstrap(RESOURCE_NAME)
end

exports('RegisterAddon', function(descriptor)
    local ok, result = Registry.register(descriptor)
    return ok, result
end)

exports('GetRegisteredAddons', function()
    return Registry.getAll()
end)

exports('GetAddonsByCapability', function(capability)
    return Registry.getByCapability(capability)
end)
