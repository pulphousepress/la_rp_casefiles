local Config = require('config')

local EngineClient = {}
local initialized = false

local function mergeConfig(opts)
    if type(opts) ~= 'table' then return end
    for key, value in pairs(opts) do
        Config[key] = value
    end
end

local function emitLog(level, message)
    local formatted = string.format('[la_engine][%s] %s', level, message)
    if Config.Debug then
        print(formatted)
    end
    return formatted
end

local function ensureCore()
    local ok, core = pcall(require, 'la_core.client.main')
    if ok and type(core) == 'table' and type(core.init) == 'function' then
        local result = core.init({ Debug = Config.Debug })
        if not result or not result.ok then
            emitLog('warn', 'la_core client init returned error: ' .. tostring(result and result.err or 'unknown'))
        end
    end
end

local function validateOptions(opts)
    if opts ~= nil and type(opts) ~= 'table' then
        return false, 'expected table for options'
    end

    return true
end

function EngineClient.init(opts)
    if initialized then
        return { ok = true, alreadyInitialized = true }
    end

    local ok, err = validateOptions(opts)
    if not ok then
        return { ok = false, err = err }
    end

    mergeConfig(opts)

    if Config.Enable == false then
        initialized = true
        return { ok = true, disabled = true }
    end

    ensureCore()

    RegisterCommand(Config.StatusCommand or 'la_engine_status', function()
        emitLog('info', 'engine client active')
    end, false)

    initialized = true

    return { ok = true }
end

return EngineClient
-- la_engine client stub
RegisterNetEvent('la_engine:ClientSpawnVehicle', function(model, coords)
    print('[la_engine - client] spawn vehicle event received: ' .. tostring(model))
    -- client spawn code would go here; left as an exercise for the real engine
    -- Example: TriggerEvent('vehicle:spawn', model, coords)
end)
