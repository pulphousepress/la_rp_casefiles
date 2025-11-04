local Config = require('config')

local EngineServer = {}
local initialized = false
local controllers = {}

local function mergeConfig(opts)
    if type(opts) ~= 'table' then return end
    for key, value in pairs(opts) do
        Config[key] = value
    end
end

local function emitLog(level, message)
    local formatted = string.format('[la_engine][%s] %s', level, message)
    if type(Config.logger) == 'function' then
        local ok, err = pcall(Config.logger, level, message, formatted)
        if not ok then
            print(string.format('[la_engine][warn] logger callback failed: %s', err))
        end
    else
        print(formatted)
    end
    return formatted
end

local function ensureCore()
    local ok, core = pcall(require, 'la_core.server.main')
    if ok and type(core) == 'table' and type(core.init) == 'function' then
        local result = core.init({ logger = Config.logger })
        if not result or not result.ok then
            emitLog('warn', 'la_core.init returned error: ' .. tostring(result and result.err or 'unknown'))
        end
    end
end

local function validateOptions(opts)
    if opts ~= nil and type(opts) ~= 'table' then
        return false, 'expected table for options'
    end

    if opts then
        if opts.StatusCommand and type(opts.StatusCommand) ~= 'string' then
            return false, 'StatusCommand must be string'
        end

        if opts.logger and type(opts.logger) ~= 'function' then
            return false, 'logger must be function'
        end
    end

    return true
end

function EngineServer.registerController(name, handler)
    if type(name) ~= 'string' then
        return { ok = false, err = 'name must be string' }
    end
    if type(handler) ~= 'function' then
        return { ok = false, err = 'handler must be function' }
    end
    controllers[name] = handler
    return { ok = true }
end

function EngineServer.dispatch(name, payload)
    if type(name) ~= 'string' then
        return { ok = false, err = 'event name must be string' }
    end
    local handler = controllers[name]
    if not handler then
        return { ok = false, err = 'no controller registered for ' .. name }
    end

    local ok, result = pcall(handler, payload or {}, Config)
    if not ok then
        emitLog('error', string.format('controller %s failed: %s', name, result))
        return { ok = false, err = result }
    end

    return { ok = true, result = result }
end

function EngineServer.init(opts)
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

    local commandName = Config.StatusCommand or 'la_engine_status'

    RegisterCommand(commandName, function(source)
        local msg = emitLog('info', 'engine active')
        if source ~= 0 then
            TriggerClientEvent('chat:addMessage', source, { args = { msg } })
        end
    end, false)

    RegisterNetEvent('la_engine:dispatch', function(name, payload)
        local src = source
        if src ~= 0 then
            emitLog('warn', 'dispatch rejected from client ' .. tostring(src))
            return
        end
        local result = EngineServer.dispatch(name, payload)
        if not result.ok then
            emitLog('error', 'dispatch failed: ' .. tostring(result.err))
        end
    end)

    CreateThread(function()
        emitLog('info', 'runtime initialized')
    end)

    initialized = true

    return { ok = true, command = commandName }
end

return EngineServer
